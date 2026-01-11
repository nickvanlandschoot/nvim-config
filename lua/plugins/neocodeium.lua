return {
	"monkoose/neocodeium",
	event = "VeryLazy",
	config = function()
		local neocodeium = require("neocodeium")
		local blink = require("blink.cmp")

		-- Clear NeoCodeium suggestions when blink.cmp menu opens
		vim.api.nvim_create_autocmd("User", {
			pattern = "BlinkCmpMenuOpen",
			callback = function()
				neocodeium.clear()
			end,
		})

		neocodeium.setup({
			enabled = true,
			manual = false,
			show_label = true,
			debounce = false,
			-- Only show suggestions when blink.cmp menu is not visible
			filter = function()
				return not blink.is_visible()
			end,
			filetypes = {
				help = false,
				gitcommit = false,
				gitrebase = false,
				["."] = false,
				TelescopePrompt = false,
				["dap-repl"] = false,
			},
		})

		-- Keymaps for NeoCodeium
		vim.keymap.set("i", "<A-f>", function()
			neocodeium.accept()
		end, { noremap = true, silent = true, desc = "Accept NeoCodeium completion" })

		vim.keymap.set("i", "<A-w>", function()
			neocodeium.accept_word()
		end, { noremap = true, silent = true, desc = "Accept NeoCodeium word" })

		vim.keymap.set("i", "<A-a>", function()
			neocodeium.accept_line()
		end, { noremap = true, silent = true, desc = "Accept NeoCodeium line" })

		vim.keymap.set("i", "<A-e>", function()
			neocodeium.cycle_or_complete()
		end, { noremap = true, silent = true, desc = "Cycle NeoCodeium suggestions" })

		vim.keymap.set("i", "<A-r>", function()
			neocodeium.cycle_or_complete(-1)
		end, { noremap = true, silent = true, desc = "Cycle NeoCodeium suggestions (reverse)" })

		vim.keymap.set("i", "<A-c>", function()
			neocodeium.clear()
		end, { noremap = true, silent = true, desc = "Clear NeoCodeium suggestions" })

		-- Toggle NeoCodeium (replacing the old Augment toggle)
		vim.keymap.set("n", "<leader>ta", function()
			require("neocodeium.commands").toggle()
		end, { noremap = true, silent = true, desc = "Toggle NeoCodeium" })
	end,
}
