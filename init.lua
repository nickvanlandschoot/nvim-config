vim.g.mapleader = ' '

-- Basic settings that work in both VSCode and regular Neovim
vim.opt.tabstop       = 2    -- number of visual spaces per TAB
vim.opt.softtabstop   = 2    -- number of spaces for a <Tab> in insert mode
vim.opt.shiftwidth    = 2    -- size of an indent
vim.opt.expandtab     = true -- convert tabs to spaces
vim.opt.smartindent   = true
vim.opt.autoindent    = true

require("vim-settings")

-- Basic file watching
vim.opt.autoread = true
vim.opt.updatetime = 300

-- Basic clipboard integration
vim.opt.termguicolors = true


-- Install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure Lazy to use HTTPS instead of SSH for regular Neovim
require("lazy").setup("plugins", {
  git = {
    url_format = "https://github.com/%s.git",
  },
})
