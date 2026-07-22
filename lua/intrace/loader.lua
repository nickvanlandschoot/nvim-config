-- Deterministic colorscheme lifecycle shared by every Intrace variant.

local M = {}

function M.load(name, module, background)
  -- Clear the previous name before changing 'background' so Neovim does not
  -- recursively reload a previously active light or dark colorscheme.
  vim.g.colors_name = nil
  vim.o.termguicolors = true
  vim.o.background = background
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = name
  require(module).load()
end

return M
