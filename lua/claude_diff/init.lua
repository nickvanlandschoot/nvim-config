-- Claude Diff Plugin - Main entry point
--
-- RESPONSIBILITIES:
-- - Plugin setup and configuration
-- - Autocmd registration for file events
-- - User command registration
-- - Coordinate between modules (state, diff, render, actions, persistence)
-- - No direct buffer/state modification (delegates to other modules)
local M = {}

local state = require("claude_diff.state")
local diff = require("claude_diff.diff")
local render = require("claude_diff.render")
local actions = require("claude_diff.actions")
local telescope = require("claude_diff.telescope")
local persistence = require("claude_diff.persistence")

-- Debounce timer for user changes
local debounce_timer = nil
-- Periodic checktime timer
local periodic_timer = nil

-- Debounced user change tracking with dynamic hunk adjustment
local function debounce_user(buf, immediate)
  if debounce_timer then
    vim.fn.timer_stop(debounce_timer)
  end

  local function do_update()
    local st = state.buf_state(buf)
    local had_changes = state.track_user_edit(buf, true)

    -- If hunks were affected, re-render immediately and save state
    if had_changes and #st.hunks > 0 then
      render.render_hunks(buf, st)
      persistence.save_state(st.path, st)
    elseif #st.hunks == 0 then
      -- Clean up state if no hunks remain
      persistence.save_state(st.path, st)
    end
  end

  if immediate then
    -- Immediate update (e.g., on save)
    do_update()
  else
    -- Debounced update (normal editing)
    debounce_timer = vim.fn.timer_start(150, do_update)
  end
end

-- Capture buffer state before external file reload
local function on_file_changed_shell(buf)
  local st = state.buf_state(buf)

  -- CRITICAL: Capture buffer state BEFORE autoread reloads it
  -- This preserves user's unsaved edits
  -- Store in a temp field for use in FileChangedShellPost
  st.pre_reload_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

-- Handle external file changes (e.g., Claude writes) - AFTER reload
local function on_external_change(buf)
  local st = state.buf_state(buf)

  -- Use the pre-reload buffer state as the new baseline
  -- This preserves any unsaved edits the user made before Claude wrote
  --
  -- Timeline:
  -- 1. User makes edits (captured in user_snapshot via TextChanged)
  -- 2. Claude writes to disk
  -- 3. FileChangedShell fires → captures buffer state in pre_reload_lines
  -- 4. Autoread reloads buffer with Claude's version
  -- 5. FileChangedShellPost fires (this function)
  -- 6. We use pre_reload_lines as baseline
  -- 7. Calculate hunks = Claude's version vs user's pre-reload state

  if st.pre_reload_lines then
    st.baseline.lines = st.pre_reload_lines
    st.baseline.tick = st.baseline.tick + 1
    st.pre_reload_lines = nil -- Clear temp storage
  end

  -- Clear old hunks and user ranges since we're starting fresh with new baseline
  st.hunks = {}
  st.user_ranges = {}

  -- Process the new external change
  -- This will calculate hunks from current buffer (Claude's version) vs baseline (user's edits)
  diff.process_external_change(buf, st)
  render.render_hunks(buf, st)

  -- Reset user snapshot to match current buffer after external change
  st.user_snapshot.lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Save state for persistence
  persistence.save_state(st.path, st)
end

-- Handle after buffer save
local function on_saved(buf)
  local st = state.buf_state(buf)

  -- If no hunks remain, reset baseline to match saved file
  -- This becomes the new reference point for future Claude writes
  if #st.hunks == 0 then
    diff.reset_baseline(buf, st)
  end
end

