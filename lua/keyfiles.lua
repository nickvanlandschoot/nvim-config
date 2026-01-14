local M = {}

-- Storage file for persisting key files
local data_path = vim.fn.stdpath("data") .. "/keyfiles.json"

-- In-memory list of key files
M.files = {}

-- Load key files from disk
local function load_files()
  local file = io.open(data_path, "r")
  if file then
    local content = file:read("*all")
    file:close()
    local ok, decoded = pcall(vim.json.decode, content)
    if ok and type(decoded) == "table" then
      M.files = decoded
    end
  end
end

-- Save key files to disk
local function save_files()
  local file = io.open(data_path, "w")
  if file then
    file:write(vim.json.encode(M.files))
    file:close()
  end
end

-- Add a file to key files
function M.add(filepath)
  filepath = vim.fn.fnamemodify(filepath, ":p") -- Get absolute path

  -- Check if already in list
  for _, file in ipairs(M.files) do
    if file == filepath then
      vim.notify("File already in key files", vim.log.levels.INFO)
      return
    end
  end

  table.insert(M.files, filepath)
  save_files()
  vim.notify("Added to key files: " .. vim.fn.fnamemodify(filepath, ":~:."), vim.log.levels.INFO)
end

-- Remove a file from key files
function M.remove(filepath)
  filepath = vim.fn.fnamemodify(filepath, ":p")

  for i, file in ipairs(M.files) do
    if file == filepath then
      table.remove(M.files, i)
      save_files()
      vim.notify("Removed from key files: " .. vim.fn.fnamemodify(filepath, ":~:."), vim.log.levels.INFO)
      return
    end
  end

  vim.notify("File not in key files", vim.log.levels.WARN)
end

-- Toggle current file in key files
function M.toggle_current()
  local filepath = vim.api.nvim_buf_get_name(0)

  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  filepath = vim.fn.fnamemodify(filepath, ":p")

  -- Check if file is in list
  for i, file in ipairs(M.files) do
    if file == filepath then
      table.remove(M.files, i)
      save_files()
      vim.notify("Removed from key files", vim.log.levels.INFO)
      return
    end
  end

  -- Not in list, add it
  table.insert(M.files, filepath)
  save_files()
  vim.notify("Added to key files", vim.log.levels.INFO)
end

-- Clear all key files
function M.clear()
  M.files = {}
  save_files()
  vim.notify("Cleared all key files", vim.log.levels.INFO)
end

-- Open telescope picker with key files
function M.picker()
  if #M.files == 0 then
    vim.notify("No key files added yet. Use <leader>fK to add current file.", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Filter out files that don't exist anymore
  local valid_files = {}
  for _, file in ipairs(M.files) do
    if vim.fn.filereadable(file) == 1 then
      table.insert(valid_files, file)
    end
  end

  -- Update the list if files were removed
  if #valid_files < #M.files then
    M.files = valid_files
    save_files()
  end

  pickers.new({}, {
    prompt_title = "Key Files",
    finder = finders.new_table({
      results = M.files,
      entry_maker = function(entry)
        local display = vim.fn.fnamemodify(entry, ":~:.")
        return {
          value = entry,
          display = display,
          ordinal = display,
          path = entry,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
      end)

      -- Add mapping to remove file from list
      map("i", "<C-d>", function()
        local selection = action_state.get_selected_entry()
        M.remove(selection.value)
        actions.close(prompt_bufnr)
        -- Reopen picker to show updated list
        vim.schedule(function()
          M.picker()
        end)
      end)

      map("n", "dd", function()
        local selection = action_state.get_selected_entry()
        M.remove(selection.value)
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.picker()
        end)
      end)

      return true
    end,
  }):find()
end

-- Initialize on first load
load_files()

return M
