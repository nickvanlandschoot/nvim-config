-- Minimal init for running tests
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/site]])

-- Add lazy.nvim and plenary
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local plenarypath = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"

vim.opt.rtp:append(".")
vim.opt.rtp:append(lazypath)
vim.opt.rtp:append(plenarypath)

-- Load the plugin
vim.cmd([[runtime! plugin/plenary.vim]])
require("plenary.busted")
