return {
  "pmizio/typescript-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
    "saghen/blink.cmp",
  },
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  keys = {
    { "<leader>to", "<cmd>TSToolsOrganizeImports<cr>", desc = "Organize Imports" },
    { "<leader>ts", "<cmd>TSToolsSortImports<cr>", desc = "Sort Imports" },
    { "<leader>tru", "<cmd>TSToolsRemoveUnused<cr>", desc = "Remove Unused" },
    { "<leader>trf", "<cmd>TSToolsRemoveUnusedImports<cr>", desc = "Remove Unused Imports" },
    { "<leader>trf", "<cmd>TSToolsFixAll<cr>", desc = "Fix All" },
    { "<leader>tai", "<cmd>TSToolsAddMissingImports<cr>", desc = "Add Missing Imports" },
    { "<leader>tgd", "<cmd>TSToolsGoToSourceDefinition<cr>", desc = "Go to Source Definition" },
    { "<leader>tfu", "<cmd>TSToolsFileReferences<cr>", desc = "File References" },
    { "<leader>trn", "<cmd>TSToolsRenameFile<cr>", desc = "Rename File" },
  },
  config = function()
    -- Start with default LSP capabilities, then merge blink.cmp capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())

    require("typescript-tools").setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }

        -- TypeScript-specific keymaps
        vim.keymap.set("n", "gD", "<cmd>TSToolsGoToSourceDefinition<cr>", vim.tbl_extend("force", bufopts, { desc = "Go to source definition" }))

        -- Show all code actions (refactor, quickfix, etc.)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", bufopts, { desc = "Code action" }))
      end,
      settings = {
        -- Expose as global for debugging
        expose_as_code_action = "all",

        -- TSServer settings
        tsserver_max_memory = 8192,
        tsserver_format_options = {
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = true,
        },
        tsserver_file_preferences = {
          -- Inlay hints
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,

          -- Import preferences
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          includeCompletionsWithInsertText = true,
          includeAutomaticOptionalChainCompletions = true,

          -- Other preferences
          quotePreference = "single",
          importModuleSpecifierPreference = "relative",
          importModuleSpecifierEnding = "minimal",
          includePackageJsonAutoImports = "auto",
        },

        -- Code lens
        tsserver_plugins = {
          -- Add plugins here if needed
        },

        -- Separate diagnostic config
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",

        -- JSX/TSX settings
        jsx_close_tag = {
          enable = true,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
      },
    })
  end,
}
