return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  opts = {
    heading = {
      -- Disable background colors for headings
      backgrounds = {},
      -- Use foreground colors and icons instead
      foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
      },
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    },
  },
  config = function(_, opts)
    require('render-markdown').setup(opts)

    -- Set custom highlight colors for headers (no background, just foreground color and size)
    vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = '#a277ff', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = '#61ffca', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = '#ffca85', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = '#82e2ff', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = '#f694ff', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = '#a277ff', bold = false })
  end,
}
