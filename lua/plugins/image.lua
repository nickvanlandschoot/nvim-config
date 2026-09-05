-- ImageMagick can mistake CSS font fallback lists in SVGs for an empty font and
-- raise an asynchronous error that image.nvim cannot catch. Render local SVGs
-- with librsvg first; this is the same workaround used by the Markdown `gd`
-- preview in config/keymaps.lua.
local svg_cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "image.nvim", "svg")

local function resolve_image_path(document_path, image_path, fallback)
	local path = fallback(document_path, image_path)
	if vim.fn.fnamemodify(path, ":e"):lower() ~= "svg" then
		return path
	end

	-- image.nvim normally retries percent-decoded local paths itself, but this
	-- resolver needs the real path before invoking rsvg-convert.
	if vim.fn.filereadable(path) == 0 then
		local decoded_path = path:gsub("%%(%x%x)", function(hex)
			return string.char(tonumber(hex, 16))
		end)
		if vim.fn.filereadable(decoded_path) == 1 then
			path = decoded_path
		end
	end

	if vim.fn.filereadable(path) == 0 then
		return path
	end
	if vim.fn.executable("rsvg-convert") == 0 then
		vim.notify_once("Cannot safely preview SVGs: rsvg-convert is not installed", vim.log.levels.WARN)
		return path .. ".image-nvim-skipped"
	end

	vim.fn.mkdir(svg_cache_dir, "p")
	local output = vim.fs.joinpath(svg_cache_dir, vim.fn.sha256(path) .. ".png")
	if vim.fn.filereadable(output) == 1 and vim.fn.getftime(output) >= vim.fn.getftime(path) then
		return output
	end

	local result = vim.system({ "rsvg-convert", "--output", output, path }, { text = true }):wait()
	if result.code == 0 and vim.fn.filereadable(output) == 1 then
		return output
	end

	vim.fn.delete(output)
	vim.notify_once(
		("Could not prepare SVG preview for image.nvim: %s"):format(vim.trim(result.stderr or path)),
		vim.log.levels.WARN
	)
	-- A missing path makes image.nvim fail synchronously inside its pcall rather
	-- than letting ImageMagick throw from an asynchronous identify callback.
	return output
end

return {
	"3rd/image.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	build = false, -- don't build magick rock, use CLI instead
	event = "VeryLazy",
	opts = {
		backend = "kitty",
		processor = "magick_cli", -- use ImageMagick CLI
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = true, -- Clear images in insert mode to save memory
				download_remote_images = false, -- Disable auto-download to save memory
				only_render_image_at_cursor = true, -- Only render image at cursor to save memory
				only_render_image_at_cursor_mode = "inline", -- Reserve space in the document instead of using a popup
				resolve_image_path = resolve_image_path,
				filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
			},
			neorg = {
				enabled = true,
				clear_in_insert_mode = true, -- Clear images in insert mode to save memory
				download_remote_images = false, -- Disable auto-download to save memory
				only_render_image_at_cursor = true, -- Only render image at cursor to save memory
				only_render_image_at_cursor_mode = "inline", -- Reserve space in the document instead of using a popup
				resolve_image_path = resolve_image_path,
				filetypes = { "norg" },
			},
		},
		max_width = nil,
		max_height = nil,
		max_width_window_percentage = nil,
		max_height_window_percentage = 50,
		-- Hide terminal images beneath Telescope and other floating windows. Without
		-- overlap masking, Kitty images remain visible through picker sections and
		-- make an otherwise opaque Telescope window look transparent.
		window_overlap_clear_enabled = true,
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif" },
		editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
		tmux_show_only_in_active_window = false, -- auto show/hide images in the current Tmux window/tab
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- SVG links are rendered to temporary PNGs before opening
	},
	config = function(_, opts)
		require("image").setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("image_viewer_keymaps", { clear = true }),
			pattern = "image_nvim",
			callback = function(args)
				vim.keymap.set("n", "q", function()
					local image_buf = vim.api.nvim_get_current_buf()
					local return_buf = vim.b[image_buf].image_return_buffer
					if type(return_buf) ~= "number" or not vim.api.nvim_buf_is_valid(return_buf) then
						return_buf = vim.fn.bufnr("#")
					end

					if return_buf ~= -1 and return_buf ~= image_buf and vim.api.nvim_buf_is_valid(return_buf) then
						vim.api.nvim_win_set_buf(0, return_buf)
					end
					vim.api.nvim_buf_delete(image_buf, { force = true })
				end, { buffer = args.buf, desc = "Close image and return to originating buffer" })
			end,
			desc = "Add image viewer keymaps",
		})
	end,
}
