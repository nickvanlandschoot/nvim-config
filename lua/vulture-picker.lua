local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

-- Parse vulture output line
-- Format: filename:line: unused [type] 'name' (confidence X%)
local function parse_vulture_line(line)
  local filename, lnum, unused_type, name, confidence = line:match("^(.+):(%d+):%s+unused%s+(%w+)%s+'([^']+)'%s+%(confidence%s+(%d+)%%%)")

  if not filename then
    return nil
  end

  return {
    filename = filename,
    lnum = tonumber(lnum),
    col = 1,
    unused_type = unused_type,
    name = name,
    confidence = tonumber(confidence),
    text = line,
  }
end

-- Run vulture and get results
local function run_vulture(opts)
  opts = opts or {}
  local target_dir = opts.cwd or vim.fn.getcwd()

  -- Check if vulture is installed
  local vulture_check = vim.fn.system("command -v vulture")
  if vim.v.shell_error ~= 0 then
    vim.notify("Vulture is not installed. Install with: pip install vulture", vim.log.levels.ERROR)
    return {}
  end

  -- Run vulture command
  local cmd = string.format("vulture %s --min-confidence %d", target_dir, opts.min_confidence or 60)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 and output:match("No such file or directory") then
    vim.notify("Error running vulture: " .. output, vim.log.levels.ERROR)
    return {}
  end

  -- Parse output
  local results = {}
  for line in output:gmatch("[^\r\n]+") do
    local entry = parse_vulture_line(line)
    if entry then
      table.insert(results, entry)
    end
  end

  return results
end

-- Create entry maker for telescope
local function make_entry_maker()
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 8 },   -- unused type
      { width = 40 },  -- name
      { width = 6 },   -- confidence
      { remaining = true }, -- filename
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.unused_type, "TelescopeResultsComment" },
      { entry.name, "TelescopeResultsIdentifier" },
      { entry.confidence .. "%", "TelescopeResultsNumber" },
      { entry.filename .. ":" .. entry.lnum, "TelescopeResultsLineNr" },
    })
  end

  return function(entry)
    return {
      value = entry,
      display = make_display,
      ordinal = entry.filename .. " " .. entry.name .. " " .. entry.unused_type,
      filename = entry.filename,
      lnum = entry.lnum,
      col = entry.col,
      unused_type = entry.unused_type,
      name = entry.name,
      confidence = entry.confidence,
    }
  end
end

-- Main vulture picker function
function M.vulture_picker(opts)
  opts = opts or {}

  -- Get directory to scan (default to cwd)
  local target_dir = opts.cwd
  if not target_dir then
    target_dir = vim.fn.input({
      prompt = "Directory to scan (empty for current): ",
      default = vim.fn.getcwd(),
      completion = "dir",
    })
    if target_dir == "" then
      target_dir = vim.fn.getcwd()
    end
  end

  -- Get minimum confidence level
  local min_confidence = opts.min_confidence
  if not min_confidence then
    local confidence_input = vim.fn.input({
      prompt = "Minimum confidence % (default 60): ",
      default = "60",
    })
    min_confidence = tonumber(confidence_input) or 60
  end

  -- Show loading message
  vim.notify("Running vulture on " .. target_dir .. "...", vim.log.levels.INFO)

  -- Run vulture
  local results = run_vulture({
    cwd = target_dir,
    min_confidence = min_confidence,
  })

  if #results == 0 then
    vim.notify("No unused code found (or no Python files in directory)", vim.log.levels.INFO)
    return
  end

  vim.notify("Found " .. #results .. " unused code items", vim.log.levels.INFO)

  -- Create telescope picker
  pickers.new(opts, {
    prompt_title = "Vulture - Unused Python Code",
    finder = finders.new_table({
      results = results,
      entry_maker = make_entry_maker(),
    }),
    sorter = conf.generic_sorter(opts),
    previewer = conf.file_previewer(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit +" .. selection.lnum .. " " .. selection.filename)
        end
      end)

      -- Add custom mapping to filter by type
      map("i", "<C-t>", function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local type_filter = vim.fn.input("Filter by type (function/class/variable/import/attribute/property): ")
        if type_filter ~= "" then
          current_picker:set_prompt(type_filter)
        end
      end)

      return true
    end,
  }):find()
end

-- Quick picker with default settings
function M.vulture_quick()
  M.vulture_picker({
    cwd = vim.fn.getcwd(),
    min_confidence = 80,
  })
end

return M
