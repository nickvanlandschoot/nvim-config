return {
	"lewis6991/hover.nvim",
	config = function()
		require("hover").setup({
			init = function()
				-- Require providers
				require("hover.providers.lsp")
				-- require("hover.providers.gh")
				-- require("hover.providers.man")
				-- require("hover.providers.dictionary")
			end,
			preview_opts = {
				border = "rounded",
				-- Position hover window to avoid blocking code
				relative = "cursor",
				row = 1,
				col = 0,
				-- Make it smaller and less intrusive
				max_width = 60,
				max_height = 20,
			},
			-- Whether the contents of a currently open hover window should be moved
			-- to a :h preview-window when pressing the hover key.
			preview_window = false,
			title = true,
			-- Close hover window when cursor moves
			close_on_move = true,
		})

		-- Note: K is already mapped to hover in keymaps.lua, so we don't override it here
		-- hover.nvim will be used automatically by the autocmd
	end,
}
