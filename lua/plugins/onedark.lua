return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "dark", -- Options: 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer'
      transparent = false,
      term_colors = true,
      ending_tildes = false,
      cmp_itemkind_reverse = false,

      -- Toggle theme style
      toggle_style_key = nil, -- Set to keybinding if you want to toggle styles
      toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer" },

      -- Change code style
      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "bold",
        strings = "none",
        variables = "none",
      },

      -- Lualine options
      lualine = {
        transparent = false,
      },

      -- Custom highlights
      colors = {},
      highlights = {},

      -- Diagnostics
      diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
      },
    })
  end,
}
