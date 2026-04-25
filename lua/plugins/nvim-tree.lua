return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = {
        width = 35,
        side = "left",
        number = false,
        relativenumber = true,
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      filters = {
        dotfiles = false,
        custom = { ".git", "node_modules", ".cache" },
      },
      git = {
        enable = true,
        ignore = false,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
        },
      },
      update_focused_file = {
        enable = true,
        update_cwd = false,
      },
    },
    config = function(_, opts)
      -- Disable netrw (recommended by nvim-tree)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup(opts)

      -- Keymaps
      local keymap_opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", vim.tbl_extend("force", keymap_opts, { desc = "Toggle file tree" }))
      vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", vim.tbl_extend("force", keymap_opts, { desc = "Find file in tree" }))
    end,
  },
}
