-- Go language configuration
-- LSP (gopls), DAP (delve via nvim-dap-go), formatting (gofmt)

local M = {}

-- Setup Go LSP server
function M.setup_lsp(capabilities, on_attach)
  vim.lsp.config.gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

-- Setup Go DAP (via nvim-dap-go)
function M.setup_dap()
  require('dap-go').setup()
end

-- Setup Go formatting (via conform.nvim)
function M.get_formatters()
  return {
    go = { "gofmt" },
  }
end

return M
