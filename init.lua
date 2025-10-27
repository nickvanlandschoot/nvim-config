-- Neovim Configuration
-- Organized structure: config/, plugins/, languages/, utils/

-- Load core configuration
require("config.settings")    -- Vim options and settings
require("config.keymaps")     -- All keymaps centralized
require("config.autocmds")    -- All autocommands

-- Install lazy.nvim plugin manager
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

-- Setup lazy.nvim with HTTPS
require("lazy").setup("plugins", {
  git = {
    url_format = "https://github.com/%s.git",
  },
})

-- Set colorscheme
vim.cmd([[colorscheme intrace]])
