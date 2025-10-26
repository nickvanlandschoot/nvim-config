-- Tests for accept/reject actions
describe("Claude Diff - Actions", function()
  local diff = require("claude_diff.diff")
  local actions = require("claude_diff.actions")
  local utils = require("tests.claude_diff.test_utils")

  describe("accept_hunk", function()
    it("accepts a single addition", function()
      local baseline = { "line1", "line2", "line3" }
      local current = { "line1", "line2", "added", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      -- Build hunks
      st.hunks = diff.build_hunks(st, current)
      assert.equals(1, #st.hunks)

      -- Accept the hunk
      actions.accept_hunk(buf, st, 1)

      -- Baseline should now match buffer
      local expected_baseline = { "line1", "line2", "added", "line3" }
      assert.is_true(utils.lines_equal(expected_baseline, st.baseline.lines))

      -- Buffer should be unchanged
      local buf_lines = utils.get_buffer_lines(buf)
      assert.is_true(utils.lines_equal(current, buf_lines))

      -- Hunks should be empty (nothing left to diff)
      assert.equals(0, #st.hunks)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("accepts a single deletion", function()
      local baseline = { "line1", "line2", "todelete", "line3" }
      local current = { "line1", "line2", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      -- Build hunks
      st.hunks = diff.build_hunks(st, current)
      assert.equals(1, #st.hunks)
      assert.equals("del", st.hunks[1].kind)

      -- Accept the deletion
      actions.accept_hunk(buf, st, 1)

      -- Baseline should now match buffer (deletion accepted)
      local expected_baseline = { "line1", "line2", "line3" }
      assert.is_true(utils.lines_equal(expected_baseline, st.baseline.lines))

      -- Hunks should be empty
      assert.equals(0, #st.hunks)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("accepts a change", function()
      local baseline = { "line1", "original", "line3" }
      local current = { "line1", "modified", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      st.hunks = diff.build_hunks(st, current)
      actions.accept_hunk(buf, st, 1)

      local expected_baseline = { "line1", "modified", "line3" }
      assert.is_true(utils.lines_equal(expected_baseline, st.baseline.lines))
      assert.equals(0, #st.hunks)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("correctly handles multiple hunks - accept first", function()
      local baseline = { "line1", "line2", "line3", "line4" }
      local current = { "line1", "changed2", "line3", "added", "line4" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      st.hunks = diff.build_hunks(st, current)
      assert.equals(2, #st.hunks)

      -- Accept first hunk (the change)
      actions.accept_hunk(buf, st, 1)

      -- Should have 1 hunk left (the addition)
      assert.equals(1, #st.hunks)
      assert.equals("add", st.hunks[1].kind)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("reject_hunk", function()
    it("rejects a single addition", function()
      local baseline = { "line1", "line2", "line3" }
      local current = { "line1", "line2", "added", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      st.hunks = diff.build_hunks(st, current)
      actions.reject_hunk(buf, st, 1)

      -- Baseline unchanged
      assert.is_true(utils.lines_equal(baseline, st.baseline.lines))

      -- Buffer should be reverted to baseline
      local buf_lines = utils.get_buffer_lines(buf)
      assert.is_true(utils.lines_equal(baseline, buf_lines))

      -- Hunks should be empty
      assert.equals(0, #st.hunks)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("rejects a change", function()
      local baseline = { "line1", "original", "line3" }
      local current = { "line1", "modified", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      st.hunks = diff.build_hunks(st, current)
      actions.reject_hunk(buf, st, 1)

      -- Baseline unchanged
      assert.is_true(utils.lines_equal(baseline, st.baseline.lines))

      -- Buffer reverted
      local buf_lines = utils.get_buffer_lines(buf)
      assert.is_true(utils.lines_equal(baseline, buf_lines))

      assert.equals(0, #st.hunks)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("accept_all / reject_all", function()
    it("accepts all hunks", function()
      local baseline = { "line1", "line2", "line3" }
      local current = { "line1", "changed2", "added", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      st.hunks = diff.build_hunks(st, current)
      local initial_count = #st.hunks
      assert.is_true(initial_count > 0)

      actions.accept_all(buf, st)

      -- Baseline should match current
      assert.is_true(utils.lines_equal(current, st.baseline.lines))
      assert.equals(0, #st.hunks)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("rejects all hunks", function()
      local baseline = { "line1", "line2", "line3" }
      local current = { "line1", "changed2", "added", "line3" }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)

      st.hunks = diff.build_hunks(st, current)
      actions.reject_all(buf, st)

      -- Baseline unchanged
      assert.is_true(utils.lines_equal(baseline, st.baseline.lines))

      -- Buffer reverted
      local buf_lines = utils.get_buffer_lines(buf)
      assert.is_true(utils.lines_equal(baseline, buf_lines))

      assert.equals(0, #st.hunks)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)
end)
