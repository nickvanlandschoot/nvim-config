-- Set dark background for catppuccin
vim.o.background = "dark"

return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    enabled = false,  -- Disabled in favor of catppuccin
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = false,
        term_colors = true,
      })
    end,
  },
  
  -- GitHub theme as backup option
  {
    "projekt0n/github-nvim-theme",
    priority = 900,
    enabled = false,  -- Disabled but available
    config = function()
      require("github-theme").setup({})
      -- vim.cmd("colorscheme github_dark")
    end,
  },
}
