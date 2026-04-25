return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"ThePrimeagen/harpoon",
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("telescope").setup({
				defaults = {
					-- Custom preview title with just filename and icon
					dynamic_preview_title = true,
					preview_title = function(_, entry)
						if entry and entry.filename then
							local filename = vim.fn.fnamemodify(entry.filename, ":t")
							local icon, icon_hl =
								require("nvim-web-devicons").get_icon(filename, nil, { default = true })
							if icon then
								return icon .. " " .. filename
							end
							return filename
						end
						return "Preview"
					end,
					hidden = true,
					file_ignore_patterns = {
						"node_modules/",
						".git/",
						".venv/",
						"venv/",
						"__pycache__/",
						"%.pyc",
						"%.pyo",
						"%.pyd",
						"%.so",
						"%.dll",
						"%.dylib",
						"%.zip",
						"%.tar",
						"%.gz",
						"%.bz2",
						"%.xz",
						"%.cache",
						"%.DS_Store",
						"%.class",
						"%.o",
						"%.a",
						"%.out",
						"%.pdf",
						"%.jpg",
						"%.jpeg",
						"%.png",
						"%.gif",
						"%.svg",
						"%.ico",
						"%.db",
						"%.sqlite",
						"%.sqlite3",
						"%.min.js",
						"%.min.css",
						"dist/",
						"build/",
						"target/",
						"vendor/",
						"%.log",
						"%.tmp",
						"%.temp",
						"%.swp",
						"%.swo",
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!.git/",
						"--glob=!node_modules/",
						"--glob=!.venv/",
						"--glob=!venv/",
						"--glob=!__pycache__/",
						"--glob=!dist/",
						"--glob=!build/",
						"--glob=!target/",
						"--glob=!vendor/",
					},
				},
				extensions = {
					["ui-select"] = require("telescope.themes").get_dropdown({}),
				},
			})

			require("telescope").load_extension("ui-select")

			-- Simple git changed files command using built-in git_status
			vim.api.nvim_create_user_command("TelescopeGitDiff", function()
				require("telescope.builtin").git_status()
			end, {})

			-- Enhanced find_files that always includes force-included files even if in .gitignore
			-- Uses Telescope's built-in find_files which already has streaming support
			local function find_files_plus(opts)
				opts = opts or {}
				
				-- Check if fd is available, otherwise fall back to default
				local fd_available = vim.fn.executable("fd") == 1
				
				local find_opts = {
					-- Ensure hidden files are shown
					hidden = true,
					-- Limit results to prevent memory issues
					limit = 1000,
				}
				
				-- Use fd if available (faster and streams properly)
				if fd_available then
					find_opts.find_command = {
						"fd",
						"--type",
						"f",
						"--hidden",
						"--exclude",
						".git",
						"--exclude",
						"node_modules",
						"--exclude",
						".venv",
						"--exclude",
						"venv",
						"--exclude",
						"__pycache__",
					}
				end
				
				-- Use Telescope's built-in find_files which handles streaming efficiently
				-- It properly formats entries so they don't appear greyed out
				require("telescope.builtin").find_files(vim.tbl_extend("keep", find_opts, opts))
			end

			-- Make it available as a command
			vim.api.nvim_create_user_command("TelescopeFindFilesPlus", find_files_plus, {})
		end,
	},
}
