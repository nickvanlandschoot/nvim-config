return {
  'augmentcode/augment.vim',
  config = function ()
    -- Set OpenAI API key
    vim.g.augment_openai_api_key = vim.fn.getenv("OPENAI_API_KEY")

    -- Toggle function to enable/disable completions
    vim.keymap.set('n', '<leader>ta', function()
      if vim.g.augment_disable_completions == true then
        vim.g.augment_disable_completions = false
        vim.notify('Augment completions enabled')
      else
        vim.g.augment_disable_completions = true
        vim.notify('Augment completions disabled')
      end
    end, { noremap = true, silent = true, desc = 'Toggle Augment completions' })

    -- Start with completions disabled by default
    vim.g.augment_disable_completions = true
  end
}

