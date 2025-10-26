-- Actions for Claude diff plugin (accept, reject, navigate)
--
-- RESPONSIBILITIES:
-- - Execute user actions (accept/reject/navigate)
-- - Update buffer content when needed
-- - Coordinate baseline updates via diff module
-- - Recalculate hunks after modifications
-- - Trigger re-rendering and persistence
local M = {}

local diff = require("claude_diff.diff")
local render = require("claude_diff.render")
local persistence = require("claude_diff.persistence")

-- Utility to set buffer lines
local function set_lines(buf, s, e, lines)
  vim.api.nvim_buf_set_lines(buf, s - 1, e, false, lines)
end

-- Utility to get buffer lines
local function get_lines(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

-- Recalculate all hunks from baseline vs current buffer
-- This is needed after accept/reject operations change the buffer
local function recalculate_hunks(buf, st)
  local current_lines = get_lines(buf)
  local new_hunks = diff.build_hunks(st, current_lines)
  diff.exclude_user_overlaps(st, new_hunks)
  return st.hunks
end

-- Accept a hunk at the given index
function M.accept_hunk(buf, st, idx)
  local h = st.hunks[idx]
  if not h then
    vim.notify("No hunk found at index " .. idx, vim.log.levels.WARN)
    return
  end

  -- Step 1: Update baseline to include Claude's change
  diff.merge_hunk_to_baseline(st, h)

  -- Step 2: Buffer already has the change (no modification needed)

  -- Step 3: Recalculate all hunks (baseline vs current buffer)
  recalculate_hunks(buf, st)

  -- Step 4: Re-render and save state
  render.render_hunks(buf, st)
  persistence.save_state(st.path, st)

  -- Step 5: Write buffer to disk
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! write")
  end)
end

-- Reject a hunk at the given index
function M.reject_hunk(buf, st, idx)
  local h = st.hunks[idx]
  if not h then
    vim.notify("No hunk found at index " .. idx, vim.log.levels.WARN)
    return
  end

  -- Step 1: Revert buffer to baseline content
  set_lines(buf, h.s, h.e, h.old)

  -- Step 2: Baseline stays unchanged (already has content we want)

  -- Step 3: Recalculate all hunks (baseline vs current buffer)
  recalculate_hunks(buf, st)

  -- Step 4: Re-render and save state
  render.render_hunks(buf, st)
  persistence.save_state(st.path, st)

  -- Step 5: Write buffer to disk
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! write")
  end)
end

-- Accept all hunks
function M.accept_all(buf, st)
  if #st.hunks == 0 then
    vim.notify("No hunks to accept", vim.log.levels.INFO)
    return
  end

  -- Accept all hunks by setting baseline to current buffer
  st.baseline.lines = get_lines(buf)
  st.baseline.tick = st.baseline.tick + 1

  -- Clear all hunks since we accepted everything
  st.hunks = {}
  st.user_ranges = {}

  -- Re-render (will be empty) and save state
  render.render_hunks(buf, st)
  persistence.save_state(st.path, st)

  -- Write buffer to disk
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! write")
  end)

  vim.notify(string.format("Accepted all hunks"), vim.log.levels.INFO)
end

-- Reject all hunks
function M.reject_all(buf, st)
  if #st.hunks == 0 then
    vim.notify("No hunks to reject", vim.log.levels.INFO)
    return
  end

  local hunk_count = #st.hunks

  -- Revert entire buffer to baseline
  set_lines(buf, 1, vim.api.nvim_buf_line_count(buf), st.baseline.lines)

  -- Recalculate hunks (should be empty now since buffer matches baseline)
  recalculate_hunks(buf, st)

  -- Re-render and save state
  render.render_hunks(buf, st)
  persistence.save_state(st.path, st)

  -- Write buffer to disk
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! write")
  end)

  vim.notify(string.format("Rejected %d hunks", hunk_count), vim.log.levels.INFO)
end

-- Navigate to next hunk
function M.next_hunk(buf, st)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  for i, h in ipairs(st.hunks) do
    if h.s > cur then
      vim.api.nvim_win_set_cursor(0, { h.s, 0 })
      return i
    end
  end
  return nil
end

-- Navigate to previous hunk
function M.prev_hunk(buf, st)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  for i = #st.hunks, 1, -1 do
    local h = st.hunks[i]
    if h.e < cur then
      vim.api.nvim_win_set_cursor(0, { h.s, 0 })
      return i
    end
  end
  return nil
end

-- Find hunk at current cursor position
function M.hunk_at_cursor(st)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  for i, h in ipairs(st.hunks) do
    if h.s <= cur and cur <= h.e then
      return i
    end
  end
  return nil
end

-- Accept both changes (creates conflict markers for manual resolution)
function M.accept_both(buf, st, idx)
  local h = st.hunks[idx]
  if not h then
    return
  end

  -- Get current buffer content for this range (may include user edits if conflicted)
  local current_lines = vim.api.nvim_buf_get_lines(buf, h.s - 1, h.e, false)

  -- Build merged content with conflict markers
  -- Show: current buffer state vs what Claude wanted vs original baseline
  local merged = {}
  table.insert(merged, "<<<<<<< Current (your edits)")
  for _, line in ipairs(current_lines) do
    table.insert(merged, line)
  end
  table.insert(merged, "||||||| Baseline (original)")
  for _, line in ipairs(h.old) do
    table.insert(merged, line)
  end
  table.insert(merged, "=======")
  for _, line in ipairs(h.new) do
    table.insert(merged, line)
  end
  table.insert(merged, ">>>>>>> Claude (AI changes)")

  -- Write merged content to buffer
  set_lines(buf, h.s, h.e, merged)

  -- Update baseline with the merged content (using old_s and old_e)
  local base = st.baseline.lines
  local prefix = {}
  for i = 1, h.old_s - 1 do
    table.insert(prefix, base[i] or "")
  end

  local suffix = {}
  for i = h.old_e + 1, #base do
    table.insert(suffix, base[i] or "")
  end

  local new_baseline = {}
  for _, ln in ipairs(prefix) do
    table.insert(new_baseline, ln)
  end
  for _, ln in ipairs(merged) do
    table.insert(new_baseline, ln)
  end
  for _, ln in ipairs(suffix) do
    table.insert(new_baseline, ln)
  end

  st.baseline.lines = new_baseline
  st.baseline.tick = st.baseline.tick + 1

  -- Remove the hunk as it's now resolved
  table.remove(st.hunks, idx)
  render.render_hunks(buf, st)
  persistence.save_state(st.path, st)

  -- Notify user
  vim.notify("Created conflict markers for manual resolution", vim.log.levels.INFO)
end

-- Accept all hunks including conflicted ones
function M.accept_all_force(buf, st)
  for i = #st.hunks, 1, -1 do
    M.accept_hunk(buf, st, i)
  end
  st.baseline.lines = get_lines(buf)
end

return M
