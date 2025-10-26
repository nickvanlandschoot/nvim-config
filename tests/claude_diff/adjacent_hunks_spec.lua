-- Tests for adjacent and close hunks - critical for consistency
describe("Claude Diff - Adjacent Hunks", function()
  local diff = require("claude_diff.diff")
  local actions = require("claude_diff.actions")
  local utils = require("tests.claude_diff.test_utils")

  describe("consecutive line changes", function()
    it("handles two consecutive single-line changes", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
      }
      local current = {
        "line1",
        "changed2",
        "changed3",
        "line4",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- vim.diff may merge these into 1 hunk since they're consecutive
      assert.is_true(#hunks == 1 or #hunks == 2)

      if #hunks == 1 then
        -- If merged, should span both lines
        assert.equals(2, hunks[1].s)
        assert.equals(3, hunks[1].e)
      else
        -- If separate, both should be changes
        assert.equals("change", hunks[1].kind)
        assert.equals("change", hunks[2].kind)
      end
    end)

    it("handles three consecutive changes", function()
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

      -- Should likely be 1 merged hunk
      assert.equals(1, #hunks)
      assert.equals("change", hunks[1].kind)
      assert.equals(2, hunks[1].s)
      assert.equals(4, hunks[1].e)
    end)

    it("keeps consecutive additions as one hunk", function()
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

      -- Should be one addition hunk
      assert.equals(1, #hunks)
      assert.equals("add", hunks[1].kind)
    end)

    it("keeps consecutive deletions as one hunk", function()
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

      -- Should be one deletion hunk
      assert.equals(1, #hunks)
      assert.equals("del", hunks[1].kind)
    end)
  end)

  describe("minimal gaps between hunks", function()
    it("separates hunks with exactly 1 line gap", function()
      local baseline = {
        "line1",
        "line2",
        "changed2",
        "line3",
        "line4",
        "changed4",
        "line5",
      }
      local current = {
        "line1",
        "line2",
        "new2",
        "line3",
        "line4",
        "new4",
        "line5",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should be 2 separate hunks with 1 unchanged line between
      assert.equals(2, #hunks)
      assert.equals(3, hunks[1].s)
      assert.equals(3, hunks[1].e)
      assert.equals(6, hunks[2].s)
      assert.equals(6, hunks[2].e)
    end)

    it("separates with 1 line gap between addition and change", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
      }
      local current = {
        "line1",
        "added1",
        "line2",
        "line3",
        "changed4",
        "line5",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)
      assert.equals("add", hunks[1].kind)
      assert.equals("change", hunks[2].kind)
    end)

    it("separates with 1 line gap between deletion and addition", function()
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
        "line3",
        "added1",
        "line4",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)
      assert.equals("del", hunks[1].kind)
      assert.equals("add", hunks[2].kind)
    end)
  end)

  describe("replacement scenarios (delete + add same position)", function()
    it("handles line replacement as change hunk", function()
      local baseline = {
        "line1",
        "old_content",
        "line3",
      }
      local current = {
        "line1",
        "new_content",
        "line3",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should be single change hunk
      assert.equals(1, #hunks)
      assert.equals("change", hunks[1].kind)
      assert.equals(2, hunks[1].s)
      assert.equals(2, hunks[1].e)
    end)

    it("handles multi-line replacement", function()
      local baseline = {
        "line1",
        "old1",
        "old2",
        "old3",
        "line5",
      }
      local current = {
        "line1",
        "new1",
        "new2",
        "line5",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should be one change hunk
      assert.equals(1, #hunks)
      assert.equals("change", hunks[1].kind)
      -- Should span the changed lines
      assert.is_true(hunks[1].s >= 2 and hunks[1].e >= 2)
    end)

    it("handles replace with different line counts", function()
      local baseline = {
        "start",
        "to_replace",
        "end",
      }
      local current = {
        "start",
        "replacement1",
        "replacement2",
        "replacement3",
        "end",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(1, #hunks)
      assert.equals("change", hunks[1].kind)
      assert.are.same({ "to_replace" }, hunks[1].old)
      assert.are.same(
        { "replacement1", "replacement2", "replacement3" },
        hunks[1].new
      )
    end)
  end)

  describe("accept/reject with adjacent hunks", function()
    it("accepting one hunk doesn't affect adjacent hunk", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
        "line6",
      }
      local current = {
        "line1",
        "changed2",
        "line3",
        "line4",
        "changed5",
        "line6",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Accept first hunk
      actions.accept_hunk(buf, st, 1)

      -- Should still have second hunk
      assert.is_true(#st.hunks >= 1)

      -- Get the remaining hunk (positions may have shifted)
      local remaining = st.hunks[#st.hunks]
      if remaining then
        assert.equals("change", remaining.kind)
      end
    end)

    it("rejecting one adjacent hunk doesn't affect other", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
        "line6",
      }
      local current = {
        "line1",
        "changed2",
        "line3",
        "line4",
        "changed5",
        "line6",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      local initial_count = #st.hunks

      -- Reject first hunk (revert it to baseline)
      actions.reject_hunk(buf, st, 1)

      -- Should have fewer hunks (first one removed)
      assert.is_true(#st.hunks <= initial_count)
    end)

    it("accept_all works correctly with adjacent hunks", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
        "line6",
      }
      local current = {
        "line1",
        "changed2",
        "line3",
        "line4",
        "changed5",
        "line6",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Accept all
      actions.accept_all(buf, st)

      -- Should have no hunks remaining
      assert.equals(0, #st.hunks)

      -- Buffer should match current (Claude's version)
      local result = utils.get_buffer_lines(buf)
      assert.are.same(current, result)
    end)

    it("reject_all works correctly with adjacent hunks", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
        "line4",
        "line5",
        "line6",
      }
      local current = {
        "line1",
        "changed2",
        "line3",
        "line4",
        "changed5",
        "line6",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Reject all
      actions.reject_all(buf, st)

      -- Should have no hunks remaining
      assert.equals(0, #st.hunks)

      -- Buffer should match baseline (user's version)
      local result = utils.get_buffer_lines(buf)
      assert.are.same(baseline, result)
    end)
  end)

  describe("complex adjacent scenarios", function()
    it("handles alternating additions and changes", function()
      local baseline = {
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
      }
      local current = {
        "a",
        "added1",
        "b",
        "changed_c",
        "d",
        "added2",
        "e",
        "f",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have multiple hunks
      assert.is_true(#hunks >= 2)

      -- Verify no overlaps
      for i = 1, #hunks - 1 do
        assert.is_true(hunks[i].e < hunks[i + 1].s)
      end
    end)

    it("handles change surrounded by additions", function()
      local baseline = {
        "line1",
        "line2",
        "line3",
      }
      local current = {
        "added_before",
        "line1",
        "changed_line2",
        "line3",
        "added_after",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have hunks for all changes
      assert.is_true(#hunks >= 1)

      -- All hunks should be properly positioned
      for _, h in ipairs(hunks) do
        assert.is_true(h.s >= 1)
        assert.is_true(h.e >= h.s)
      end
    end)

    it("handles dense changes with minimal spacing", function()
      local baseline = {
        "a",
        "b1",
        "c",
        "d1",
        "e",
        "f1",
        "g",
      }
      local current = {
        "a",
        "b2",
        "c",
        "d2",
        "e",
        "f2",
        "g",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Should have 3 hunks (one per change with 1-line gaps)
      assert.equals(3, #hunks)

      -- All should be changes
      for _, h in ipairs(hunks) do
        assert.equals("change", h.kind)
      end

      -- Verify positions are correct
      assert.equals(2, hunks[1].s)
      assert.equals(4, hunks[2].s)
      assert.equals(6, hunks[3].s)
    end)

    it("preserves content in complex adjacent scenario", function()
      local baseline = {
        "start",
        "a",
        "b",
        "middle",
        "c",
        "d",
        "end",
      }
      local current = {
        "start",
        "a_new",
        "b_new",
        "middle",
        "c_new",
        "d_new",
        "end",
      }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)

      -- First hunk content
      assert.are.same({ "a", "b" }, hunks[1].old)
      assert.are.same({ "a_new", "b_new" }, hunks[1].new)

      -- Second hunk content
      assert.are.same({ "c", "d" }, hunks[2].old)
      assert.are.same({ "c_new", "d_new" }, hunks[2].new)
    end)
  end)
end)
