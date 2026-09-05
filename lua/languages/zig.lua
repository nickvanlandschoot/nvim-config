-- Zig language configuration
-- LSP (zls)

local M = {}

function M.setup_lsp(capabilities, on_attach)
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

  vim.lsp.config.zls = {
    cmd = { mason_bin .. "/zls" },
    filetypes = { "zig", "zir" },
    root_markers = { "build.zig", "build.zig.zon", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

return M
