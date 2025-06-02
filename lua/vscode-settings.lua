-- VSCode-specific Neovim configuration
local vscode = require('vscode')

-- Set leader key (already set in init.lua but keeping for clarity)
vim.g.mapleader = " "

-- Basic clipboard integration - use VSCode's clipboard
vim.g.clipboard = vim.g.vscode_clipboard

-- Key mappings that work well with VSCode
-- These replace some of the keybindings from vim-settings.lua that won't work in VSCode

-- File operations using VSCode commands
vim.keymap.set('n', '<leader>e', function()
  vscode.action('workbench.view.explorer')
end, { desc = 'Toggle Explorer' })

vim.keymap.set('n', '<leader>nf', function()
  vscode.action('workbench.files.action.showActiveFileInExplorer')
end, { desc = 'Find current file in explorer' })

-- Git operations using VSCode commands
vim.keymap.set('n', '<leader>gg', function()
  vscode.action('git.openChange')
end, { desc = 'Open Git changes' })

-- Diagnostics using VSCode
vim.keymap.set('n', '<leader>d', function()
  vscode.action('editor.action.marker.next')
end, { desc = 'Next diagnostic' })

-- Search and navigation
vim.keymap.set('n', '<leader>ff', function()
  vscode.action('workbench.action.quickOpen')
end, { desc = 'Quick Open' })

vim.keymap.set('n', '<leader>fg', function()
  vscode.action('workbench.action.findInFiles')
end, { desc = 'Find in Files' })

-- Code actions and formatting
vim.keymap.set('n', '<leader>ca', function()
  vscode.action('editor.action.quickFix')
end, { desc = 'Code Actions' })

vim.keymap.set({'n', 'x'}, '=', function()
  vscode.action('editor.action.formatSelection')
end, { desc = 'Format Selection' })

-- Enhanced clipboard operations - yank to VSCode clipboard
vim.keymap.set("n", "y", '"+y', { noremap = true, desc = "Yank to clipboard" })
vim.keymap.set("v", "y", '"+y', { noremap = true, desc = "Yank to clipboard" })

-- Tab/indentation in visual mode
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, desc = "Indent and reselect" })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, desc = "Unindent and reselect" })

-- Line movement using VSCode commands for better integration
vim.keymap.set("n", "<C-S-k>", function()
  vscode.action('editor.action.moveLinesUpAction')
end, { noremap = true, silent = true, desc = "Move line up" })

vim.keymap.set("n", "<C-S-j>", function()
  vscode.action('editor.action.moveLinesDownAction')
end, { noremap = true, silent = true, desc = "Move line down" })

vim.keymap.set("v", "<C-S-k>", function()
  vscode.action('editor.action.moveLinesUpAction')
end, { noremap = true, silent = true, desc = "Move selection up" })

vim.keymap.set("v", "<C-S-j>", function()
  vscode.action('editor.action.moveLinesDownAction')
end, { noremap = true, silent = true, desc = "Move selection down" })

-- Window/panel management
vim.keymap.set('n', '<C-w>v', function()
  vscode.action('workbench.action.splitEditor')
end, { desc = 'Split editor vertically' })

vim.keymap.set('n', '<C-w>s', function()
  vscode.action('workbench.action.splitEditorDown')
end, { desc = 'Split editor horizontally' })

vim.keymap.set('n', '<C-w>q', function()
  vscode.action('workbench.action.closeActiveEditor')
end, { desc = 'Close active editor' })

-- Navigation between editors
vim.keymap.set('n', '<C-w>h', function()
  vscode.action('workbench.action.focusLeftGroup')
end, { desc = 'Focus left editor group' })

vim.keymap.set('n', '<C-w>l', function()
  vscode.action('workbench.action.focusRightGroup')
end, { desc = 'Focus right editor group' })

vim.keymap.set('n', '<C-w>j', function()
  vscode.action('workbench.action.focusBelowGroup')
end, { desc = 'Focus below editor group' })

vim.keymap.set('n', '<C-w>k', function()
  vscode.action('workbench.action.focusAboveGroup')
end, { desc = 'Focus above editor group' })

-- Tab navigation
vim.keymap.set('n', 'gt', function()
  vscode.action('workbench.action.nextEditor')
end, { desc = 'Next tab' })

vim.keymap.set('n', 'gT', function()
  vscode.action('workbench.action.previousEditor')
end, { desc = 'Previous tab' })

-- Symbol navigation
vim.keymap.set('n', 'gd', function()
  vscode.action('editor.action.revealDefinition')
end, { desc = 'Go to definition' })

vim.keymap.set('n', 'gr', function()
  vscode.action('editor.action.goToReferences')
end, { desc = 'Go to references' })

vim.keymap.set('n', 'K', function()
  vscode.action('editor.action.showHover')
end, { desc = 'Show hover' })

-- Multi-cursor support
vim.keymap.set({ "n", "x", "i" }, "<C-d>", function()
  vscode.with_insert(function()
    vscode.action("editor.action.addSelectionToNextFindMatch")
  end)
end, { desc = "Add selection to next find match" })

-- Folding using VSCode commands
vim.keymap.set('n', 'za', function()
  vscode.action('editor.toggleFold')
end, { desc = 'Toggle fold' })

vim.keymap.set('n', 'zc', function()
  vscode.action('editor.fold')
end, { desc = 'Close fold' })

vim.keymap.set('n', 'zo', function()
  vscode.action('editor.unfold')
end, { desc = 'Open fold' })

vim.keymap.set('n', 'zM', function()
  vscode.action('editor.foldAll')
end, { desc = 'Fold all' })

vim.keymap.set('n', 'zR', function()
  vscode.action('editor.unfoldAll')
end, { desc = 'Unfold all' })

-- Comment toggling
vim.keymap.set({'n', 'v'}, '<leader>/', function()
  vscode.action('editor.action.commentLine')
end, { desc = 'Toggle comment' })

-- Find and replace
vim.keymap.set('n', '<leader>fr', function()
  vscode.action('editor.action.startFindReplaceAction')
end, { desc = 'Find and replace' })

-- Zen mode
vim.keymap.set('n', '<leader>z', function()
  vscode.action('workbench.action.toggleZenMode')
end, { desc = 'Toggle Zen Mode' })

-- Command palette
vim.keymap.set('n', '<leader>p', function()
  vscode.action('workbench.action.showCommands')
end, { desc = 'Command Palette' })

-- Terminal
vim.keymap.set('n', '<leader>t', function()
  vscode.action('workbench.action.terminal.toggleTerminal')
end, { desc = 'Toggle Terminal' }) 