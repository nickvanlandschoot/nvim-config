return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                filters = {
                    dotfiles = false, -- Show hidden files (dotfiles)
                    custom = {} -- Ensure no additional filters
                },
                git = {
                    ignore = false -- Show ignored files as well
                }
            })

            -- Keybinding to toggle NvimTree
            vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
        end
    }
}

