return {
  "prettier/vim-prettier",
  build = "npm install",
  ft = { "javascript", "typescript", "json", "css", "html" }, -- add filetypes as needed
  config = function()
    -- Optionally enable/disable autoformat on save
    vim.g["prettier#autoformat"] = 1  -- or set to 0 if you don't want autoformatting
  end,
}

