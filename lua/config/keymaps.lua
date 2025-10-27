-- Centralized keymap configuration
-- All keybindings defined in one place for easy reference and conflict detection

local opts = { noremap = true, silent = true }

-- ============================================================================
-- CORE VIM KEYMAPS
-- ============================================================================

-- Clipboard operations
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { noremap = true, desc = "Yank to clipboard" })
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', { noremap = true, desc = "Paste from clipboard" })

-- Visual mode indentation (maintain selection)
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, desc = "Indent and reselect" })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, desc = "Unindent and reselect" })

-- Window/split management
vim.keymap.set("n", "<C-s>", "<cmd>split<cr>", { noremap = true, desc = "Horizontal split" })
vim.keymap.set("n", "<C-p>", "<cmd>vsplit<cr>", { noremap = true, desc = "Vertical split" })
vim.keymap.set("n", "<C-q>", "<cmd>close<cr>", { noremap = true, desc = "Close window" })

-- ============================================================================
-- LSP KEYMAPS
-- ============================================================================

-- Safe LSP operation wrapper (defined in lsp-config.lua, used here)
local function safe_lsp_operation(operation)
  return function()
    local ok, err = pcall(operation)
    if not ok then
      vim.notify("LSP operation failed: " .. tostring(err), vim.log.levels.WARN)
    end
  end
end

