-- Neovim settings and options

-- Set leader key
vim.g.mapleader = " "

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 12

-- Wrapping options are applied only to normal editing windows in autocmds.lua.
-- Keeping them out of the global defaults prevents one-line prompts, pickers,
-- and floating inputs from inheriting display offsets intended for file buffers.

-- Clipboard
-- Use the real system clipboard for yanks/pastes. This avoids copying terminal
-- escape sequences, bracketed-paste markers, line numbers, or wrapped screen text
-- when moving code out of/into Neovim inside tmux.
vim.opt.clipboard = "unnamedplus"

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- File handling
vim.opt.autoread = true
vim.opt.updatetime = 300

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Create undo directory if it doesn't exist
local undo_dir = vim.fn.stdpath("data") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end

-- ShaDa (shared data) configuration
-- Reduce write frequency to prevent temp file accumulation
vim.opt.shada = "'100,<50,s10,h"

-- Spelling
vim.opt.spelllang = "en_us"
