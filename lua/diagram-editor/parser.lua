local serializer = require("diagram-editor.serializer")
local renderer = require("diagram-editor.renderer")

local M = {}

--- Check if a line is an opening delimiter. Returns the name or nil.
--- @param line string
--- @return string|nil
local function match_open(line)
  local trimmed = vim.trim(line)
  return trimmed:match("^%[%[%[diagram:(.+)")
end

--- Check if a line contains a closing delimiter.
--- @param line string
--- @return boolean
local function match_close(line)
  local trimmed = vim.trim(line)
  -- match exactly "]]]" or ending with "]]]" (recovery for glued delimiters)
  return trimmed == "]]]" or trimmed:match("%]%]%]$") ~= nil
end

--- Detect the diagram region surrounding a cursor line.
--- Scans backward for `[[[diagram:name` and forward for `]]]`.
--- @param bufnr number
--- @param cursor_line number 0-based line number
--- @return table|nil { start_line: number, end_line: number, name: string } (0-based)
function M.detect_region(bufnr, cursor_line)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  -- scan backward for opening delimiter
  local start_line, name
  for i = cursor_line, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
    if line then
      local m = match_open(line)
      if m then
        start_line = i
        name = m
        break
      end
      if match_close(line) and i ~= cursor_line then
        return nil
      end
    end
  end

  if not start_line then
    return nil
  end

  -- scan forward for closing delimiter
  local end_line
  for i = start_line + 1, line_count - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
    if line then
      if match_close(line) then
        end_line = i
        break
      end
      if match_open(line) then
        return nil
      end
    end
  end

  if not end_line then
    return nil
  end

  if cursor_line < start_line or cursor_line > end_line then
    return nil
  end

  return { start_line = start_line, end_line = end_line, name = name }
end

--- Extract the serialized tree from the metadata line within a region.
--- @param bufnr number
--- @param region table { start_line, end_line }
--- @return table|nil decoded tree
function M.extract_metadata(bufnr, region)
  -- scan all lines between opening and closing delimiters
  local lines = vim.api.nvim_buf_get_lines(bufnr, region.start_line + 1, region.end_line + 1, false)
  for _, line in ipairs(lines) do
    if serializer.is_metadata_line(line) then
      return serializer.decode(line)
    end
  end
  return nil
end

--- Extract the diagram name from the opening delimiter.
--- @param bufnr number
--- @param region table { start_line }
--- @return string
function M.extract_name(bufnr, region)
  local line = vim.api.nvim_buf_get_lines(bufnr, region.start_line, region.start_line + 1, false)[1]
  if line then
    return match_open(line) or ""
  end
  return ""
end

--- Write a tree back to the buffer: serialize metadata + render ASCII.
--- Replaces everything between (and including) the delimiters, then re-inserts them.
--- @param bufnr number
--- @param region table { start_line, end_line }
--- @param tree table root node
function M.write_region(bufnr, region, tree)
  local new_lines = {}

  -- opening delimiter
  new_lines[#new_lines + 1] = "[[[diagram:" .. (region.name or "diagram")

  -- metadata line
  new_lines[#new_lines + 1] = serializer.encode(tree)

  -- rendered ASCII
  local ascii_lines = renderer.render_to_lines(tree)
  for _, line in ipairs(ascii_lines) do
    new_lines[#new_lines + 1] = line
  end

  -- closing delimiter
  new_lines[#new_lines + 1] = "]]]"

  -- replace the entire region (inclusive of both delimiters)
  vim.api.nvim_buf_set_lines(bufnr, region.start_line, region.end_line + 1, false, new_lines)

  -- update region to reflect new content
  region.end_line = region.start_line + #new_lines - 1
end

return M
