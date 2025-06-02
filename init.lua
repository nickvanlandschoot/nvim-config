vim.g.mapleader = ' '

-- Detect if we're running in VSCode
local in_vscode = vim.g.vscode ~= nil

-- Basic settings that work in both VSCode and regular Neovim
vim.opt.tabstop       = 2    -- number of visual spaces per TAB
vim.opt.softtabstop   = 2    -- number of spaces for a <Tab> in insert mode
vim.opt.shiftwidth    = 2    -- size of an indent
vim.opt.expandtab     = true -- convert tabs to spaces
vim.opt.smartindent   = true
vim.opt.autoindent    = true

if not in_vscode then
  -- Settings that only apply to regular Neovim (not VSCode)
  require("vim-settings")
  
  vim.o.autoread = true -- Automatically read files when they change outside of Vim

  vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained", "CursorHold" },
    {
      pattern = "*",
      callback = function()
        if vim.fn.mode() ~= "c" then
          vim.cmd("silent! checktime")
        end
      end,
    }
  )

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
else
  -- VSCode-specific configuration
  require("vscode-settings")
  
  -- Install lazy.nvim for VSCode-compatible plugins
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
  
  -- Load only VSCode-compatible plugins
  require("lazy").setup("plugins.vscode-plugins", {
    git = {
      url_format = "https://github.com/%s.git",
    },
  })
end

