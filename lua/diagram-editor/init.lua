local M = {}

local NAMESPACE = vim.api.nvim_create_namespace("diagram_editor_conceal")
local METADATA_PREFIX = "%%"

--- Check if a line is a metadata line (avoid requiring serializer at top level).
--- @param line string
--- @return boolean
local function is_metadata_line(line)
  return vim.startswith(line, METADATA_PREFIX)
end

--- Apply extmark concealment to all %% metadata lines in the buffer.
--- @param bufnr number
function M.conceal_metadata(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, NAMESPACE, 0, -1)

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for i = 0, line_count - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
    if line and is_metadata_line(line) then
      vim.api.nvim_buf_set_extmark(bufnr, NAMESPACE, i, 0, {
        end_row = i,
        end_col = #line,
        conceal = "",
        hl_group = "Conceal",
      })
    end
  end
end

--- Edit an existing diagram at the cursor position.
local function edit_diagram()
  -- Force fresh modules to avoid stale cache
  package.loaded["diagram-editor.parser"] = nil
  package.loaded["diagram-editor.serializer"] = nil
  package.loaded["diagram-editor.renderer"] = nil
  package.loaded["diagram-editor.menu"] = nil
  package.loaded["diagram-editor.model"] = nil

  local parser = require("diagram-editor.parser")
  local menu = require("diagram-editor.menu")

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1] - 1 -- convert to 0-based

  local region = parser.detect_region(bufnr, cursor_line)
  if not region then
    vim.notify("diagram-editor: cursor is not inside a [[[diagram:...]]] region", vim.log.levels.WARN)
    return
  end

  local tree = parser.extract_metadata(bufnr, region)
  if not tree then
    vim.notify("diagram-editor: no metadata found in diagram region", vim.log.levels.ERROR)
    return
  end

  menu.open(tree, bufnr, region)
end

--- Create a new diagram at the cursor position.
local function new_diagram()
  vim.ui.input({ prompt = "Diagram name:" }, function(name)
    if not name or name == "" then
      return
    end

    vim.schedule(function()
      local model = require("diagram-editor.model")
      local serializer = require("diagram-editor.serializer")
      local renderer = require("diagram-editor.renderer")
      local menu = require("diagram-editor.menu")

      local bufnr = vim.api.nvim_get_current_buf()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local cursor_line = cursor[1] - 1 -- 0-based

      local tree = model.create_default_tree(name)
      local metadata_line = serializer.encode(tree)
      local ascii_lines = renderer.render_to_lines(tree)

      local insert_lines = {}
      insert_lines[#insert_lines + 1] = "[[[diagram:" .. name
      insert_lines[#insert_lines + 1] = metadata_line
      for _, line in ipairs(ascii_lines) do
        insert_lines[#insert_lines + 1] = line
      end
      insert_lines[#insert_lines + 1] = "]]]"

      vim.api.nvim_buf_set_lines(bufnr, cursor_line + 1, cursor_line + 1, false, insert_lines)

      local region = {
        start_line = cursor_line + 1,
        end_line = cursor_line + 1 + #insert_lines - 1,
        name = name,
      }

      M.conceal_metadata(bufnr)
      menu.open(tree, bufnr, region)
    end)
  end)
end

--- Public entry points (called from lazy.nvim keys spec).
M.edit = edit_diagram
M.new = new_diagram

--- Register conceal autocmd. Called once on first require.
local group = vim.api.nvim_create_augroup("DiagramEditorConceal", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufWritePost" }, {
  group = group,
  callback = function(args)
    local bufnr = args.buf
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    for i = 0, line_count - 1 do
      local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
      if line and is_metadata_line(line) then
        M.conceal_metadata(bufnr)
        vim.api.nvim_set_option_value("conceallevel", 2, { buf = bufnr })
        break
      end
    end
  end,
})

return M
