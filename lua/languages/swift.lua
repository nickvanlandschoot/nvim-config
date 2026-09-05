-- Swift language configuration
-- LSP (sourcekit-lsp)

local M = {}

-- Setup Swift LSP server.
-- sourcekit-lsp ships with Xcode / Swift toolchains and is not installed by Mason.
function M.setup_lsp(capabilities, on_attach)
  local cmd

  if vim.fn.executable("xcrun") == 1 then
    cmd = { "xcrun", "sourcekit-lsp" }
  else
    cmd = { "sourcekit-lsp" }
  end

  vim.lsp.config.sourcekit = {
    cmd = cmd,
    filetypes = { "swift" },
    root_markers = { "Package.swift", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

return M
