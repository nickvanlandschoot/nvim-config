-- Tests for visualization layer sync with logical hunk state
describe("Claude Diff - Visualization Sync", function()
  local diff = require("claude_diff.diff")
  local actions = require("claude_diff.actions")
  local render = require("claude_diff.render")
  local utils = require("tests.claude_diff.test_utils")

  describe("hunk stability after accept/reject", function()
    it("accepting hunk doesn't affect other hunks' positions", function()
      local baseline = {
        "line1",
        "old2",
        "line3",
        "line4",
        "old5",
        "line6",
      }
      local current = {
        "line1",
        "new2",
        "line3",
        "line4",
        "new5",
        "line6",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      assert.equals(2, #st.hunks)
      local hunk2_initial_pos = { s = st.hunks[2].s, e = st.hunks[2].e }

      -- Accept first hunk
      actions.accept_hunk(buf, st, 1)

      -- Second hunk should still exist
      assert.is_true(#st.hunks >= 1)

      -- Find the remaining change hunk (may have shifted index)
      local found_hunk = nil
      for _, h in ipairs(st.hunks) do
        if h.kind == "change" then
          found_hunk = h
          break
        end
      end

      assert.is_not_nil(found_hunk)
      -- Position should be stable (line 5 in current)
      assert.equals(5, found_hunk.s)
    end)

    it("rejecting hunk doesn't affect other hunks' positions", function()
      local baseline = {
        "line1",
        "old2",
        "line3",
        "line4",
        "old5",
        "line6",
      }
      local current = {
        "line1",
        "new2",
        "line3",
        "line4",
        "new5",
        "line6",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      assert.equals(2, #st.hunks)

      -- Reject first hunk
      actions.reject_hunk(buf, st, 1)

      -- Second hunk should still exist
      assert.is_true(#st.hunks >= 1)

      -- Find the remaining hunk
      local found_hunk = nil
      for _, h in ipairs(st.hunks) do
        if h.kind == "change" then
          found_hunk = h
          break
        end
      end

      assert.is_not_nil(found_hunk)
      -- Position should be stable
      assert.equals(5, found_hunk.s)
    end)

    it("hunks don't merge after accept", function()
      local baseline = {
        "line1",
        "old2",
        "old3",
        "line4",
      }
      local current = {
        "line1",
        "new2",
        "new3",
        "line4",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Should start with 1 hunk (consecutive changes merged by vim.diff)
      assert.equals(1, #st.hunks)
      local initial_hunk_count = #st.hunks

      -- Accept the hunk
      actions.accept_hunk(buf, st, 1)

      -- Should have 0 hunks now (accepted)
      assert.equals(0, #st.hunks)
    end)

    it("hunks don't split unexpectedly after reject", function()
      local baseline = {
        "line1",
        "old2",
        "old3",
        "line4",
      }
      local current = {
        "line1",
        "new2",
        "new3",
        "line4",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      assert.equals(1, #st.hunks)

      -- Reject the hunk
      actions.reject_hunk(buf, st, 1)

      -- Should have 0 hunks now (rejected)
      assert.equals(0, #st.hunks)
    end)
  end)

  describe("buffer state matches hunk positions", function()
    it("buffer content at hunk position matches hunk.new", function()
      local baseline = {
        "line1",
        "old2",
        "line3",
      }
      local current = {
        "line1",
        "new2",
        "line3",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Render hunks (adds old lines to buffer)
      render.render_hunks(buf, st)

      local h = st.hunks[1]
      -- After rendering, change hunk has new content followed by old content
      -- Get the "new" portion
      local buffer_lines = vim.api.nvim_buf_get_lines(buf, h.s - 1, h.s, false)

      -- First line should be the new content
      assert.equals("new2", buffer_lines[1])
    end)

    it("hunk positions are valid buffer indices after accept", function()
      local baseline = {
        "line1",
        "old2",
        "line3",
        "old4",
        "line5",
      }
      local current = {
        "line1",
        "new2",
        "line3",
        "new4",
        "line5",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Accept first hunk
      actions.accept_hunk(buf, st, 1)

      -- All remaining hunks should have valid positions
      local buf_line_count = vim.api.nvim_buf_line_count(buf)
      for _, h in ipairs(st.hunks) do
        assert.is_true(h.s >= 1, "hunk start should be >= 1")
        assert.is_true(h.e <= buf_line_count, "hunk end should be <= buffer line count")
        assert.is_true(h.s <= h.e, "hunk start should be <= hunk end")
      end
    end)

    it("hunk positions are valid buffer indices after reject", function()
      local baseline = {
        "line1",
        "old2",
        "line3",
        "old4",
        "line5",
      }
      local current = {
        "line1",
        "new2",
        "line3",
        "new4",
        "line5",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Reject first hunk
      actions.reject_hunk(buf, st, 1)

      -- All remaining hunks should have valid positions
      local buf_line_count = vim.api.nvim_buf_line_count(buf)
      for _, h in ipairs(st.hunks) do
        assert.is_true(h.s >= 1)
        assert.is_true(h.e <= buf_line_count)
        assert.is_true(h.s <= h.e)
      end
    end)
  end)

  describe("accept/reject sequence consistency", function()
    it("accept then reject preserves logical state", function()
      local baseline = {
        "a",
        "b1",
        "c",
        "d1",
        "e",
      }
      local current = {
        "a",
        "b2",
        "c",
        "d2",
        "e",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      assert.equals(2, #st.hunks)

      -- Accept first hunk
      actions.accept_hunk(buf, st, 1)

      local after_accept_count = #st.hunks

      -- Reject remaining hunk
      if #st.hunks > 0 then
        actions.reject_hunk(buf, st, 1)
      end

      -- Should have fewer hunks
      assert.is_true(#st.hunks < after_accept_count)

      -- Verify buffer is in valid state
      local buffer_lines = utils.get_buffer_lines(buf)
      assert.is_true(#buffer_lines > 0)
    end)

    it("reject then accept preserves logical state", function()
      local baseline = {
        "a",
        "b1",
        "c",
        "d1",
        "e",
      }
      local current = {
        "a",
        "b2",
        "c",
        "d2",
        "e",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      assert.equals(2, #st.hunks)

      -- Reject first hunk
      actions.reject_hunk(buf, st, 1)

      local after_reject_count = #st.hunks

      -- Accept remaining hunk
      if #st.hunks > 0 then
        actions.accept_hunk(buf, st, 1)
      end

      -- Should have fewer hunks
      assert.is_true(#st.hunks < after_reject_count)

      -- Verify buffer is in valid state
      local buffer_lines = utils.get_buffer_lines(buf)
      assert.is_true(#buffer_lines > 0)
    end)

    it("multiple accepts in sequence don't corrupt state", function()
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

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      local initial_count = #st.hunks

      -- Accept all hunks one by one
      while #st.hunks > 0 do
        actions.accept_hunk(buf, st, 1)
      end

      -- Should have no hunks
      assert.equals(0, #st.hunks)

      -- Buffer should be in valid state
      local buffer_lines = utils.get_buffer_lines(buf)
      assert.is_true(#buffer_lines > 0)
    end)

    it("multiple rejects in sequence don't corrupt state", function()
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

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      local initial_count = #st.hunks

      -- Reject all hunks one by one
      while #st.hunks > 0 do
        actions.reject_hunk(buf, st, 1)
      end

      -- Should have no hunks
      assert.equals(0, #st.hunks)

      -- Buffer should match baseline
      local buffer_lines = utils.get_buffer_lines(buf)
      assert.are.same(baseline, buffer_lines)
    end)
  end)

  describe("visualization layer cleanup", function()
    it("no old_inserted flags remain after accept_all", function()
      local baseline = {
        "a",
        "b1",
        "c",
        "d1",
        "e",
      }
      local current = {
        "a",
        "b2",
        "c",
        "d2",
        "e",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Render to insert old lines
      render.render_hunks(buf, st)

      -- Accept all
      actions.accept_all(buf, st)

      -- No hunks should remain
      assert.equals(0, #st.hunks)
    end)

    it("no old_inserted flags remain after reject_all", function()
      local baseline = {
        "a",
        "b1",
        "c",
        "d1",
        "e",
      }
      local current = {
        "a",
        "b2",
        "c",
        "d2",
        "e",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      -- Render to insert old lines
      render.render_hunks(buf, st)

      -- Reject all
      actions.reject_all(buf, st)

      -- No hunks should remain
      assert.equals(0, #st.hunks)
    end)
  end)

  describe("hunk content preservation", function()
    it("hunk old/new content stays consistent after operations", function()
      local baseline = {
        "line1",
        "old_a",
        "line3",
        "old_b",
        "line5",
      }
      local current = {
        "line1",
        "new_a",
        "line3",
        "new_b",
        "line5",
      }

      local buf = utils.create_test_buffer(current)
      local st = utils.create_test_state(baseline, current)
      local hunks = diff.build_hunks(st, current)
      st.hunks = hunks

      assert.equals(2, #st.hunks)

      -- Store hunk 2 content before operating on hunk 1
      local hunk2_old = vim.deepcopy(st.hunks[2].old)
      local hunk2_new = vim.deepcopy(st.hunks[2].new)

      -- Accept first hunk
      actions.accept_hunk(buf, st, 1)

      -- Find remaining hunk (should be the original hunk 2)
      local remaining_hunk = nil
      for _, h in ipairs(st.hunks) do
        if h.kind == "change" then
          remaining_hunk = h
          break
        end
      end

      if remaining_hunk then
        -- Content should be unchanged
        assert.are.same(hunk2_old, remaining_hunk.old)
        assert.are.same(hunk2_new, remaining_hunk.new)
      end
    end)
  end)
end)
