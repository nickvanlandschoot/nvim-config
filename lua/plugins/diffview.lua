return {
  'sindrets/diffview.nvim',
  requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    require("diffview").setup({
      diff_binaries = false,
      enhanced_diff_hl = true,
      use_icons = true,
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      commit_log_panel = {
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
    })

    vim.api.nvim_set_keymap('n', '<leader>do', ':DiffviewOpen<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>dc', ':DiffviewClose<CR>', { noremap = true, silent = true })
  end,
}
