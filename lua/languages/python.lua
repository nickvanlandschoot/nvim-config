-- Python language configuration
-- LSP (Ruff + Pyright), DAP (debugpy), formatting, linting

local M = {}

-- Setup Python LSP servers
function M.setup_lsp(capabilities, on_attach)
  -- Ruff LSP configuration (linter/formatter)
  vim.lsp.config.ruff = {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false

      -- Call base on_attach
      on_attach(client, bufnr)

      local bufopts = { noremap = true, silent = true, buffer = bufnr }

      -- Python-specific keymaps for Ruff
      -- Fix all auto-fixable issues with Ruff
      vim.keymap.set("n", "<leader>tf", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.fixAll" },
            diagnostics = {},
          },
          apply = true,
        })
      end, vim.tbl_extend("force", bufopts, { desc = "Fix all (Ruff)" }))

      -- Extract to function/method (works in visual mode)
      vim.keymap.set("v", "<leader>te", function()
        vim.lsp.buf.code_action()
      end, vim.tbl_extend("force", bufopts, { desc = "Extract function" }))

      -- Show all refactor options (extract, inline, etc.)
      vim.keymap.set({ "n", "v" }, "<leader>tr", function()
        vim.lsp.buf.code_action()
      end, vim.tbl_extend("force", bufopts, { desc = "Refactor options" }))
    end,
  }

  -- Pyright LSP configuration (type checking)
  vim.lsp.config.pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      pyright = {
        -- Use Ruff for organizing imports
        disableOrganizeImports = true,
      },
      python = {
        analysis = {
          typeCheckingMode = "basic",
        },
      },
    },
  }
end

-- Setup Python DAP (Debug Adapter Protocol)
function M.setup_dap()
  local dap = require('dap')

  -- Python configurations (using nvim-dap-python)
  require('dap-python').setup('uv')

  -- Fallback configurations if nvim-dap-python doesn't set them
  if not dap.configurations.python then
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          return 'uv'
        end,
      },
      {
        type = 'python',
        request = 'launch',
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local input = vim.fn.input('Arguments: ')
          return vim.split(input, ' ')
        end,
        pythonPath = function()
          return 'uv'
        end,
      },
    }
  end
end

-- Setup Python formatting (via conform.nvim)
function M.get_formatters()
  return {
    python = { "ruff_format" },
  }
end

-- Setup Python linting (via nvim-lint)
function M.get_linters()
  return {
    python = { "ruff" },
  }
end

return M
