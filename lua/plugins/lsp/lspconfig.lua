return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
          "ruff",
          "yamlls",
          "jsonls",
          "gopls",
          "terraformls",
          "tinymist"
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "node2",
          "chrome",
          "js-debug-adapter",
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- Start with default LSP capabilities, then merge blink.cmp capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())

      -- Base on_attach function (no keymaps - those are in keymaps.lua)
      local function on_attach(client, bufnr)
        if client.server_capabilities.documentFormattingProvider then
          client.server_capabilities.documentFormattingProvider = true
        end
      end

      -- Setup language-specific LSP servers from language modules
      require('languages.python').setup_lsp(capabilities, on_attach)
      require('languages.lua').setup_lsp(capabilities, on_attach)
      require('languages.go').setup_lsp(capabilities, on_attach)
      require('languages.terraform').setup_lsp(capabilities, on_attach)
      require('languages.typst').setup_lsp(capabilities, on_attach)
      require('languages.json-yaml').setup_lsp(capabilities, on_attach)

      -- Enable all configured LSP servers
      vim.lsp.enable({
        'lua_ls',
        'terraformls',
        'tinymist',
        'ruff',
        'pyright',
        'yamlls',
        'jsonls',
        'gopls'
      })

      -- Note: TypeScript LSP is handled by typescript-tools.nvim plugin
      -- Note: Keymaps are centralized in lua/config/keymaps.lua
      -- Note: Diagnostics utilities are in lua/utils/diagnostics.lua
    end
  },
}
