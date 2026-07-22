return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {
		heading = {
			-- Disable background colors for headings
			backgrounds = {},
			-- Use foreground colors and icons instead
			foregrounds = {
				"RenderMarkdownH1",
				"RenderMarkdownH2",
				"RenderMarkdownH3",
				"RenderMarkdownH4",
				"RenderMarkdownH5",
				"RenderMarkdownH6",
			},
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		},
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		-- Heading colors are owned by the active colorscheme. Keeping palette
		-- values out of plugin configuration prevents cross-theme contamination.
	end,
}
