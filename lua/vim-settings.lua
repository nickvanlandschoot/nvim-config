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

-- Use leader+y for clipboard yank instead of overriding default y
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { noremap = true, desc = "Yank to clipboard" })
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', { noremap = true, desc = "Paste from clipboard" })

vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')

-- Remap Tab in visual mode to reselect visual area after indenting

vim.keymap.set("v", "<Tab>", ">gv", { noremap = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true })

-- Set scrolloff
vim.opt.scrolloff = 12

--vim.opt.spell = true
vim.opt.spelllang = "en_us"

-- Window/split management
vim.keymap.set("n", "<C-s>", "<cmd>split<cr>", { noremap = true, desc = "Horizontal split" })
vim.keymap.set("n", "<C-p>", "<cmd>vsplit<cr>", { noremap = true, desc = "Vertical split" })
vim.keymap.set("n", "<C-q>", "<cmd>close<cr>", { noremap = true, desc = "Close window" })
