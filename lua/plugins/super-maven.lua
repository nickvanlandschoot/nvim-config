return {
	"supermaven-inc/supermaven-nvim",
	cmd = {
		"SupermavenStart",
		"SupermavenStop",
		"SupermavenToggle",
		"SupermavenRestart",
	},
	keys = {
		{ "<leader>aS", "<cmd>SupermavenToggle<cr>", desc = "Toggle Supermaven completions" },
	},
	config = function()
		require("supermaven-nvim").setup({})
	end,
}
