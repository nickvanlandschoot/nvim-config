return {
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local config = require("nvim-treesitter.configs")
        config.setup({
          auto_install = true,
          highlight = { 
            enable = not vim.g.vscode,
            additional_vim_regex_highlighting = vim.g.vscode and {} or { 'tex' }
          },
          indent = { enable = true },
          fold = { enable = not vim.g.vscode },
          ensure_installed = {
            "lua",
            "vim",
            "vimdoc",
            "query",
            "latex",
            "markdown",
            "markdown_inline",
            "python",
            "javascript",
            "typescript",
            "tsx",
            "html",
            "css",
            "json",
            "yaml",
          },
        })
      end
    }
  }
