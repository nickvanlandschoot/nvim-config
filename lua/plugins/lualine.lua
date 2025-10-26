return {
  "nvim-lualine/lualine.nvim",
  config = function()
    -- Create custom theme that uses Aura colors
    local function get_aura_theme()
      -- Helper to convert decimal to hex string for lualine
      local function to_hex(color)
        if not color then return nil end
        return string.format("#%06x", color)
      end

      -- Extract colors from highlight groups
      local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
      local statusline = vim.api.nvim_get_hl(0, { name = "StatusLine" })
      local visual = vim.api.nvim_get_hl(0, { name = "Visual" })
      local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
      local search = vim.api.nvim_get_hl(0, { name = "Search" })
      local diffadd = vim.api.nvim_get_hl(0, { name = "DiffAdd" })
      local diffchange = vim.api.nvim_get_hl(0, { name = "DiffChange" })
      local diffdelete = vim.api.nvim_get_hl(0, { name = "DiffDelete" })

      -- Build color palette with proper fallbacks
      -- Use Normal bg for sections b/c to avoid light StatusLine backgrounds in dark mode
      -- Convert all colors to hex strings for lualine
      local colors = {
        bg = to_hex(normal.bg),
        fg = to_hex(normal.fg),
        visual_bg = to_hex(visual.bg or cursorline.bg),
        visual_fg = to_hex(visual.fg) or to_hex(normal.fg),
        search_bg = to_hex(search.bg) or to_hex(visual.bg),
        search_fg = to_hex(search.fg) or to_hex(normal.fg),
        add_bg = to_hex(diffadd.bg) or to_hex(diffadd.fg),
        change_bg = to_hex(diffchange.bg) or to_hex(diffchange.fg),
        delete_bg = to_hex(diffdelete.bg) or to_hex(diffdelete.fg),
      }

      -- Use Normal bg for sections b and c to maintain dark background
      -- Use distinct colors for section a based on mode
      return {
        normal = {
          a = { bg = colors.visual_bg, fg = colors.fg, gui = 'bold' },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        insert = {
          a = { bg = colors.add_bg, fg = colors.fg, gui = 'bold' },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        visual = {
          a = { bg = colors.change_bg, fg = colors.fg, gui = 'bold' },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        replace = {
          a = { bg = colors.delete_bg, fg = colors.fg, gui = 'bold' },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        command = {
          a = { bg = colors.search_bg, fg = colors.search_fg, gui = 'bold' },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        inactive = {
          a = { bg = colors.bg, fg = colors.fg },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
      }
    end

    require("lualine").setup({
      options = {
        theme = get_aura_theme(),
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
        }
      }
    })

    -- Ensure lualine refreshes after colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        require("lualine").setup({
          options = {
            theme = get_aura_theme(),
          }
        })
      end,
    })
  end
}
