return {
  -- Typst syntax and filetype
  "kaarmu/typst.vim",
  -- Typst live preview
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    cmd = { "TypstPreview", "TypstPreviewStop", "TypstPreviewFollowCursor", "TypstPreviewUpdate" },
    opts = {},
    config = function()
      -- Initialize plugin if setup is available
      local ok, tp = pcall(require, "typst-preview")
      if ok and type(tp.setup) == "function" then
        tp.setup({})
      end
      -- Buffer-local keymaps for Typst files; prefer Lua API, fallback to commands
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function(args)
          local buf = args.buf
          local ok_local, tp_local = pcall(require, "typst-preview")
          -- Open
          if ok_local and type(tp_local.open) == "function" then
            vim.keymap.set("n", "<leader>tp", tp_local.open, { buffer = buf, desc = "Open Typst preview" })
          else
            vim.keymap.set("n", "<leader>tp", ":TypstPreview<CR>", { buffer = buf, desc = "Open Typst preview" })
          end
          -- Close
          if ok_local and type(tp_local.close) == "function" then
            vim.keymap.set("n", "<leader>tq", tp_local.close, { buffer = buf, desc = "Close Typst preview" })
          else
            vim.keymap.set("n", "<leader>tq", ":TypstPreviewStop<CR>", { buffer = buf, desc = "Close Typst preview" })
          end
          -- Follow cursor (command provided by the plugin)
          vim.keymap.set("n", "<leader>tf", ":TypstPreviewFollowCursor<CR>", { buffer = buf, desc = "Typst preview follow cursor" })
        end,
      })
    end,
    build = "typst-preview update",
  },
}

