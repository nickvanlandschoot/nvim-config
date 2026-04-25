-- Go language configuration
-- LSP (gopls)

local M = {}

-- Setup Go LSP server
function M.setup_lsp(capabilities, on_attach)
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  vim.lsp.config.gopls = {
    cmd = { mason_bin .. "/gopls" },
    filetypes = { "go", "gomod", "gowork" },
    root_markers = { "go.mod", "go.work", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
      },
    },
  }
end

return M
