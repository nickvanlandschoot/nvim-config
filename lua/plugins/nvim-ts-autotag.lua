return {
  "windwp/nvim-ts-autotag",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
      per_filetype = {
        ["html"] = {
          enable_close = true,
        },
        ["javascriptreact"] = {
          enable_close = true,
        },
        ["typescriptreact"] = {
          enable_close = true,
        },
        ["xml"] = {
          enable_close = true,
        },
      },
    })
  end,
}
