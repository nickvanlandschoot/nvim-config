-- Test utilities for Claude diff plugin
local M = {}

-- Create a test buffer with given lines
function M.create_test_buffer(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return buf
end

-- Create a test state with baseline and hunks
function M.create_test_state(baseline_lines, current_lines)
  local state = {
    path = "/test/file.lua",
    baseline = { lines = baseline_lines, tick = 0 },
    user_snapshot = { lines = current_lines, tick = 0 },
    user_ranges = {},
    hunks = {},
  }
  return state
end

-- Helper to print buffer contents
function M.print_buffer(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  print("Buffer contents:")
  for i, line in ipairs(lines) do
    print(string.format("%d: %s", i, line))
  end
end

-- Helper to print state
function M.print_state(st)
  print("Baseline:")
  for i, line in ipairs(st.baseline.lines) do
    print(string.format("%d: %s", i, line))
  end
  print("\nHunks:")
  for i, h in ipairs(st.hunks) do
    print(string.format(
      "Hunk %d: lines %d-%d (baseline %d-%d), kind=%s, old=%d lines, new=%d lines",
      i, h.s, h.e, h.old_s, h.old_e, h.kind, #h.old, #h.new
    ))
  end
end

-- Compare two line arrays
function M.lines_equal(lines1, lines2)
  if #lines1 ~= #lines2 then
    print(string.format("Length mismatch: %d vs %d", #lines1, #lines2))
    return false
  end
  for i = 1, #lines1 do
    if lines1[i] ~= lines2[i] then
      print(string.format("Line %d mismatch: '%s' vs '%s'", i, lines1[i] or "nil", lines2[i] or "nil"))
      return false
    end
  end
  return true
end

-- Get buffer lines
function M.get_buffer_lines(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

return M
