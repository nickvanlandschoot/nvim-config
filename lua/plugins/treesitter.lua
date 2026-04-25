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
            additional_vim_regex_highlighting = vim.g.vscode and {} or { 'tex' },
            -- Disable for large files to save memory
            disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,
          },
          indent = { enable = true },
          fold = { enable = not vim.g.vscode },
          -- Incremental selection to reduce memory usage
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm",
            },
          },
          ensure_installed = {
            "lua",
            "vim",
            "vimdoc",
            "query",
            "latex",
            "typst",
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
