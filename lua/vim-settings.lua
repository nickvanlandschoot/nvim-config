-- Set tab width and leader key
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })

-- Remap 'y' in normal and visual mode to yank to clipboard while preserving default functionality
vim.keymap.set("n", "y", '"+y', { noremap = true })
vim.keymap.set("v", "y", '"+y', { noremap = true })

--Map open diagnostics to shift `f`
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')

-- Enable Tree-sitter based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
