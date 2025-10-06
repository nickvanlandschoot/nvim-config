return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "macchiato", -- latte, frappe, macchiato, mocha
                background = { -- :h background
                    light = "latte",
                    dark = "latte",
                },
                transparent_background = true, -- disables setting the background color.
                show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
                term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
                dim_inactive = {
                    enabled = false, -- dims the background color of inactive window
                    shade = "dark",
                    percentage = 0.15, -- percentage of the shade to apply to the inactive window
                },
                no_italic = false, -- Force no italic
                no_bold = false, -- Force no bold
                no_underline = false, -- Force no underline
                styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
                    comments = { "italic" }, -- Change the style of comments
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
                color_overrides = {},
                custom_highlights = function(colors)
                    return {
                        -- Main transparency
                        Normal = { bg = colors.none },
                        NormalNC = { bg = colors.none },
                        SignColumn = { bg = colors.none },
                        LineNr = { bg = colors.none },
                        CursorLineNr = { bg = colors.none },
                        
                        -- Floating windows
                        NormalFloat = { bg = colors.none },
                        FloatBorder = { bg = colors.none },
                        FloatTitle = { bg = colors.none },
                        
                        -- Telescope transparency
                        TelescopeNormal = { bg = colors.none },
                        TelescopeBorder = { bg = colors.none },
                        TelescopePromptNormal = { bg = colors.none },
                        TelescopePromptBorder = { bg = colors.none },
                        TelescopePromptTitle = { bg = colors.none },
                        TelescopeResultsNormal = { bg = colors.none },
                        TelescopeResultsBorder = { bg = colors.none },
                        TelescopeResultsTitle = { bg = colors.none },
                        TelescopePreviewNormal = { bg = colors.none },
                        TelescopePreviewBorder = { bg = colors.none },
                        TelescopePreviewTitle = { bg = colors.none },
                        TelescopeSelection = { bg = colors.none },
                        
                        -- Status line
                        StatusLine = { bg = colors.none },
                        StatusLineNC = { bg = colors.none },
                        
                        -- Popup menus
                        Pmenu = { bg = colors.none },
                        PmenuSel = { bg = colors.none },
                        PmenuSbar = { bg = colors.none },
                        PmenuThumb = { bg = colors.none },
                        
                        -- File explorer
                        NvimTreeNormal = { bg = colors.none },
                        NvimTreeEndOfBuffer = { bg = colors.none },
                        
                        -- Which-key
                        WhichKeyFloat = { bg = colors.none },
                        WhichKeyBorder = { bg = colors.none },
                        
                        -- Lazy.nvim
                        LazyNormal = { bg = colors.none },
                        LazyBorder = { bg = colors.none },
                        
                        -- Mason
                        MasonNormal = { bg = colors.none },
                        MasonBorder = { bg = colors.none },
                        
                        -- DAP UI
                        DapUIFloatBorder = { bg = colors.none },
                        DapUIFloatNormal = { bg = colors.none },
                        
                        -- Blink completion
                        BlinkCmpMenu = { bg = colors.none },
                        BlinkCmpMenuBorder = { bg = colors.none },
                        BlinkCmpMenuSelection = { bg = colors.none },
                        BlinkCmpDoc = { bg = colors.none },
                        BlinkCmpDocBorder = { bg = colors.none },
                        BlinkCmpSignatureHelp = { bg = colors.none },
                        BlinkCmpSignatureHelpBorder = { bg = colors.none },
                    }
                end,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    treesitter = true,
                    notify = false,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                    -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
                    barbar = true,
                    dap = true,
                    dap_ui = true,
                    harpoon = true,
                    lsp_trouble = true,
                    mason = true,
                    neotree = true,
                    telescope = {
                        enabled = true,
                        -- style = "nvchad"
                    },
                    which_key = true,
                },
            })

            -- setup must be called before loading
            vim.cmd.colorscheme "catppuccin"
        end
    },
}