-- Setup function - initialize plugin
function M.setup(opts)
  opts = opts or {}

  -- Default configuration
  local config = {
    check_interval = opts.check_interval or 3000, -- milliseconds (default 3 seconds)
    keymaps = opts.keymaps,
  }

  -- Enable autoread for external changes
  vim.o.autoread = true

  -- Setup highlight groups
  render.setup_highlights()

  -- Clean up old state files (30+ days old)
  persistence.cleanup_old_states()

  -- Initialize buffer state on read and load from persistence
  vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("ClaudeDiffInit", { clear = true }),
    callback = function(args)
      local st = state.buf_state(args.buf, true) -- try to load from persistence
      -- If we loaded hunks from persistence, render them
      if st.hunks and #st.hunks > 0 then
        render.render_hunks(args.buf, st)
      end
    end,
  })

  -- Track user edits (debounced for performance)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = vim.api.nvim_create_augroup("ClaudeDiffUserEdit", { clear = true }),
    callback = function(args)
      debounce_user(args.buf, false)
    end,
  })

  -- Capture buffer state before external file reload
  vim.api.nvim_create_autocmd({ "FileChangedShell" }, {
    group = vim.api.nvim_create_augroup("ClaudeDiffPreReload", { clear = true }),
    callback = function(args)
      on_file_changed_shell(args.buf)
    end,
  })

  -- Handle external changes (Claude writes) - after reload
  vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
    group = vim.api.nvim_create_augroup("ClaudeDiffExternal", { clear = true }),
    callback = function(args)
      on_external_change(args.buf)
    end,
  })

  -- Handle saves (update hunks after write + baseline reset if no hunks)
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("ClaudeDiffSave", { clear = true }),
    callback = function(args)
      -- Update hunks immediately on save
      debounce_user(args.buf, true)
      -- Reset baseline if no hunks remain
      on_saved(args.buf)
    end,
  })

  -- Trigger checktime on focus and cursor movement
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorMoved", "CursorMovedI" }, {
    group = vim.api.nvim_create_augroup("ClaudeDiffChecktime", { clear = true }),
    callback = function()
      pcall(vim.cmd, "checktime")
    end,
  })

  -- Periodic checktime for automatic detection when idle
  if periodic_timer then
    vim.fn.timer_stop(periodic_timer)
  end
  periodic_timer = vim.fn.timer_start(config.check_interval, function()
    pcall(vim.cmd, "checktime")
  end, { ["repeat"] = -1 })

  -- Clean up state on buffer delete
  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    group = vim.api.nvim_create_augroup("ClaudeDiffCleanup", { clear = true }),
    callback = function(args)
      state.cleanup_buffer(args.buf)
    end,
  })

  -- Commands
  vim.api.nvim_create_user_command("ClaudeNextDiff", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state.buf_state(buf)
    actions.next_hunk(buf, st)
  end, {})

  vim.api.nvim_create_user_command("ClaudePrevDiff", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state.buf_state(buf)
    actions.prev_hunk(buf, st)
  end, {})

  vim.api.nvim_create_user_command("ClaudeAcceptHunk", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state.buf_state(buf)
    local idx = actions.hunk_at_cursor(st) or actions.next_hunk(buf, st) or 1
    actions.accept_hunk(buf, st, idx)
  end, {})

  vim.api.nvim_create_user_command("ClaudeRejectHunk", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state.buf_state(buf)
    local idx = actions.hunk_at_cursor(st) or actions.next_hunk(buf, st) or 1
    actions.reject_hunk(buf, st, idx)
  end, {})

  vim.api.nvim_create_user_command("ClaudeAcceptBoth", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state.buf_state(buf)
    local idx = actions.hunk_at_cursor(st) or actions.next_hunk(buf, st) or 1
    actions.accept_both(buf, st, idx)
  end, {})

  vim.api.nvim_create_user_command("ClaudeAcceptAll", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state.buf_state(buf)
    actions.accept_all(buf, st)
  end, {})

  vim.api.nvim_create_user_command("ClaudeRejectAll", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state.buf_state(buf)
    actions.reject_all(buf, st)
  end, {})

  vim.api.nvim_create_user_command("ClaudeDiffs", function()
    telescope.open_buffer_picker()
  end, {})

  vim.api.nvim_create_user_command("ClaudeProjectDiffs", function()
    telescope.open_project_picker()
  end, {})

  -- Testing command (dev only)
  vim.api.nvim_create_user_command("ClaudeRunTests", function()
    vim.cmd([[lua require('plenary.test_harness').test_directory('tests/claude_diff')]])
  end, { desc = "Run Claude Diff tests" })

  -- Default keymaps (can be disabled via opts)
  if config.keymaps ~= false then
    vim.keymap.set("n", "]h", ":ClaudeNextDiff<CR>", { silent = true, desc = "Next Claude hunk" })
    vim.keymap.set("n", "[h", ":ClaudePrevDiff<CR>", { silent = true, desc = "Previous Claude hunk" })
    vim.keymap.set("n", "<leader>ha", ":ClaudeAcceptHunk<CR>", { silent = true, desc = "Accept Claude hunk" })
    vim.keymap.set("n", "<leader>hr", ":ClaudeRejectHunk<CR>", { silent = true, desc = "Reject Claude hunk" })
    vim.keymap.set("n", "<leader>hb", ":ClaudeAcceptBoth<CR>", { silent = true, desc = "Accept both (merge conflict)" })
    vim.keymap.set("n", "<leader>hl", ":ClaudeDiffs<CR>", { silent = true, desc = "List Claude hunks (buffer)" })
    vim.keymap.set("n", "<leader>hL", ":ClaudeProjectDiffs<CR>", { silent = true, desc = "List Claude hunks (project)" })
  end
end

return M
