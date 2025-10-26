-- Tests for dynamic position adjustment
describe("Claude Diff - Position Adjustment", function()
  local state = require("claude_diff.state")
  local utils = require("tests.claude_diff.test_utils")

  describe("adjust_hunk_positions", function()
    it("shifts hunks down when user adds lines above", function()
      local st = utils.create_test_state({ "line1", "line2", "line3" }, { "line1", "line2", "line3" })

      -- Create a hunk at line 3
      st.hunks = {
        { s = 3, e = 3, old_s = 3, old_e = 3, kind = "change", new = { "changed3" }, old = { "line3" }, conflicted = false, mark_ids = {} }
      }

      -- User inserted 2 lines at line 2 (change_start=2, change_end=1 means insertion, new_line_count=2)
      -- Function signature: adjust_hunk_positions(st, change_start, change_end, new_line_count)
      state.adjust_hunk_positions(st, 2, 1, 2)

      -- Hunk should have shifted down by 2
      assert.equals(5, st.hunks[1].s)
      assert.equals(5, st.hunks[1].e)
    end)

    it("shifts hunks up when user deletes lines above", function()
      local st = utils.create_test_state({ "line1", "line2", "line3", "line4", "line5" }, { "line1", "line2", "line3", "line4", "line5" })

      -- Create a hunk at line 5
      st.hunks = {
        { s = 5, e = 5, old_s = 5, old_e = 5, kind = "change", new = { "changed5" }, old = { "line5" }, conflicted = false, mark_ids = {} }
      }

      -- User deleted 2 lines (lines 2-3) -> change_start=2, change_end=3, new_line_count=0
      state.adjust_hunk_positions(st, 2, 3, 0)

      -- Hunk should have shifted up by 2
      assert.equals(3, st.hunks[1].s)
      assert.equals(3, st.hunks[1].e)
    end)

    it("does not shift hunks above the change", function()
      local st = utils.create_test_state({ "line1", "line2", "line3", "line4" }, { "line1", "line2", "line3", "line4" })

      -- Create hunks at lines 1 and 4
      st.hunks = {
        { s = 1, e = 1, old_s = 1, old_e = 1, kind = "change", new = { "changed1" }, old = { "line1" }, conflicted = false, mark_ids = {} },
        { s = 4, e = 4, old_s = 4, old_e = 4, kind = "change", new = { "changed4" }, old = { "line4" }, conflicted = false, mark_ids = {} }
      }

      -- User inserted 2 lines at line 3 -> change_start=3, change_end=2, new_line_count=2
      state.adjust_hunk_positions(st, 3, 2, 2)

      -- First hunk should not move
      assert.equals(1, st.hunks[1].s)
      assert.equals(1, st.hunks[1].e)
      -- Second hunk should shift down
      assert.equals(6, st.hunks[2].s)
      assert.equals(6, st.hunks[2].e)
    end)

    it("adjusts multi-line hunks correctly", function()
      local st = utils.create_test_state({ "line1", "line2", "line3", "line4", "line5" }, { "line1", "line2", "line3", "line4", "line5" })

      -- Create a multi-line hunk at lines 4-5
      st.hunks = {
        { s = 4, e = 5, old_s = 4, old_e = 5, kind = "change", new = { "changed4", "changed5" }, old = { "line4", "line5" }, conflicted = false, mark_ids = {} }
      }

      -- User inserted 3 lines at line 2 -> change_start=2, change_end=1, new_line_count=3
      state.adjust_hunk_positions(st, 2, 1, 3)

      -- Both start and end should shift
      assert.equals(7, st.hunks[1].s)
      assert.equals(8, st.hunks[1].e)
    end)
  end)
end)
