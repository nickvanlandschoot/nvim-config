return {
  'lervag/vimtex',
  lazy = false, -- Load immediately for better LaTeX support
  init = function()
    -- Disable Treesitter for LaTeX files
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_syntax_conceal_disable = 1

    -- Set explicit paths to LaTeX executables
    vim.g.vimtex_compiler_latexmk = {
      executable = '/Library/TeX/texbin/latexmk',
      build_dir = '',
      continuous = 1,
      callback = 1,
      options = {
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
        '-shell-escape',
        '-pdf',
        '-pdflatex="/Library/TeX/texbin/pdflatex -file-line-error -synctex=1 -interaction=nonstopmode -shell-escape"',
      },
    }

    -- View method configuration
    vim.g.vimtex_view_method = 'zathura' -- PDF viewer
    vim.g.vimtex_view_general_viewer = 'zathura'
    vim.g.vimtex_view_general_options = '--synctex-editor-command "nvim --headless -es --cmd \"lua require(\'vimtex\').viewer().synctex()\" %{input} %{line}"'

    -- General settings
    vim.g.vimtex_quickfix_mode = 1 -- Show quickfix window for errors
    vim.g.vimtex_quickfix_open_on_warning = 1
    vim.g.vimtex_quickfix_ignore_filters = {
      'Underfull',
      'Overfull',
      'Package hyperref Warning',
    }

    -- Conceal settings
    vim.g.vimtex_syntax_conceal = {
      accents = 1,
      ligatures = 1,
      cites = 1,
      fancy = 1,
      spacing = 1,
      math_bounds = 1,
      math_delimiters = 1,
      math_fracs = 1,
      mathsuperscripts = 1,
      math_subscripts = 1,
      math_symbols = 1,
      sections = 0,
      styles = 1,
    }

    -- Key mappings
    vim.keymap.set('n', '<leader>ll', '<plug>(vimtex-compile)', { desc = 'Compile LaTeX document' })
    vim.keymap.set('n', '<leader>lv', '<plug>(vimtex-view)', { desc = 'View PDF' })
    vim.keymap.set('n', '<leader>lc', '<plug>(vimtex-clean-full)', { desc = 'Clean auxiliary files' })
    vim.keymap.set('n', '<leader>lt', '<plug>(vimtex-toc-toggle)', { desc = 'Toggle Table of Contents' })
    vim.keymap.set('n', '<leader>le', '<plug>(vimtex-error)', { desc = 'Show errors' })
  end,
} 