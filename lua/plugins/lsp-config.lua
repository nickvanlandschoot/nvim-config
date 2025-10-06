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
        ensure_installed = { "ts_ls", "lua_ls", "pyright", "yamlls", "jsonls", "gopls", "terraformls", "tinymist" }
      })
    end,
  },

  -- Add Mason DAP support
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "node2",  -- Node.js debugger
          "chrome", -- Chrome debugger for frontend
          "js-debug-adapter", -- Modern JS/TS debugger
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Add error handling for LSP operations
      local function safe_lsp_operation(operation)
        return function()
          local ok, err = pcall(operation)
          if not ok then
            vim.notify("LSP operation failed: " .. tostring(err), vim.log.levels.WARN)
          end
        end
      end

      -- Custom on_attach function with error handling
      local function on_attach(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        
        -- Safe LSP keymaps
        vim.keymap.set("n", "gd", safe_lsp_operation(vim.lsp.buf.definition), bufopts)
        vim.keymap.set("n", "K", safe_lsp_operation(vim.lsp.buf.hover), bufopts)
        vim.keymap.set("n", "gr", safe_lsp_operation(vim.lsp.buf.references), bufopts)
        vim.keymap.set("n", "gi", safe_lsp_operation(vim.lsp.buf.implementation), bufopts)
        
        if client.server_capabilities.documentFormattingProvider then
          client.server_capabilities.documentFormattingProvider = true
        end
      end

      -- Lua LSP setup
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = {
              globals = { 'vim' },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })

      -- TypeScript LSP setup (updated to ts_ls)
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        settings = {
          typescript = {
            format = { enable = true },
            inlayHints = {
              includeInlayParameterNameHints = 'literal',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
              jsxAttributeCompletionStyle = "auto",
            },
          },
          javascript = {
            format = { enable = true },
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          completions = {
            completeFunctionCalls = true
          }
        },
        init_options = {
          preferences = {
            disableSuggestions = false,
            quotePreference = "auto",
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            includeCompletionsWithSnippetText = true,
            includeAutomaticOptionalChainCompletions = true,
          }
        },
        on_attach = function(client, bufnr)
          -- Call the general on_attach function
          on_attach(client, bufnr)
          
          -- TypeScript specific settings
          local bufopts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "<leader>to", "<cmd>TypescriptOrganizeImports<CR>", bufopts)
          vim.keymap.set("n", "<leader>tr", "<cmd>TypescriptRenameFile<CR>", bufopts)
          vim.keymap.set("n", "<leader>ta", "<cmd>TypescriptAddMissingImports<CR>", bufopts)
          vim.keymap.set("n", "<leader>tu", "<cmd>TypescriptRemoveUnused<CR>", bufopts)
        end,
      })

      -- Terraform LSP setup
      lspconfig.terraformls.setup({
        capabilities = capabilities,
        filetypes = { "terraform", "tf", "hcl" },
        on_attach = on_attach,
      })

      -- Typst LSP (tinymist)
      lspconfig.tinymist.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { "typst" },
      })

      -- Other LSP servers
      for _, server in ipairs({ "pyright", "yamlls", "jsonls", "gopls" }) do
        lspconfig[server].setup({ capabilities = capabilities })
      end

      -- Custom keybindings with error handling
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', 'gd', safe_lsp_operation(vim.lsp.buf.definition), opts)
      vim.keymap.set('n', '<leader>rn', safe_lsp_operation(vim.lsp.buf.rename), opts)
      vim.keymap.set('n', '<leader>ca', safe_lsp_operation(vim.lsp.buf.code_action), opts)
      vim.keymap.set('n', "K", safe_lsp_operation(vim.lsp.buf.hover), opts)

      -- Diagnostic keymappings
      vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

      local function copy_all_diagnostics()
        local diagnostics = vim.diagnostic.get(0) -- Get diagnostics for current buffer
        if #diagnostics == 0 then
          vim.notify("No diagnostics to copy", vim.log.levels.INFO)
          return
        end
        
        -- Severity mapping
        local severity_map = {
          [vim.diagnostic.severity.ERROR] = "ERROR",
          [vim.diagnostic.severity.WARN] = "WARN",
          [vim.diagnostic.severity.INFO] = "INFO",
          [vim.diagnostic.severity.HINT] = "HINT"
        }
        
        local lines = {}
        for _, diag in ipairs(diagnostics) do
          local severity = severity_map[diag.severity] or "UNKNOWN"
          local filename = vim.fn.bufname(diag.bufnr)
          if filename == "" then
            filename = "[No Name]"
          end
          table.insert(lines, string.format("[%s] %s:%d:%d %s", severity, filename, diag.lnum + 1, diag.col + 1, diag.message))
        end
        local text_to_copy = table.concat(lines, "\n")
        vim.fn.setreg('"', text_to_copy) -- Copy to default register
        vim.fn.setreg('+', text_to_copy) -- Copy to system clipboard
        vim.notify("Copied " .. #diagnostics .. " diagnostic(s) to clipboard", vim.log.levels.INFO)
      end

      vim.keymap.set('n', '<leader>dg', copy_all_diagnostics, opts)
      

    end
  },
}

