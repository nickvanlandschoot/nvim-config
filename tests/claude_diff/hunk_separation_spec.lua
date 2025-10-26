-- Tests for proper hunk separation and isolation
describe("Claude Diff - Hunk Separation", function()
  local diff = require("claude_diff.diff")
  local utils = require("tests.claude_diff.test_utils")

  describe("hunks stay separated with proper spacing", function()
    it("keeps hunks separate when there are unchanged lines between them", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
        "line6",
        "line7",
      }
      local current = {
        "line1",
        "changed2",  -- change at line 2
        "line3",
        "line4",
        "line5",
        "changed6", -- change at line 6
        "line7",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have 2 separate hunks
      assert.equals(2, #hunks)
      -- First hunk at line 2
      assert.equals(2, hunks[1].s)
      assert.equals(2, hunks[1].e)
      -- Second hunk at line 6
      assert.equals(6, hunks[2].s)
      assert.equals(6, hunks[2].e)
    end)

    it("keeps additions separate when spaced apart", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
      }
      local current = {
        "line1",
        "inserted1",  -- addition after line 1
        "line2",
        "line3",
        "line4",
        "inserted2", -- addition after line 4
        "line5",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have 2 separate hunks
      assert.equals(2, #hunks)
      -- Both should be additions
      assert.equals("add", hunks[1].kind)
      assert.equals("add", hunks[2].kind)
      -- First at line 2
      assert.equals(2, hunks[1].s)
      -- Second at line 6
      assert.equals(6, hunks[2].s)
    end)

    it("keeps deletions separate when spaced apart", function()
      local baseline = {
        "line1",
        "deleted1",
        "line2",
        "line3",
        "deleted2",
        "line4",
      }
      local current = {
        "line1",
        "line2",
        "line3",
        "line4",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have 2 separate hunks
      assert.equals(2, #hunks)
      -- Both should be deletions
      assert.equals("del", hunks[1].kind)
      assert.equals("del", hunks[2].kind)
    end)
  end)

  describe("hunk boundaries are correct", function()
    it("correctly identifies hunk start and end lines", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
      }
      local current = {
        "line1",
        "changed2",
        "changed3",
        "changed4",
        "line5",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(1, #hunks)
      assert.equals(2, hunks[1].s)
      assert.equals(4, hunks[1].e)
    end)

    it("handles multi-line additions correctly", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
      }
      local current = {
        "line1",
        "added1",
        "added2",
        "added3",
        "line2",
        "line3",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(1, #hunks)
      assert.equals("add", hunks[1].kind)
      assert.equals(2, hunks[1].s)
      assert.equals(4, hunks[1].e)
    end)

    it("handles multi-line deletions correctly", function()
      local baseline = {
        "line1",
        "deleted1",
        "deleted2",
        "deleted3",
        "line2",
        "line3",
      }
      local current = {
        "line1",
        "line2",
        "line3",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(1, #hunks)
      assert.equals("del", hunks[1].kind)
      -- Deletion shows as position 2 in current buffer
      assert.equals(2, hunks[1].s)
    end)
  end)

  describe("mixed hunk types stay separate", function()
    it("keeps additions separate from changes", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
      }
      local current = {
        "line1",
        "inserted",  -- addition
        "line2",
        "changed3",  -- change (gap between hunks)
        "line4",
        "line5",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)
      assert.equals("add", hunks[1].kind)
      assert.equals("change", hunks[2].kind)
    end)

    it("keeps deletions separate from additions", function()
      local baseline = {
        "line1",
        "deleted1",
        "line2",
        "line3",
        "line4",
      }
      local current = {
        "line1",
        "line2",
        "inserted1",  -- addition (gap)
        "line3",
        "line4",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)
      assert.equals("del", hunks[1].kind)
      assert.equals("add", hunks[2].kind)
    end)

    it("keeps changes separate from deletions", function()
      local baseline = {
        "line1",
        "changed1",
        "line2",
        "line3",
        "deleted1",
        "line4",
      }
      local current = {
        "line1",
        "modified1",
        "line2",
        "line3",
        "line4",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)
      assert.equals("change", hunks[1].kind)
      assert.equals("del", hunks[2].kind)
    end)
  end)

  describe("complex multi-hunk scenarios", function()
    it("handles many hunks across large file", function()
      local baseline = {}
      local current = {}

      -- Create 5 separate hunks with gaps
      for i = 1, 50 do
        table.insert(baseline, "line" .. i)
        if i % 10 == 5 then
          -- Create a change hunk
          table.insert(current, "changed" .. i)
        else
          table.insert(current, "line" .. i)
        end
      end

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have 5 hunks (one per change)
      assert.equals(5, #hunks)

      -- All should be changes
      for _, h in ipairs(hunks) do
        assert.equals("change", h.kind)
      end
    end)

    it("handles alternating additions and deletions", function()
      local baseline = {
        "line1",
        "line2",
        "deleted1",
        "line3",
        "line4",
        "deleted2",
        "line5",
        "line6",
      }
      local current = {
        "line1",
        "inserted1",
        "line2",
        "line3",
        "inserted2",
        "line4",
        "line5",
        "inserted3",
        "line6",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have multiple hunks, properly separated
      assert.is_true(#hunks >= 2)

      -- Verify hunks don't overlap
      for i = 1, #hunks - 1 do
        assert.is_true(hunks[i].e < hunks[i + 1].s or hunks[i].e < hunks[i + 1].s)
      end
    end)

    it("all hunks have non-overlapping ranges", function()
      local baseline = {
        "a", "changed1", "b", "c", "changed2", "d", "e", "changed3", "f"
      }
      local current = {
        "a", "modified1", "b", "c", "modified2", "d", "e", "modified3", "f"
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Verify no overlaps
      for i = 1, #hunks - 1 do
        local h1 = hunks[i]
        local h2 = hunks[i + 1]
        -- h1 must end before h2 starts
        assert.is_true(h1.e < h2.s, string.format(
          "Hunk %d (lines %d-%d) overlaps with hunk %d (lines %d-%d)",
          i, h1.s, h1.e, i + 1, h2.s, h2.e
        ))
      end
    end)
  end)

  describe("content preservation in separated hunks", function()
    it("each hunk contains correct old and new content", function()
      local baseline = {
        "line1",
        "old_a",
        "line2",
        "old_b",
        "line3",
      }
      local current = {
        "line1",
        "new_a",
        "line2",
        "new_b",
        "line3",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)

      -- First hunk
      assert.are.same({ "old_a" }, hunks[1].old)
      assert.are.same({ "new_a" }, hunks[1].new)

      -- Second hunk
      assert.are.same({ "old_b" }, hunks[2].old)
      assert.are.same({ "new_b" }, hunks[2].new)
    end)

    it("preserves exact line content in multi-line hunks", function()
      local baseline = {
        "start",
        "old line 1",
        "old line 2",
        "old line 3",
        "middle",
        "old x",
        "old y",
        "end",
      }
      local current = {
        "start",
        "new line 1",
        "new line 2",
        "new line 3",
        "middle",
        "new x",
        "new y",
        "end",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)

      -- First hunk should have exact old/new content
      assert.are.same(
        { "old line 1", "old line 2", "old line 3" },
        hunks[1].old
      )
      assert.are.same(
        { "new line 1", "new line 2", "new line 3" },
        hunks[1].new
      )

      -- Second hunk
      assert.are.same({ "old x", "old y" }, hunks[2].old)
      assert.are.same({ "new x", "new y" }, hunks[2].new)
    end)
  end)
end)
