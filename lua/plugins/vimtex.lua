-- LaTeX: VimTeX + Sioyek (SyncTeX forward/inverse search).
-- Requires: latexmk, a TeX distribution, and `sioyek` on PATH.
-- In Sioyek, toggle SyncTeX mode with F4 if forward search seems inert.
-- Default VimTeX maps use <localleader> (often \): e.g. \ll compile, \lv view, \le quickfix.

return {
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex" },
    init = function()
      vim.g.vimtex_view_method = "sioyek"
      vim.g.vimtex_compiler_method = "latexmk"
      -- 0 = only populate quickfix on errors (not on warnings)
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
