-- Typst language configuration
-- LSP (tinymist)

local M = {}

-- Setup Typst LSP server
function M.setup_lsp(capabilities, on_attach)
  vim.lsp.config.tinymist = {
    cmd = { 'tinymist' },
    filetypes = { "typst" },
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

return M
