return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    local function find_up(filename, start_dir)
      local dir = start_dir or vim.fn.expand('%:p:h')
      local found = vim.fn.findfile(filename, dir .. ';')
      if found == '' then
        return nil
      end
      return vim.fn.fnamemodify(found, ':p')
    end

    local function mypy_local_root()
      local config = find_up('mypy.local.ini')
      if not config then
        return nil
      end
      return vim.fn.fnamemodify(config, ':p:h')
    end

    lint.linters.mypy_local = vim.tbl_deep_extend('force', lint.linters.mypy, {
      cmd = function()
        local root = mypy_local_root()
        if not root then
          return 'true'
        end
        local local_mypy = root .. '/.venv/bin/mypy'
        if vim.fn.executable(local_mypy) == 1 then
          return local_mypy
        end
        return 'mypy'
      end,
      args = function()
        local root = mypy_local_root()
        if not root then
          return {}
        end
        return {
          '--config-file', root .. '/mypy.local.ini',
          '--show-column-numbers',
          '--show-error-end',
          '--hide-error-context',
          '--no-color-output',
          '--no-error-summary',
          '--no-pretty',
        }
      end,
    })

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
