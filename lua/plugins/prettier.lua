return {
  'sindrets/diffview.nvim',
  requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    require("diffview").setup({
      diff_binaries = false,         -- Skip binary files in diffs
      enhanced_diff_hl = true,       -- Better diff highlighting
      use_icons = true,             -- Enable icons for a more intuitive interface
      file_panel = {
        listing_style = "tree",     -- File panel listing style
        tree_options = {
          flatten_dirs = true,      -- Flatten directory structure for easier navigation
        },
        win_config = {
          position = "left",        -- Position of the file panel window
          width = 35,
        },
      },
      commit_log_panel = {
        win_config = {
          position = "bottom",      -- Position of the commit log panel
          height = 16,
        },
      },
    })
  end
}

