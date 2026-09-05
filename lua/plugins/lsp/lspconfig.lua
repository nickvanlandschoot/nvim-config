return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()

      -- Non-LSP/DAP tools that Mason can install for language modules.
      local ok, registry = pcall(require, "mason-registry")
      if ok then
        for _, tool in ipairs({ "csharp-language-server", "csharpier" }) do
          local package_ok, package = pcall(registry.get_package, tool)
          if package_ok and not package:is_installed() then
            package:install()
          end
        end
      end
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
          "terraformls",
          "tinymist",
          "gopls",
          "zls",
          "csharp_ls",
          "marksman",
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
          "js-debug-adapter",
          "debugpy",
          "netcoredbg",
        },
        automatic_installation = false,
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
        
        -- Disable LSP features for very large files to save memory
        local max_filesize = 500 * 1024 -- 500 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then
          -- Disable semantic tokens and other memory-intensive features for large files
          client.server_capabilities.semanticTokensProvider = nil
        end
      end

      -- The nvim-lspconfig built-in stylua server runs `stylua --lsp`, but the
      -- formatter-only Stylua package installed by Mason does not support that
      -- mode. Keep Stylua as a Conform formatter only.
      vim.lsp.config('stylua', { autostart = false, filetypes = {} })
      vim.lsp.enable('stylua', false)

      -- Setup language-specific LSP servers from language modules
      require('languages.python').setup_lsp(capabilities, on_attach)
      require('languages.lua').setup_lsp(capabilities, on_attach)
      require('languages.terraform').setup_lsp(capabilities, on_attach)
      require('languages.typst').setup_lsp(capabilities, on_attach)
      require('languages.json-yaml').setup_lsp(capabilities, on_attach)
      require('languages.go').setup_lsp(capabilities, on_attach)
      require('languages.zig').setup_lsp(capabilities, on_attach)
      require('languages.swift').setup_lsp(capabilities, on_attach)
      require('languages.csharp').setup_lsp(capabilities, on_attach)
      require('languages.markdown').setup_lsp(capabilities, on_attach)

      -- Enable all configured LSP servers
      vim.lsp.enable({
        'lua_ls',
        'terraformls',
        'tinymist',
        'ruff',
        'pyright',
        'yamlls',
        'jsonls',
        'gopls',
        'zls',
        'sourcekit',
        'csharp_ls',
        'marksman',
      })

      -- Note: TypeScript LSP is handled by typescript-tools.nvim plugin
      -- Note: Keymaps are centralized in lua/config/keymaps.lua
      -- Note: Diagnostics utilities are in lua/utils/diagnostics.lua
    end
  },
}
