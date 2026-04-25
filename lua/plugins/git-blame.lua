return {
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    config = function()
      require("gitblame").setup({
        enabled = true,
        date_format = "%Y-%m-%d %H:%M",
        virtual_text_column = 80, -- Show blame after column 80
        highlight_group = "Comment", -- Use Comment highlight group
        delay = 1000, -- Delay in milliseconds before showing blame
      })
    end,
    keys = {
      { "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
    },
  },
}
