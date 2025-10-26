-- Tests for accept_both operation
describe("Claude Diff - Accept Both", function()
  local actions = require("claude_diff.actions")
  local diff = require("claude_diff.diff")
  local utils = require("tests.claude_diff.test_utils")

  describe("accept_both", function()
    it("creates conflict markers with current, baseline, and Claude changes", function()
      local baseline = { "line1", "original", "line3" }
      local current = { "line1", "modified", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Accept both for the change hunk
      actions.accept_both(buf, st, 1)

      local result = utils.get_buffer_lines(buf)

      -- Should have conflict markers
      assert.equals("line1", result[1])
      assert.equals("<<<<<<< Current (your edits)", result[2])
      assert.equals("modified", result[3])
      assert.equals("||||||| Baseline (original)", result[4])
      assert.equals("original", result[5])
      assert.equals("=======", result[6])
      assert.equals("modified", result[7])
      assert.equals(">>>>>>> Claude (AI changes)", result[8])
      assert.equals("line3", result[9])

      -- Hunk should be removed after accept_both
      assert.equals(0, #st.hunks)
    end)

    it("handles multi-line hunks correctly", function()
      local baseline = { "line1", "old2", "old3", "line4" }
      local current = { "line1", "new2", "new3", "line4" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      actions.accept_both(buf, st, 1)

      local result = utils.get_buffer_lines(buf)

      -- Should have multi-line content in each section
      assert.equals("line1", result[1])
      assert.equals("<<<<<<< Current (your edits)", result[2])
      assert.equals("new2", result[3])
      assert.equals("new3", result[4])
      assert.equals("||||||| Baseline (original)", result[5])
      assert.equals("old2", result[6])
      assert.equals("old3", result[7])
      assert.equals("=======", result[8])
      assert.equals("new2", result[9])
      assert.equals("new3", result[10])
      assert.equals(">>>>>>> Claude (AI changes)", result[11])
      assert.equals("line4", result[12])
    end)

    it("updates baseline with merged content", function()
      local baseline = { "line1", "original", "line3" }
      local current = { "line1", "modified", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      actions.accept_both(buf, st, 1)

      -- Baseline should now include the conflict markers
      assert.equals("line1", st.baseline.lines[1])
      assert.equals("<<<<<<< Current (your edits)", st.baseline.lines[2])
      assert.equals("modified", st.baseline.lines[3])
      assert.equals("||||||| Baseline (original)", st.baseline.lines[4])
      assert.equals("original", st.baseline.lines[5])
      assert.equals("=======", st.baseline.lines[6])
      assert.equals("modified", st.baseline.lines[7])
      assert.equals(">>>>>>> Claude (AI changes)", st.baseline.lines[8])
      assert.equals("line3", st.baseline.lines[9])
    end)
  end)
end)
