-- JSON and YAML language configuration
-- LSP (jsonls, yamlls)

local M = {}

-- Setup JSON and YAML LSP servers
function M.setup_lsp(capabilities, on_attach)
  -- YAML LSP configuration with schema support
  vim.lsp.config.yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      yaml = {
        schemaStore = {
          enable = true,  -- Enable schema store for common schemas
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
        schemas = {
          -- Add custom schemas here if needed
          -- Example:
          -- ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        },
        format = {
          enable = true,
          singleQuote = false,
          bracketSpacing = true,
        },
        validate = true,
        hover = true,
        completion = true,
        customTags = {
          -- Support for custom YAML tags (e.g., CloudFormation)
          "!fn",
          "!And",
          "!If",
          "!Not",
          "!Equals",
          "!Or",
          "!FindInMap sequence",
          "!Base64",
          "!Cidr",
          "!Ref",
          "!Sub",
          "!GetAtt",
          "!GetAZs",
          "!ImportValue",
          "!Select",
          "!Split",
          "!Join sequence",
        },
      },
    },
  }

  -- JSON LSP configuration with schema support
  vim.lsp.config.jsonls = {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
        format = {
          enable = true,
        },
      },
    },
  }
end

return M
