return {
  dir = vim.fn.expand("~/Projects/nvim-plugins/prowritingaid.nvim"),
  name = "prowritingaid.nvim",
  dev = true,
  lazy = true,
  cmd = { "ProWritingAid" },
  config = function()
    require("prowritingaid").setup()
  end,
}
