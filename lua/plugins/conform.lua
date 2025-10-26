return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			html = { "prettier" },
			markdown = { "prettier" },
			yaml = { "prettier" },
			lua = { "stylua" },
			python = { "ruff_format" },
			go = { "gofmt" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
		formatters = {
			prettier = {
				prepend_args = {
					"--single-quote",
					"--jsx-single-quote",
					"--trailing-comma=es5",
					"--semi",
					"--tab-width=2",
				},
			},
		},
	},
}
