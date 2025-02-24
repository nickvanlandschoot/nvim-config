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

	--Install different LSPs
	ensure_installed = { "lua_ls", "ts_ls", "pyright", "yamlls", "jsonls" }
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp' },

    servers = {
      lua_ls = {},
      ts_ls = {},
      pyright = {},
      yaamlls = {},
      jsonls = {},
    },

    config = function(_, servers)
      local lspconfig = require("lspconfig")

      for server, config in pairs(servers) do
	local capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
	config.capabilities = capabilities
	lspconfig[server].setup(config)

      end

      --Setup LSPs
      local util = require("lspconfig.util")

      lspconfig.lua_ls.setup({})
      lspconfig.pyright.setup({})
      lspconfig.yamlls.setup({})
      lspconfig.jsonls.setup({})

      lspconfig.ts_ls.setup({
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	on_attach = function(client, bufnr)
	  -- If using a separate formatter (like prettier), disable tsserver's formatting:
	  client.server_capabilities.documentFormattingProvider = false
	  local bufopts = { noremap = true, silent = true, buffer = bufnr }
	  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	end,
      })

      --Custom keybindings
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
    end
  ;}
}