-- Navigation
vim.keymap.set('n', 'gd', safe_lsp_operation(vim.lsp.buf.definition), vim.tbl_extend("force", opts, { desc = "Go to definition" }))
vim.keymap.set('n', 'gr', safe_lsp_operation(vim.lsp.buf.references), vim.tbl_extend("force", opts, { desc = "Go to references" }))
vim.keymap.set('n', 'gi', safe_lsp_operation(vim.lsp.buf.implementation), vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
vim.keymap.set("n", "K", safe_lsp_operation(vim.lsp.buf.hover), vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

-- Actions
vim.keymap.set('n', '<leader>rn', safe_lsp_operation(vim.lsp.buf.rename), vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
vim.keymap.set('n', '<leader>ca', safe_lsp_operation(vim.lsp.buf.code_action), vim.tbl_extend("force", opts, { desc = "Code action" }))

-- Diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostics" }))
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostics to loclist" }))
vim.keymap.set('n', '<leader>dg', function() require('utils.diagnostics').copy_all_diagnostics() end, vim.tbl_extend("force", opts, { desc = "Copy all diagnostics" }))

-- ============================================================================
-- TELESCOPE KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", vim.tbl_extend("force", opts, { desc = "Find files" }))
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", vim.tbl_extend("force", opts, { desc = "Live grep" }))
vim.keymap.set("n", "<leader>fr", function() require('telescope.builtin').grep_string() end, vim.tbl_extend("force", opts, { desc = "Global find and replace" }))
vim.keymap.set("n", "<leader>fh", function()
  local harpoon = require("harpoon")
  local conf = require("telescope.config").values
  local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
      table.insert(file_paths, item.value)
    end
    require("telescope.pickers").new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table({ results = file_paths }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
    }):find()
  end
  toggle_telescope(harpoon:list())
end, vim.tbl_extend("force", opts, { desc = "Harpoon in Telescope" }))

vim.keymap.set("n", "<leader>fe", function()
  require("telescope.builtin").diagnostics({ bufnr = 0, severity = "ERROR" })
end, vim.tbl_extend("force", opts, { desc = "Buffer errors" }))

vim.keymap.set("n", "<leader>fd", function()
  require("telescope.builtin").diagnostics({ bufnr = 0 })
end, vim.tbl_extend("force", opts, { desc = "Buffer diagnostics" }))

vim.keymap.set("n", "<leader><leader>", "<cmd>Telescope oldfiles<cr>", vim.tbl_extend("force", opts, { desc = "Recent files" }))
vim.keymap.set("n", "<leader>f", "<cmd>Telescope current_buffer_fuzzy_find<cr>", vim.tbl_extend("force", opts, { desc = "Fuzzy find in buffer" }))
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", vim.tbl_extend("force", opts, { desc = "Find buffers" }))
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", vim.tbl_extend("force", opts, { desc = "Git status" }))

vim.keymap.set("n", "<leader>fs", function()
  require("telescope.builtin").lsp_document_symbols({ symbols = {"function", "method", "class"} })
end, vim.tbl_extend("force", opts, { desc = "Document symbols (filtered)" }))

vim.keymap.set("n", "<leader>f.", "<cmd>Telescope lsp_document_symbols<cr>", vim.tbl_extend("force", opts, { desc = "Document symbols (all)" }))
vim.keymap.set("n", "<leader>bm", "<cmd>Telescope bookmarks list<cr>", vim.tbl_extend("force", opts, { desc = "Find bookmarks" }))
vim.keymap.set("n", "<leader>fv", function() require("utils.vulture-picker").vulture_picker() end, vim.tbl_extend("force", opts, { desc = "Find unused Python code" }))

-- Tmux session switcher
vim.keymap.set("n", "<leader>s", function()
  local handle = io.popen("tmux list-sessions -F '#S'")
  local sessions = {}
  if handle then
    for session in handle:lines() do
      table.insert(sessions, session)
    end
    handle:close()
  end
  if #sessions == 0 then
    print("No tmux sessions found")
    return
  end
  require("telescope.pickers").new({}, {
    prompt_title = "Switch Tmux Session",
    finder = require("telescope.finders").new_table({ results = sessions }),
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          vim.fn.system("tmux switch-client -t " .. selection[1])
        end
      end)
      return true
    end,
  }):find()
end, vim.tbl_extend("force", opts, { desc = "Switch tmux session" }))

-- ============================================================================
-- FORMATTING KEYMAPS
-- ============================================================================

-- Format with conform.nvim (was <leader>f, now <leader>fm to avoid conflict)
vim.keymap.set("", "<leader>fm", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

-- ============================================================================
-- LINTING KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<leader>l", function()
  require("lint").try_lint()
end, vim.tbl_extend("force", opts, { desc = "Trigger linting" }))

-- ============================================================================
-- TYPESCRIPT-SPECIFIC KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<leader>to", "<cmd>TSToolsOrganizeImports<cr>", vim.tbl_extend("force", opts, { desc = "Organize imports (TS)" }))
vim.keymap.set("n", "<leader>ts", "<cmd>TSToolsSortImports<cr>", vim.tbl_extend("force", opts, { desc = "Sort imports (TS)" }))
vim.keymap.set("n", "<leader>tru", "<cmd>TSToolsRemoveUnused<cr>", vim.tbl_extend("force", opts, { desc = "Remove unused (TS)" }))
vim.keymap.set("n", "<leader>trf", "<cmd>TSToolsRemoveUnusedImports<cr>", vim.tbl_extend("force", opts, { desc = "Remove unused imports (TS)" }))
vim.keymap.set("n", "<leader>tfa", "<cmd>TSToolsFixAll<cr>", vim.tbl_extend("force", opts, { desc = "Fix all (TS)" }))
vim.keymap.set("n", "<leader>tai", "<cmd>TSToolsAddMissingImports<cr>", vim.tbl_extend("force", opts, { desc = "Add missing imports (TS)" }))
vim.keymap.set("n", "<leader>tgd", "<cmd>TSToolsGoToSourceDefinition<cr>", vim.tbl_extend("force", opts, { desc = "Go to source definition (TS)" }))
vim.keymap.set("n", "<leader>tfu", "<cmd>TSToolsFileReferences<cr>", vim.tbl_extend("force", opts, { desc = "File references (TS)" }))
vim.keymap.set("n", "<leader>trn", "<cmd>TSToolsRenameFile<cr>", vim.tbl_extend("force", opts, { desc = "Rename file (TS)" }))

-- ============================================================================
-- PYTHON-SPECIFIC KEYMAPS (Ruff)
-- ============================================================================

-- Note: These are set up in languages/python.lua as buffer-local keymaps
-- Listed here for reference:
-- <leader>tf - Fix all auto-fixable issues (Ruff)
-- <leader>te - Extract to function/method (visual mode)
-- <leader>tr - Show all refactor options

-- ============================================================================
-- DEBUG (DAP) KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<space>b", function() require("dap").toggle_breakpoint() end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
vim.keymap.set("n", "<space>gb", function() require("dap").run_to_cursor() end, vim.tbl_extend("force", opts, { desc = "Run to cursor" }))
vim.keymap.set("n", "<space>dl", function() require("dap").run_last() end, vim.tbl_extend("force", opts, { desc = "Debug: Run last" }))
vim.keymap.set("n", "<space>dc", function() require("dap").continue() end, vim.tbl_extend("force", opts, { desc = "Debug: Continue/Start" }))
vim.keymap.set("n", "<space>ds", function()
  local dap = require("dap")
  local filetype = vim.bo.filetype
  local configs = dap.configurations[filetype]
  if not configs or #configs == 0 then
    vim.notify("No debug configurations found for filetype: " .. filetype, vim.log.levels.WARN)
    return
  end
  if #configs == 1 then
    dap.run(configs[1])
  else
    vim.ui.select(configs, {
      prompt = "Select debug configuration:",
      format_item = function(config) return config.name or "Unknown" end,
    }, function(choice)
      if choice then dap.run(choice) end
    end)
  end
end, vim.tbl_extend("force", opts, { desc = "Debug: Select config" }))

vim.keymap.set("n", "<space>?", function()
  require("dapui").eval(nil, { enter = true })
end, vim.tbl_extend("force", opts, { desc = "Evaluate expression" }))

-- Function keys for debugging
vim.keymap.set("n", "<F1>", function() require("dap").continue() end, vim.tbl_extend("force", opts, { desc = "Debug: Continue" }))
vim.keymap.set("n", "<F2>", function() require("dap").step_into() end, vim.tbl_extend("force", opts, { desc = "Debug: Step into" }))
vim.keymap.set("n", "<F3>", function() require("dap").step_over() end, vim.tbl_extend("force", opts, { desc = "Debug: Step over" }))
vim.keymap.set("n", "<F4>", function() require("dap").step_out() end, vim.tbl_extend("force", opts, { desc = "Debug: Step out" }))
vim.keymap.set("n", "<F5>", function() require("dap").step_back() end, vim.tbl_extend("force", opts, { desc = "Debug: Step back" }))
vim.keymap.set("n", "<F6>", function() require("dap").toggle_breakpoint() end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
vim.keymap.set("n", "<F13>", function() require("dap").restart() end, vim.tbl_extend("force", opts, { desc = "Debug: Restart" }))

-- ============================================================================
-- FILE EXPLORER KEYMAPS
-- ============================================================================

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', vim.tbl_extend("force", opts, { desc = "Toggle NvimTree" }))
vim.keymap.set("n", "-", "<CMD>Oil<CR>", vim.tbl_extend("force", opts, { desc = "Open Oil" }))

-- ============================================================================
-- GIT KEYMAPS
-- ============================================================================

vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', vim.tbl_extend("force", opts, { desc = "Open LazyGit" }))

-- Octo (GitHub PR/Issue management) - Global keymaps
-- PR operations
vim.keymap.set("n", "<leader>gpr", "<cmd>Octo pr list<CR>", vim.tbl_extend("force", opts, { desc = "List PRs" }))
vim.keymap.set("n", "<leader>gpc", "<cmd>Octo pr create<CR>", vim.tbl_extend("force", opts, { desc = "Create PR" }))
vim.keymap.set("n", "<leader>gps", "<cmd>Octo pr search<CR>", vim.tbl_extend("force", opts, { desc = "Search PRs" }))
vim.keymap.set("n", "<leader>gpe", "<cmd>Octo pr edit<CR>", vim.tbl_extend("force", opts, { desc = "Edit PR" }))
vim.keymap.set("n", "<leader>gpp", "<cmd>Octo pr checkout<CR>", vim.tbl_extend("force", opts, { desc = "Checkout PR" }))
vim.keymap.set("n", "<leader>gpd", "<cmd>Octo pr diff<CR>", vim.tbl_extend("force", opts, { desc = "PR diff" }))
vim.keymap.set("n", "<leader>gpm", "<cmd>Octo pr merge<CR>", vim.tbl_extend("force", opts, { desc = "Merge PR" }))
vim.keymap.set("n", "<leader>gpo", "<cmd>Octo pr browser<CR>", vim.tbl_extend("force", opts, { desc = "Open PR in browser" }))

-- Issue operations
vim.keymap.set("n", "<leader>gir", "<cmd>Octo issue list<CR>", vim.tbl_extend("force", opts, { desc = "List issues" }))
vim.keymap.set("n", "<leader>gic", "<cmd>Octo issue create<CR>", vim.tbl_extend("force", opts, { desc = "Create issue" }))
vim.keymap.set("n", "<leader>gis", "<cmd>Octo issue search<CR>", vim.tbl_extend("force", opts, { desc = "Search issues" }))
vim.keymap.set("n", "<leader>gie", "<cmd>Octo issue edit<CR>", vim.tbl_extend("force", opts, { desc = "Edit issue" }))
vim.keymap.set("n", "<leader>gio", "<cmd>Octo issue browser<CR>", vim.tbl_extend("force", opts, { desc = "Open issue in browser" }))

-- Review operations
vim.keymap.set("n", "<leader>gvs", "<cmd>Octo review start<CR>", vim.tbl_extend("force", opts, { desc = "Start review" }))
vim.keymap.set("n", "<leader>gvr", "<cmd>Octo review resume<CR>", vim.tbl_extend("force", opts, { desc = "Resume review" }))
vim.keymap.set("n", "<leader>gvc", "<cmd>Octo review comments<CR>", vim.tbl_extend("force", opts, { desc = "Review comments" }))
vim.keymap.set("n", "<leader>gvt", "<cmd>Octo review submit<CR>", vim.tbl_extend("force", opts, { desc = "Submit review" }))
vim.keymap.set("n", "<leader>gvd", "<cmd>Octo review discard<CR>", vim.tbl_extend("force", opts, { desc = "Discard review" }))

-- Comment operations
vim.keymap.set("n", "<leader>gpa", "<cmd>Octo comment add<CR>", vim.tbl_extend("force", opts, { desc = "Add comment" }))
vim.keymap.set("n", "<leader>gcd", "<cmd>Octo comment delete<CR>", vim.tbl_extend("force", opts, { desc = "Delete comment" }))

-- ============================================================================
-- UI / NOTIFICATION KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<leader>n", function() Snacks.notifier.show_history() end, vim.tbl_extend("force", opts, { desc = "Notification history" }))
vim.keymap.set("n", "<leader>nd", function() Snacks.notifier.hide() end, vim.tbl_extend("force", opts, { desc = "Dismiss notifications" }))

-- ============================================================================
-- AI ASSISTANT KEYMAPS
-- ============================================================================

-- Claude Code
vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", vim.tbl_extend("force", opts, { desc = "Toggle Claude" }))
vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", vim.tbl_extend("force", opts, { desc = "Resume Claude" }))
vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", vim.tbl_extend("force", opts, { desc = "Continue Claude" }))
vim.keymap.set("n", "<leader>aV", "<cmd>ClaudeCode --verbose<cr>", vim.tbl_extend("force", opts, { desc = "Verbose Claude" }))

-- Augment Code
vim.keymap.set("n", "<leader>ta", function()
  if vim.g.augment_disable_completions == true then
    vim.g.augment_disable_completions = false
    vim.notify("Augment completions enabled")
  else
    vim.g.augment_disable_completions = true
    vim.notify("Augment completions disabled")
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle Augment" }))

vim.keymap.set("i", "<S-Tab>", "<cmd>call augment#Accept()<cr>", { noremap = true, silent = true, desc = "Accept Augment completion" })

-- ============================================================================
-- FOLDING KEYMAPS (UFO)
-- ============================================================================

vim.keymap.set('n', 'zR', function() require('ufo').openAllFolds() end, vim.tbl_extend("force", opts, { desc = "Open all folds" }))
vim.keymap.set('n', 'zM', function() require('ufo').closeAllFolds() end, vim.tbl_extend("force", opts, { desc = "Close all folds" }))
