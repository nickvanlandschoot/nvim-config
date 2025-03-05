return {
  "romgrk/barbar.nvim",

  dependencies = {
  'lewis6991/gitsigns.nvim',
  'nvim-tree/nvim-web-devicons'
  },

  config = function()
    require("barbar").setup({
      insert_at_start=true,
      animation=true,
      numbers=true
    })

    -- Key mappings for buffer navigation
    local opts = { noremap = true, silent = true }

    vim.keymap.set('n', '<Tab>', '<Cmd>BufferNext<CR>', opts)         -- Next buffer
    vim.keymap.set('n', '<S-Tab>', '<Cmd>BufferPrevious<CR>', opts)   -- Previous buffer

    for i = 1, 9 do
      vim.keymap.set('n', '<leader>'..i, '<Cmd>BufferGoto '..i..'<CR>', opts)
    end

    vim.keymap.set('n', '<leader>q', '<Cmd>BufferClose<CR>', opts)
  end
}

