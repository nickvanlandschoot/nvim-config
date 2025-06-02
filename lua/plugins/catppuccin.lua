return {
    {
        "morhetz/gruvbox",
        name = "gruvbox",
        priority = 1000,
        config = function()
            -- Set gruvbox options
            vim.g.gruvbox_contrast_dark = 'medium' -- soft, medium, hard
            vim.g.gruvbox_contrast_light = 'medium'
            vim.g.gruvbox_italic = 1
            vim.g.gruvbox_bold = 1
            vim.g.gruvbox_underline = 1
            vim.g.gruvbox_undercurl = 1
            vim.g.gruvbox_terminal_colors = 1
            vim.g.gruvbox_improved_strings = 1
            vim.g.gruvbox_improved_warnings = 1
            
            vim.cmd.colorscheme("gruvbox")
        end
    },
}
