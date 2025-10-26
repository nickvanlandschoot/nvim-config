-- Tests for diff calculation
describe("Claude Diff - Diff Calculation", function()
  local diff = require("claude_diff.diff")
  local utils = require("tests.claude_diff.test_utils")

  describe("build_hunks", function()
    it("detects additions", function()
      local baseline = { "line1", "line2", "line4" }
      local current = { "line1", "line2", "line3", "line4" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(1, #hunks)
      assert.equals("add", hunks[1].kind)
      assert.equals(3, hunks[1].s)  -- line 3 in current buffer
      assert.equals(3, hunks[1].e)
      assert.equals(3, hunks[1].old_s)  -- line 3 in baseline (doesn't exist, but position)
      assert.are.same({ "line3" }, hunks[1].new)
    end)

    it("detects deletions", function()
      local baseline = { "line1", "line2", "line3", "line4" }
      local current = { "line1", "line2", "line4" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(1, #hunks)
      assert.equals("del", hunks[1].kind)
      assert.equals(3, hunks[1].s)  -- line 3 in current buffer
      assert.are.same({ "line3" }, hunks[1].old)
    end)

    it("detects changes", function()
      local baseline = { "line1", "original", "line3" }
      local current = { "line1", "modified", "line3" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(1, #hunks)
      assert.equals("change", hunks[1].kind)
      assert.equals(2, hunks[1].s)
      assert.equals(2, hunks[1].e)
      assert.are.same({ "original" }, hunks[1].old)
      assert.are.same({ "modified" }, hunks[1].new)
    end)

    it("handles multiple hunks", function()
      local baseline = { "line1", "line2", "line3", "line4", "line5" }
      local current = { "line1", "changed2", "line3", "added", "line4", "line5" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      assert.equals(2, #hunks)
      -- First hunk: change at line 2
      assert.equals("change", hunks[1].kind)
      assert.equals(2, hunks[1].s)
      -- Second hunk: addition at line 4
      assert.equals("add", hunks[2].kind)
      assert.equals(4, hunks[2].s)
    end)
  end)

  describe("merge_hunk_to_baseline", function()
    it("correctly updates baseline for additions", function()
      local baseline = { "line1", "line2", "line3" }
      local current = { "line1", "line2", "added", "line3" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Accept the addition
      diff.merge_hunk_to_baseline(st, hunks[1])

      local expected = { "line1", "line2", "added", "line3" }
      assert.is_true(utils.lines_equal(expected, st.baseline.lines))
    end)

    it("correctly updates baseline for deletions", function()
      local baseline = { "line1", "line2", "todelete", "line3" }
      local current = { "line1", "line2", "line3" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Accept the deletion
      diff.merge_hunk_to_baseline(st, hunks[1])

      local expected = { "line1", "line2", "line3" }
      assert.is_true(utils.lines_equal(expected, st.baseline.lines))
    end)

    it("correctly updates baseline for changes", function()
      local baseline = { "line1", "original", "line3" }
      local current = { "line1", "modified", "line3" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Accept the change
      diff.merge_hunk_to_baseline(st, hunks[1])

      local expected = { "line1", "modified", "line3" }
      assert.is_true(utils.lines_equal(expected, st.baseline.lines))
    end)
  end)
end)
