vim.g.mapleader = " "

vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers

-- Persistent Undo
vim.opt.undofile = true         -- Enable persistent undo instead
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"  -- Set undo directory

local undo_dir = vim.fn.stdpath("data") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
vim.fn.mkdir(undo_dir, "p")
end

-- Remap 'y' in normal and visual mode to yank to clipboard while preserving default functionality
vim.keymap.set("n", "y", '"+y', { noremap = true })
vim.keymap.set("v", "y", '"+y', { noremap = true })

vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')

-- Remap Tab in visual mode to reselect visual area after indenting

vim.keymap.set("v", "<Tab>", ">gv", { noremap = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true })

-- Set scrolloff 
vim.opt.scrolloff = 12

--vim.opt.spell = true
vim.opt.spelllang = "en_us"
