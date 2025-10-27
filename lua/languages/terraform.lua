-- Terraform language configuration
-- LSP (terraformls)

local M = {}

-- Setup Terraform LSP server
function M.setup_lsp(capabilities, on_attach)
  vim.lsp.config.terraformls = {
    cmd = { 'terraform-ls', 'serve' },
    filetypes = { "terraform", "tf", "hcl" },
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

return M
