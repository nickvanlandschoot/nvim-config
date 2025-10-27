-- Lua language configuration
-- LSP (lua_ls), formatting (stylua)

local M = {}

-- Setup Lua LSP server
function M.setup_lsp(capabilities, on_attach)
  vim.lsp.config.lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  }
end

-- Setup Lua formatting (via conform.nvim)
function M.get_formatters()
  return {
    lua = { "stylua" },
  }
end

return M
