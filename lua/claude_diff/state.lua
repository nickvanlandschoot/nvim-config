-- State management for Claude diff plugin
--
-- RESPONSIBILITIES:
-- - Store and manage per-buffer state (baseline, hunks, user edits)
-- - Track user edit ranges for conflict detection
-- - Adjust hunk positions when buffer changes
-- - Load state from persistence on buffer open
local M = {}

-- Global state storage
M.state = {}      -- bufnr -> state table
M.project = { bufs = {} }

-- Utility functions for buffer operations
local function get_lines(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

-- Get or initialize buffer state
function M.buf_state(buf, try_load_persistence)
  if not M.state[buf] then
    local path = vim.api.nvim_buf_get_name(buf)
    local loaded_state = nil

    -- Try to load from persistence if requested
    if try_load_persistence and path ~= "" then
      local persistence = require("claude_diff.persistence")
      loaded_state = persistence.load_state(path)
    end

    -- Use loaded state or initialize fresh
    if loaded_state then
      M.state[buf] = {
        path = path,
        baseline = loaded_state.baseline,
        user_snapshot = { lines = get_lines(buf), tick = 0 },
        user_ranges = loaded_state.user_ranges or {},
        hunks = loaded_state.hunks or {},
      }
    else
      M.state[buf] = {
        path = path,
        baseline = { lines = get_lines(buf), tick = 0 },
        user_snapshot = { lines = get_lines(buf), tick = 0 },
        user_ranges = {},
        hunks = {},
      }
    end
  end

  M.project.bufs[buf] = true
  return M.state[buf]
end

-- Merge and coalesce user ranges
function M.add_user_range(st, s, e)
  local ranges = st.user_ranges
  local added = { s = s, e = e }
  local out = {}
  local placed = false

  for _, r in ipairs(ranges) do
    if not placed and e < r.s - 1 then
      table.insert(out, added)
      table.insert(out, r)
      placed = true
    elseif not placed and s > r.e + 1 then
      table.insert(out, r)
    else
      -- overlap or adjacent
      added.s = math.min(added.s, r.s)
      added.e = math.max(added.e, r.e)
    end
  end

  if not placed then
    table.insert(out, added)
  end

  st.user_ranges = out
end

-- Adjust hunk positions when lines are added/removed
function M.adjust_hunk_positions(st, change_start, change_end, new_line_count)
  local old_line_count = change_end - change_start + 1
  local delta = new_line_count - old_line_count

  if delta == 0 then
    return -- No position adjustment needed
  end

  for _, hunk in ipairs(st.hunks) do
    -- If hunk is entirely after the change, shift it
    if hunk.s > change_end then
      hunk.s = hunk.s + delta
      hunk.e = hunk.e + delta
    -- If hunk starts in the changed region but extends beyond
    elseif hunk.s >= change_start and hunk.s <= change_end and hunk.e > change_end then
      hunk.e = hunk.e + delta
    end
  end
end

-- Check if a range overlaps with a hunk
local function ranges_overlap(r1_start, r1_end, r2_start, r2_end)
  return not (r1_end < r2_start or r1_start > r2_end)
end

-- Track user edits by diffing snapshots and adjusting hunks
function M.track_user_edit(buf, immediate_update)
  local st = M.buf_state(buf)
  local prev = st.user_snapshot.lines
  local cur = get_lines(buf)

  -- Convert line arrays to strings for vim.diff
  local prev_str = table.concat(prev, "\n")
  local cur_str = table.concat(cur, "\n")

  local idx = vim.diff(prev_str, cur_str, {
    result_type = "indices",
    algorithm = "histogram",
    linematch = 120
  })

  -- Process each change
  for _, h in ipairs(idx or {}) do
    local s1, c1, s2, c2 = h[1], h[2], h[3], h[4]
    local old_start = s1
    local old_end = s1 + math.max(c1, 0) - 1
    local new_start = s2
    local new_end = s2 + math.max(c2, 0) - 1
    local new_line_count = math.max(c2, 0)

    -- Adjust positions of hunks after this change
    M.adjust_hunk_positions(st, old_start, old_end, new_line_count)

    -- Add to user ranges for conflict detection
    M.add_user_range(st, new_start, new_end)

    -- Mark overlapping hunks as conflicted
    for _, hunk in ipairs(st.hunks) do
      if ranges_overlap(new_start, new_end, hunk.s, hunk.e) then
        hunk.conflicted = true
      end
    end
  end

  -- Update snapshot
  st.user_snapshot.lines = cur
  st.user_snapshot.tick = st.user_snapshot.tick + 1

  return immediate_update and #idx > 0
end

-- Clean up state when buffer is deleted
function M.cleanup_buffer(buf)
  M.state[buf] = nil
  M.project.bufs[buf] = nil
end

return M
