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
        ensure_installed = { "lua_ls", "ts_ls", "pyright", "ruff", "yamlls", "jsonls", "gopls", "terraformls", "tinymist" },
        automatic_installation = true,
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

      -- Lua LSP configuration
      vim.lsp.config.lua_ls = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
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
      }

      -- TypeScript LSP is now handled by typescript-tools.nvim plugin
      -- See lua/plugins/typescript-tools.lua for configuration

      -- Terraform LSP configuration
      vim.lsp.config.terraformls = {
        cmd = { 'terraform-ls', 'serve' },
        filetypes = { "terraform", "tf", "hcl" },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Typst LSP (tinymist) configuration
      vim.lsp.config.tinymist = {
        cmd = { 'tinymist' },
        filetypes = { "typst" },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Ruff LSP configuration (Python linter/formatter)
      vim.lsp.config.ruff = {
        cmd = { 'ruff', 'server' },
        filetypes = { 'python' },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false

          on_attach(client, bufnr)

          local bufopts = { noremap = true, silent = true, buffer = bufnr }

          -- Fix all auto-fixable issues with Ruff
          vim.keymap.set("n", "<leader>tf", function()
            vim.lsp.buf.code_action({
              context = {
                only = { "source.fixAll" },
                diagnostics = {},
              },
              apply = true,
            })
          end, bufopts)

          -- Extract to function/method (works in visual mode)
          vim.keymap.set("v", "<leader>te", function()
            vim.lsp.buf.code_action()
          end, bufopts)

          -- Show all refactor options (extract, inline, etc.)
          vim.keymap.set({ "n", "v" }, "<leader>tr", function()
            vim.lsp.buf.code_action()
          end, bufopts)

          -- Auto-fix and format on save with Ruff LSP
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.code_action({
                context = {
                  only = { "source.fixAll", "source.organizeImports" },
                  diagnostics = {},
                },
                apply = true,
              })
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      }

      -- Python LSP configuration (Pyright for type checking)
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

      -- YAML LSP configuration
      vim.lsp.config.yamlls = {
        cmd = { 'yaml-language-server', '--stdio' },
        filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
        capabilities = capabilities,
      }

      -- JSON LSP configuration
      vim.lsp.config.jsonls = {
        cmd = { 'vscode-json-language-server', '--stdio' },
        filetypes = { 'json', 'jsonc' },
        capabilities = capabilities,
      }

      -- Go LSP configuration
      vim.lsp.config.gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        capabilities = capabilities,
      }

      -- Enable all configured LSP servers
      vim.lsp.enable({ 'lua_ls', 'terraformls', 'tinymist', 'ruff', 'pyright', 'yamlls', 'jsonls', 'gopls' })

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

