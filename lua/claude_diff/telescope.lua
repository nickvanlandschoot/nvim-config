-- Telescope picker integrations for Claude diff plugin
--
-- RESPONSIBILITIES:
-- - Create Telescope pickers for hunks (buffer and project-wide)
-- - Build diff previews
-- - Handle picker actions (jump, accept, reject)
-- - No direct state modification (delegates to actions module)
local M = {}

local state_module = require("claude_diff.state")
local actions_module = require("claude_diff.actions")

-- Create a previewer that shows the hunk diff
local function create_diff_previewer(hunks_list, file_path)
  local previewers = require("telescope.previewers")
  local putils = require("telescope.previewers.utils")

  return previewers.new_buffer_previewer({
    title = "Diff Preview",
    define_preview = function(self, entry, status)
      local hunk = hunks_list[entry.index]
      if not hunk then
        return
      end

      -- Build diff content
      local lines = {}
      table.insert(lines, string.format("--- Original (lines %d-%d)", hunk.s, hunk.e))
      table.insert(lines, string.format("+++ Claude's changes (lines %d-%d)", hunk.s, hunk.e))
      table.insert(lines, "")

      -- Show old content
      if #hunk.old > 0 then
        for _, line in ipairs(hunk.old) do
          table.insert(lines, "- " .. line)
        end
      else
        table.insert(lines, "- (empty - deletion)")
      end

      table.insert(lines, "")

      -- Show new content
      if #hunk.new > 0 then
        for _, line in ipairs(hunk.new) do
          table.insert(lines, "+ " .. line)
        end
      else
        table.insert(lines, "+ (empty - addition)")
      end

      -- Set buffer content
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

      -- Apply diff syntax highlighting
      putils.highlighter(self.state.bufnr, "diff")
    end,
  })
end

-- Create a previewer for project picker with index lookup
local function create_project_diff_previewer(index_map)
  local previewers = require("telescope.previewers")
  local putils = require("telescope.previewers.utils")

  return previewers.new_buffer_previewer({
    title = "Diff Preview",
    define_preview = function(self, entry, status)
      local key = index_map[entry.index]
      if not key then
        return
      end

      local st = state_module.state[key.buf]
      if not st or not st.hunks[key.idx] then
        return
      end

      local hunk = st.hunks[key.idx]

      -- Build diff content
      local lines = {}
      table.insert(lines, string.format("File: %s", vim.fn.fnamemodify(st.path, ":.")))
      table.insert(lines, string.format("--- Original (lines %d-%d)", hunk.s, hunk.e))
      table.insert(lines, string.format("+++ Claude's changes (lines %d-%d)", hunk.s, hunk.e))
      table.insert(lines, "")

      -- Show old content
      if #hunk.old > 0 then
        for _, line in ipairs(hunk.old) do
          table.insert(lines, "- " .. line)
        end
      else
        table.insert(lines, "- (empty - deletion)")
      end

      table.insert(lines, "")

      -- Show new content
      if #hunk.new > 0 then
        for _, line in ipairs(hunk.new) do
          table.insert(lines, "+ " .. line)
        end
      else
        table.insert(lines, "+ (empty - addition)")
      end

      -- Set buffer content
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

      -- Apply diff syntax highlighting
      putils.highlighter(self.state.bufnr, "diff")
    end,
  })
end

-- Open Telescope picker for current buffer's hunks
function M.open_buffer_picker()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local buf = vim.api.nvim_get_current_buf()
  local st = state_module.buf_state(buf)
  local items = {}

  for i, h in ipairs(st.hunks) do
    local summary = (h.new[1] or h.old[1] or ""):sub(1, 60)
    table.insert(items, string.format(
      "%s:%d-%d %s",
      vim.fn.fnamemodify(st.path, ":."),
      h.s,
      h.e,
      summary
    ))
  end

  if #items == 0 then
    vim.notify("No Claude diffs in current buffer", vim.log.levels.INFO)
    return
  end

  pickers.new({}, {
    prompt_title = "Claude Diffs (buffer)",
    finder = finders.new_table { results = items },
    sorter = conf.generic_sorter({}),
    previewer = create_diff_previewer(st.hunks, st.path),
    attach_mappings = function(prompt_bufnr, map)
      local function jump(sel)
        local idx = sel.index
        local h = st.hunks[idx]
        vim.api.nvim_win_set_cursor(0, { h.s, 0 })
      end

      map("i", "<CR>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        jump(s)
      end)

      map("n", "<CR>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        jump(s)
      end)

      map("i", "<C-a>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        actions_module.accept_hunk(buf, st, s.index)
      end)

      map("n", "a", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        actions_module.accept_hunk(buf, st, s.index)
      end)

      map("i", "<C-r>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        actions_module.reject_hunk(buf, st, s.index)
      end)

      map("n", "r", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        actions_module.reject_hunk(buf, st, s.index)
      end)

      map("i", "<C-b>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        actions_module.accept_both(buf, st, s.index)
      end)

      map("n", "b", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        actions_module.accept_both(buf, st, s.index)
      end)

      return true
    end
  }):find()
end

-- Open Telescope picker for project-wide hunks
function M.open_project_picker()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local entries = {}
  local index = {}

  for buf, _ in pairs(state_module.project.bufs) do
    local st = state_module.state[buf]
    if st and st.hunks and #st.hunks > 0 then
      for i, h in ipairs(st.hunks) do
        local key = { buf = buf, idx = i }
        local summary = (h.new[1] or h.old[1] or ""):sub(1, 60)
        local line = string.format(
          "%s:%d-%d %s",
          vim.fn.fnamemodify(st.path, ":."),
          h.s,
          h.e,
          summary
        )
        table.insert(entries, line)
        table.insert(index, key)
      end
    end
  end

  if #entries == 0 then
    vim.notify("No Claude diffs in project", vim.log.levels.INFO)
    return
  end

  pickers.new({}, {
    prompt_title = "Claude Diffs (project)",
    finder = finders.new_table { results = entries },
    sorter = conf.generic_sorter({}),
    previewer = create_project_diff_previewer(index),
    attach_mappings = function(prompt_bufnr, map)
      local function jump(sel)
        local key = index[sel.index]
        vim.api.nvim_set_current_buf(key.buf)
        local st = state_module.buf_state(key.buf)
        local h = st.hunks[key.idx]
        vim.api.nvim_win_set_cursor(0, { h.s, 0 })
      end

      map("i", "<CR>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        jump(s)
      end)

      map("n", "<CR>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        jump(s)
      end)

      map("i", "<C-a>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        local k = index[s.index]
        actions_module.accept_hunk(k.buf, state_module.state[k.buf], k.idx)
      end)

      map("n", "a", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        local k = index[s.index]
        actions_module.accept_hunk(k.buf, state_module.state[k.buf], k.idx)
      end)

      map("i", "<C-r>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        local k = index[s.index]
        actions_module.reject_hunk(k.buf, state_module.state[k.buf], k.idx)
      end)

      map("n", "r", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        local k = index[s.index]
        actions_module.reject_hunk(k.buf, state_module.state[k.buf], k.idx)
      end)

      map("i", "<C-b>", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        local k = index[s.index]
        actions_module.accept_both(k.buf, state_module.state[k.buf], k.idx)
      end)

      map("n", "b", function(pb)
        local s = action_state.get_selected_entry()
        actions.close(pb)
        local k = index[s.index]
        actions_module.accept_both(k.buf, state_module.state[k.buf], k.idx)
      end)

      return true
    end
  }):find()
end

return M
