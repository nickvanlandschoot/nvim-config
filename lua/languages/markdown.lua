-- Markdown language configuration
-- LSP (marksman)

local M = {}

-- Setup Markdown LSP server
function M.setup_lsp(capabilities, on_attach)
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

  vim.lsp.config.marksman = {
    cmd = { mason_bin .. "/marksman" },
    filetypes = { "markdown", "md" },
    root_markers = { ".git", "index.md", ".marksman.toml" },
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

return M
