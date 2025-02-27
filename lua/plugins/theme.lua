return {
  -- Keep the catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    -- Disabled to use onedark instead
    enabled = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
    end,
  },
  
  -- Add the onedark theme
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "darker", -- Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer'
        transparent = false,
        term_colors = true,
        -- Other options you might want to customize
      })
      -- Set colorscheme after options
      vim.cmd("colorscheme onedark")
    end,
  },
} 