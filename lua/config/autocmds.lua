-- Centralized autocmd configuration
-- All autocommands defined in one place

-- ============================================================================
-- LINTING AUTOCMDS
-- ============================================================================

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    local ok, lint = pcall(require, "lint")
    if ok then
      lint.try_lint()
    end
  end,
  desc = "Trigger linting on buffer enter and insert leave",
})

-- ============================================================================
-- TERMINAL AUTOCMDS
-- ============================================================================

-- Set up tmux navigation for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.keymap.set("t", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { buffer = true })
    vim.keymap.set("t", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { buffer = true })
    vim.keymap.set("t", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { buffer = true })
    vim.keymap.set("t", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { buffer = true })
  end,
  desc = "Set up tmux navigation in terminal mode",
})

-- ============================================================================
-- OTHER AUTOCMDS
-- ============================================================================

-- Note: Language-specific autocmds (like Python Ruff auto-fix) are defined
-- in their respective language modules (lua/languages/*.lua)
