-- Diff and hunk extraction logic for Claude diff plugin
--
-- RESPONSIBILITIES:
-- - Calculate diffs between baseline and current buffer
-- - Build hunk data structures with positions
-- - Update baseline after accept/reject operations
-- - No buffer modifications, no rendering
local M = {}

-- Utility to get buffer lines
local function get_lines(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

-- Build hunks by comparing baseline to new lines
function M.build_hunks(st, new_lines)
  local old = st.baseline.lines

  -- Convert line arrays to strings for vim.diff
  local old_str = table.concat(old, "\n")
  local new_str = table.concat(new_lines, "\n")

  local idx = vim.diff(old_str, new_str, {
    result_type = "indices",
    algorithm = "histogram",
    linematch = 120
  }) or {}

  local hunks = {}
  for _, h in ipairs(idx) do
    local s1, c1, s2, c2 = h[1], h[2], h[3], h[4]

    -- vim.diff returns: [old_start, old_count, new_start, new_count]
    -- For additions: old_count=0, position is "after old_start"
    -- For deletions: new_count=0, position is "after new_start"

    local kind = (c1 == 0 and c2 > 0) and "add"
      or (c1 > 0 and c2 == 0) and "del"
      or "change"

    -- Calculate positions (1-based line numbers)
    local old_s, old_e, new_s, new_e

    if kind == "add" then
      -- Addition: insert happens at s1+1 in baseline
      old_s = s1 + 1
      old_e = s1  -- old_e < old_s for zero-length range
      new_s = s2
      new_e = s2 + c2 - 1
    elseif kind == "del" then
      -- Deletion: remove from s1 to s1+c1-1 in baseline
      old_s = s1
      old_e = s1 + c1 - 1
      new_s = s2 + 1  -- position in new where deletion "would be"
      new_e = s2  -- new_e < new_s for zero-length range
    else
      -- Change: both ranges exist
      old_s = s1
      old_e = s1 + c1 - 1
      new_s = s2
      new_e = s2 + c2 - 1
    end

    -- Extract line content
    local old_chunk = {}
    for i = old_s, old_e do
      table.insert(old_chunk, old[i] or "")
    end

    local new_chunk = {}
    for i = new_s, new_e do
      table.insert(new_chunk, new_lines[i] or "")
    end

    table.insert(hunks, {
      s = new_s,      -- start line in current buffer
      e = new_e,      -- end line in current buffer
      old_s = old_s,  -- start line in baseline
      old_e = old_e,  -- end line in baseline
      old = old_chunk,
      new = new_chunk,
      kind = kind,
      conflicted = false,
      mark_ids = {}
    })
  end

  return hunks
end

-- Exclude hunks that overlap with user-edited ranges
function M.exclude_user_overlaps(st, hunks)
  local ranges = st.user_ranges
  local filtered = {}

  for _, h in ipairs(hunks) do
    local overlap = false
    for _, r in ipairs(ranges) do
      if not (h.e < r.s or h.s > r.e) then
        overlap = true
        break
      end
    end

    if overlap then
      h.conflicted = true
    end
    table.insert(filtered, h)
  end

  st.hunks = filtered
end

-- Process external change: build hunks and exclude overlaps
function M.process_external_change(buf, st)
  local cur = get_lines(buf)
  local hunks = M.build_hunks(st, cur)
  M.exclude_user_overlaps(st, hunks)
  return st.hunks
end

-- Reset baseline to current buffer state
function M.reset_baseline(buf, st)
  st.baseline.lines = get_lines(buf)
  st.baseline.tick = st.baseline.tick + 1
  st.user_snapshot.lines = get_lines(buf)
  st.user_ranges = {}
  st.hunks = {}
end

-- Update baseline by accepting a hunk (incorporate Claude's changes into baseline)
function M.merge_hunk_to_baseline(st, hunk)
  -- When accepting, we update the baseline to include Claude's change
  -- Use old_s and old_e (positions in baseline) to know where to update
  local base = st.baseline.lines
  local prefix = {}

  -- Lines before the change in baseline
  for i = 1, hunk.old_s - 1 do
    table.insert(prefix, base[i] or "")
  end

  -- Lines after the change in baseline
  local suffix = {}
  for i = hunk.old_e + 1, #base do
    table.insert(suffix, base[i] or "")
  end

  -- Build new baseline: prefix + new content + suffix
  local merged = {}
  for _, ln in ipairs(prefix) do
    table.insert(merged, ln)
  end
  for _, ln in ipairs(hunk.new) do
    table.insert(merged, ln)
  end
  for _, ln in ipairs(suffix) do
    table.insert(merged, ln)
  end

  st.baseline.lines = merged
  st.baseline.tick = st.baseline.tick + 1
end

-- Reject a hunk - baseline doesn't change (it already has the content we want)
-- The caller should update the buffer to match baseline
function M.reject_hunk_from_baseline(st, hunk)
  -- When rejecting, baseline stays the same (it has the content we want to keep)
  -- The buffer will be reverted by the caller
  -- This function is now a no-op, but kept for API consistency
end

return M
