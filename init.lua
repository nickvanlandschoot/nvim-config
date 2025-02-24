-- Install lazy.nvim if not alrnady installed
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

--import plugins and setting
require("vim-settings")
require("lazy").setup("plugins")

--display numbers 
vim.cmd("set number")
vim.cmd("set relativenumber")

-- Allow for local configs
local project_config = vim.fn.getcwd() .. "/nvim/init.lua"
if vim.fn.filereadable(project_config) == 1 then
  -- Load the project-specific config if it exists
  dofile(project_config)
end

