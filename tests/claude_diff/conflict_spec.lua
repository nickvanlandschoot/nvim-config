-- Tests for conflict detection and user edit tracking
describe("Claude Diff - Conflict Detection", function()
  local diff = require("claude_diff.diff")
  local state = require("claude_diff.state")
  local utils = require("tests.claude_diff.test_utils")

  describe("exclude_user_overlaps", function()
    it("marks hunks as conflicted when overlapping with user edits", function()
      local baseline = { "line1", "line2", "line3", "line4" }
      local current = { "line1", "changed2", "line3", "line4" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- Simulate user editing line 2
      st.user_ranges = { { s = 2, e = 2 } }

      diff.exclude_user_overlaps(st, hunks)

      assert.equals(1, #st.hunks)
      assert.is_true(st.hunks[1].conflicted)
    end)

    it("does not mark non-overlapping hunks as conflicted", function()
      local baseline = { "line1", "line2", "line3", "line4" }
      local current = { "line1", "changed2", "line3", "changed4" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- User edited line 4, but not line 2
      st.user_ranges = { { s = 4, e = 4 } }

      diff.exclude_user_overlaps(st, hunks)

      assert.equals(2, #st.hunks)
      -- First hunk (line 2) should not be conflicted
      assert.is_false(st.hunks[1].conflicted)
      -- Second hunk (line 4) should be conflicted
      assert.is_true(st.hunks[2].conflicted)
    end)

    it("handles multiple user ranges with overlaps", function()
      local baseline = { "line1", "line2", "line3", "line4", "line5" }
      local current = { "line1", "changed2", "line3", "changed4", "line5" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- User edited lines 2-3 and line 4
      st.user_ranges = { { s = 2, e = 3 }, { s = 4, e = 4 } }

      diff.exclude_user_overlaps(st, hunks)

      assert.equals(2, #st.hunks)
      -- Both hunks should be conflicted
      assert.is_true(st.hunks[1].conflicted)
      assert.is_true(st.hunks[2].conflicted)
    end)

    it("handles user range that spans multiple hunks", function()
      local baseline = { "line1", "line2", "line3", "line4", "line5" }
      local current = { "line1", "changed2", "line3", "changed4", "line5" }

      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)

      -- User edited a large range covering both hunks
      st.user_ranges = { { s = 1, e = 5 } }

      diff.exclude_user_overlaps(st, hunks)

      assert.equals(2, #st.hunks)
      assert.is_true(st.hunks[1].conflicted)
      assert.is_true(st.hunks[2].conflicted)
    end)
  end)

  describe("track_user_edit", function()
    it("detects user edits and adds to user_ranges", function()
      local buf = utils.create_test_buffer({ "line1", "line2", "line3" })

      -- Initialize state through the state module
      local st = state.buf_state(buf, false)
      st.user_snapshot.lines = { "line1", "line2", "line3" }
      st.hunks = {}

      -- Simulate user changing line 2
      vim.api.nvim_buf_set_lines(buf, 1, 2, false, { "user_changed" })

      -- track_user_edit takes just the buffer, looks up state internally
      state.track_user_edit(buf, false)

      -- Get the updated state
      st = state.buf_state(buf, false)

      -- Should have recorded a user range at line 2
      assert.equals(1, #st.user_ranges)
      assert.equals(2, st.user_ranges[1].s)
      assert.equals(2, st.user_ranges[1].e)
    end)

    it("coalesces adjacent user edit ranges", function()
      local buf = utils.create_test_buffer({ "line1", "line2", "line3", "line4" })

      local st = state.buf_state(buf, false)
      st.user_snapshot.lines = { "line1", "line2", "line3", "line4" }
      st.user_ranges = { { s = 2, e = 2 } }
      st.hunks = {}

      -- User edits line 3 (adjacent to existing range)
      vim.api.nvim_buf_set_lines(buf, 2, 3, false, { "changed3" })

      state.track_user_edit(buf, false)

      -- Get updated state
      st = state.buf_state(buf, false)

      -- Ranges should be coalesced into one
      assert.equals(1, #st.user_ranges)
      assert.equals(2, st.user_ranges[1].s)
      assert.equals(3, st.user_ranges[1].e)
    end)
  end)
end)
