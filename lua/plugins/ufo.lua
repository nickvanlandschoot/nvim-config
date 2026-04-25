return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      vim.o.foldcolumn = '0' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Using ufo provider need remap `zR` and `zM`
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      
      -- Option 1: Using treesitter and lsp as fold providers
      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end,
        -- Close folds when leaving buffer to save memory
        close_fold_kinds_for_ft = {
          ['*'] = {'imports', 'comment'},
        },
        -- Preview window configuration to reduce memory
        preview = {
          win_config = {
            winhighlight = 'Normal:Folded',
            winblend = 0
          }
        }
      })
    end
  }
} 