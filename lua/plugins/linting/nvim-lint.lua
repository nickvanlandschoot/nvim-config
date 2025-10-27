return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Collect linters from language modules
    local linters_by_ft = {}

    -- Python
    local python = require('languages.python')
    for ft, linters in pairs(python.get_linters()) do
      linters_by_ft[ft] = linters
    end

    -- TypeScript/JavaScript
    local typescript = require('languages.typescript')
    for ft, linters in pairs(typescript.get_linters()) do
      linters_by_ft[ft] = linters
    end

    lint.linters_by_ft = linters_by_ft

    -- Note: Autocmds for linting are in lua/config/autocmds.lua
    -- Keymap for manual linting is in lua/config/keymaps.lua
  end,
}
