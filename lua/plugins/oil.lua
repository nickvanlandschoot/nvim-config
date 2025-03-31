return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 4,
        max_width = 80,
        max_height = 30,
        border = "rounded",
      },
      keymaps = {
        ["q"] = "actions.close",
        ["<C-s>"] = "actions.select_split",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-t>"] = "actions.select_tab",
        ["<C-r>"] = "actions.refresh",
        ["H"] = "actions.parent",
        ["L"] = "actions.select",
        ["-"] = "actions.parent",
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil File Explorer" })
    end,
  },
}

