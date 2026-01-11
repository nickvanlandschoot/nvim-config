return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = function()
    -- Collect formatters from language modules
    local formatters_by_ft = {}

    -- Python
    local python = require('languages.python')
    for ft, formatters in pairs(python.get_formatters()) do
      formatters_by_ft[ft] = formatters
    end

    -- TypeScript/JavaScript
    local typescript = require('languages.typescript')
    for ft, formatters in pairs(typescript.get_formatters()) do
      formatters_by_ft[ft] = formatters
    end

    -- Lua
    local lua_lang = require('languages.lua')
    for ft, formatters in pairs(lua_lang.get_formatters()) do
      formatters_by_ft[ft] = formatters
    end

    return {
      formatters_by_ft = formatters_by_ft,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters = {
        prettier = {
          prepend_args = {
            "--single-quote",
            "--jsx-single-quote",
            "--trailing-comma=es5",
            "--semi",
            "--tab-width=2",
          },
        },
      },
    }
  end,
}
