return {
  -- Re-enable the catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    enabled = true, -- Enable catppuccin
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
      -- Set colorscheme to catppuccin
      vim.cmd("colorscheme catppuccin")
    end,
  },
  
  -- Keep onedark but disable it
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    enabled = false, -- Disable onedark
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = false,
        term_colors = true,
      })
    end,
  },
}
