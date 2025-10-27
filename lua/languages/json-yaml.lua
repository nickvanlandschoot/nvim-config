-- JSON and YAML language configuration
-- LSP (jsonls, yamlls)

local M = {}

-- Setup JSON and YAML LSP servers
function M.setup_lsp(capabilities, on_attach)
  -- YAML LSP configuration
  vim.lsp.config.yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
    capabilities = capabilities,
    on_attach = on_attach,
  }

  -- JSON LSP configuration
  vim.lsp.config.jsonls = {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

return M
