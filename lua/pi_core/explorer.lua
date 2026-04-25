local util = require("pi_core.util")

local M = {}

local function oil_path()
  local ok, oil = pcall(require, "oil")
  if not ok then
    return nil
  end
  local entry = oil.get_cursor_entry and oil.get_cursor_entry() or nil
  local dir = oil.get_current_dir and oil.get_current_dir() or nil
  if entry and dir then
    return util.normalize_path(dir .. "/" .. entry.name)
  end
  if dir then
    return util.normalize_path(dir)
  end
  return nil
end

local function neotree_path()
  local ok, manager = pcall(require, "neo-tree.sources.manager")
  if not ok then
    return nil
  end
  local state = manager.get_state("filesystem")
  if not state or not state.tree then
    return nil
  end
  local node = state.tree:get_node()
  if node and node.path then
    return util.normalize_path(node.path)
  end
  return nil
end

local function netrw_path()
  if vim.bo.filetype ~= "netrw" then
    return nil
  end
  local dir = vim.b.netrw_curdir
  local line = vim.trim(vim.api.nvim_get_current_line())
  if not dir or line == "" then
    return util.normalize_path(dir)
  end
  line = line:gsub("/$", "")
  line = line:gsub("^./", "")
  return util.normalize_path(dir .. "/" .. line)
end

function M.current_path(arg)
  if arg and arg ~= "" then
    return util.normalize_path(arg)
  end

  local ft = vim.bo.filetype
  if ft == "oil" then
    return oil_path()
  elseif ft == "neo-tree" or ft == "neo-tree-popup" then
    return neotree_path()
  elseif ft == "netrw" then
    return netrw_path()
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path ~= "" then
    return util.normalize_path(path)
  end
  return nil
end

return M
