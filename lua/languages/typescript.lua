-- TypeScript/JavaScript language configuration
-- LSP (typescript-tools), DAP (js-debug-adapter), formatting (prettier), linting (eslint)

local M = {}

-- TypeScript LSP is configured separately via typescript-tools.nvim plugin
-- See lua/plugins/lsp/typescript-tools.lua

-- Setup TypeScript/JavaScript DAP configurations
function M.setup_dap()
  local dap = require('dap')

  -- VS Code JS Debug Adapter (modern, works for JS/TS/Node)
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = {vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', "${port}"},
    }
  }

  -- Chrome/Browser debugging
  dap.adapters["pwa-chrome"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = {vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', "${port}"},
    }
  }

  -- JavaScript configurations
  dap.configurations.javascript = {
    {
      name = 'Launch Node.js (current file)',
      type = 'pwa-node',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      name = 'Launch Node.js with args',
      type = 'pwa-node',
      request = 'launch',
      program = '${file}',
      args = function()
        local input = vim.fn.input('Arguments: ')
        return vim.split(input, ' ')
      end,
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      name = 'Attach to Node.js process',
      type = 'pwa-node',
      request = 'attach',
      processId = require'dap.utils'.pick_process,
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
    },
    {
      name = 'Debug React App (Chrome)',
      type = 'pwa-chrome',
      request = 'launch',
      url = 'http://localhost:3000',
      webRoot = '${workspaceFolder}/src',
      sourceMaps = true,
      userDataDir = false,
    }
  }

  -- TypeScript configurations
  dap.configurations.typescript = {
    {
      name = 'Launch TypeScript (ts-node)',
      type = 'pwa-node',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
      runtimeExecutable = 'npx',
      runtimeArgs = {'ts-node'},
    },
    {
      name = 'Launch TypeScript (tsx)',
      type = 'pwa-node',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
      runtimeExecutable = 'npx',
      runtimeArgs = {'tsx'},
    },
    {
      name = 'Launch compiled JavaScript',
      type = 'pwa-node',
      request = 'launch',
      program = '${workspaceFolder}/dist/${fileBasenameNoExtension}.js',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
      outFiles = {"${workspaceFolder}/dist/**/*.js"},
    },
    {
      name = 'Attach to TypeScript process',
      type = 'pwa-node',
      request = 'attach',
      processId = require'dap.utils'.pick_process,
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
    }
  }

  -- React TypeScript configurations
  dap.configurations.typescriptreact = {
    {
      name = 'Debug React TypeScript App',
      type = 'pwa-chrome',
      request = 'launch',
      url = 'http://localhost:3000',
      webRoot = '${workspaceFolder}/src',
      sourceMaps = true,
      userDataDir = false,
    },
    {
      name = 'Debug Next.js (dev)',
      type = 'pwa-node',
      request = 'launch',
      program = '${workspaceFolder}/node_modules/.bin/next',
      args = {'dev'},
      cwd = '${workspaceFolder}',
      sourceMaps = true,
      console = 'integratedTerminal',
    },
    {
      name = 'Debug Next.js (custom port)',
      type = 'pwa-node',
      request = 'launch',
      program = '${workspaceFolder}/node_modules/.bin/next',
      args = {'dev', '--port', '3001'},
      cwd = '${workspaceFolder}',
      sourceMaps = true,
      console = 'integratedTerminal',
    }
  }

  -- JSX configurations (same as React TypeScript)
  dap.configurations.javascriptreact = dap.configurations.typescriptreact
end

-- Setup TypeScript/JavaScript formatting (via conform.nvim)
function M.get_formatters()
  return {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    html = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
  }
end

-- Setup TypeScript/JavaScript linting (via nvim-lint)
function M.get_linters()
  return {
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
  }
end

return M
