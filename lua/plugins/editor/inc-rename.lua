return {
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      {
        "<leader>lr",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "LSP Rename (with preview)"
      },
    },
    config = function()
      require("inc_rename").setup()
    end,
  },
}
