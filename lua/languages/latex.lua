-- LaTeX language configuration
-- LSP (texlab), vimtex integration

local M = {}

-- Setup LaTeX LSP server
function M.setup_lsp(capabilities, on_attach)
  -- texlab LSP would be configured here if enabled
  -- Currently vimtex handles most LaTeX functionality
end

-- VimTeX configuration is in lua/plugins/editor/vimtex.lua

return M
