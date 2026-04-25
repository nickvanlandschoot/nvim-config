local config = require("pi_core.config")
local util = require("pi_core.util")

local M = {}

local function current_file_path(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil
  end
  return path
end

function M.current_file_path(bufnr)
  return current_file_path(bufnr)
end

function M.get_visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local srow, scol = start_pos[2], start_pos[3]
  local erow, ecol = end_pos[2], end_pos[3]
  if srow == 0 or erow == 0 then
    return nil
  end
  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
  if #lines == 0 then
    return nil
  end
  lines[1] = string.sub(lines[1], scol)
  lines[#lines] = string.sub(lines[#lines], 1, ecol)
  return {
    text = table.concat(lines, "\n"),
    start_line = srow,
    end_line = erow,
  }
end

function M.file_context_bash(path)
  local cfg = config.get().context
  local p = util.shellescape(path)
  return string.format(
    "printf 'Neovim file context: %s\\n\\n' && sed -n '1,%dp' %s",
    path,
    cfg.max_file_lines,
    p
  )
end

function M.selection_context_bash(path, range)
  local cfg = config.get().context
  local start_line = math.max(1, range.start_line - cfg.max_selection_context_lines)
  local end_line = range.end_line + cfg.max_selection_context_lines
  local p = util.shellescape(path)
  return string.format(
    "printf 'Neovim selection context: %s (lines %d-%d)\\n\\n' && sed -n '%d,%dp' %s",
    path,
    range.start_line,
    range.end_line,
    start_line,
    end_line,
    p
  )
end

function M.path_context_bash(path)
  local cfg = config.get().context
  local p = util.shellescape(path)
  if util.is_dir(path) then
    return string.format(
      "printf 'Neovim directory context: %s\\n\\n' && find %s -maxdepth %d -type f | sort | head -n %d",
      path,
      p,
      cfg.max_directory_depth,
      cfg.max_directory_files
    )
  end
  return M.file_context_bash(path)
end

function M.prompt_label(bufnr, extra)
  local path = current_file_path(bufnr) or "[buffer]"
  if extra then
    return string.format("Ask pi about %s %s: ", vim.fn.fnamemodify(path, ":."), extra)
  end
  return string.format("Ask pi about %s: ", vim.fn.fnamemodify(path, ":."))
end

return M
