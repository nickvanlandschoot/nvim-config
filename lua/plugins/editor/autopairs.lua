-- Auto-pairs plugin for smart bracket/parenthesis behavior
return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup({
        check_ts = true, -- Use treesitter for better context awareness
        ts_config = {
          lua = { "string", "source" },
          javascript = { "string", "template_string" },
          java = false,
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        },
      })

      -- Smart closing: when typing ), ], or }, skip over if already there
      -- This allows typing ) to move cursor out of () instead of adding another )
      npairs.add_rules({
        Rule(")", "")
          :with_pair(cond.not_inside_quote())
          :with_pair(function(opts)
            -- Check if next character is already )
            -- opts.col is 0-indexed, line:sub is 1-indexed, so add 1
            local next_char = opts.line:sub(opts.col + 2, opts.col + 2)
            return next_char == ")"
          end)
          :replace_map(function()
            -- Move cursor right instead of inserting
            return "<Right>"
          end),
        Rule("]", "")
          :with_pair(cond.not_inside_quote())
          :with_pair(function(opts)
            local next_char = opts.line:sub(opts.col + 2, opts.col + 2)
            return next_char == "]"
          end)
          :replace_map(function()
            return "<Right>"
          end),
        Rule("}", "")
          :with_pair(cond.not_inside_quote())
          :with_pair(function(opts)
            local next_char = opts.line:sub(opts.col + 2, opts.col + 2)
            return next_char == "}"
          end)
          :replace_map(function()
            return "<Right>"
          end),
      })

      -- Smart behavior for braces: expand with proper indentation when pressing Enter after {
      -- This creates: {<CR><indent><CR><indent>} with cursor positioned inside
      npairs.add_rules({
        Rule("{", "}", { "lua", "go", "rust", "javascript", "typescript", "python", "java", "c", "cpp", "cs" })
          :with_pair(function(opts)
            -- Only apply to braces at end of line or followed by whitespace
            local line = opts.line
            local col = opts.col
            local next_char = line:sub(col, col)
            return next_char == "" or next_char:match("%s")
          end)
          :use_key("}")
          :replace_map_cr(function()
            -- When Enter is pressed after opening brace, expand with proper indentation
            local line = vim.api.nvim_get_current_line()
            local indent = line:match("^%s*")
            local indent_size = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
            local indent_str = string.rep(" ", indent_size)
            -- Insert: newline, indent+content_indent, newline, indent, closing brace
            -- Then move cursor up one line to the content line
            return "<CR>" .. indent .. indent_str .. "<CR>" .. indent .. "}<Esc>O"
          end),
      })

      -- Integration with blink.cmp (completion menu)
      -- This ensures autopairs works correctly when selecting from completion menu
      local ok_blink, blink_cmp = pcall(require, "blink.cmp")
      if ok_blink and blink_cmp and blink_cmp.event then
        blink_cmp.event:on("confirm_done", function()
          npairs.check_break_line_char()
        end)
      end

      -- Auto-expand braces when {} is created (automatic expansion on typing {)
      -- This watches for when autopairs creates {} and expands it automatically
      local expand_braces_ft = { "lua", "go", "rust", "javascript", "typescript", "python", "java", "c", "cpp", "cs" }
      local expand_timer = nil

      vim.api.nvim_create_autocmd("TextChangedI", {
        pattern = "*",
        callback = function()
          local ft = vim.bo.filetype
          if not vim.tbl_contains(expand_braces_ft, ft) then
            return
          end

          -- Debounce to avoid multiple expansions
          if expand_timer then
            vim.fn.timer_stop(expand_timer)
          end

          expand_timer = vim.fn.timer_start(10, function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local line = vim.api.nvim_get_current_line()
            
            -- Check if we're between {} at end of line
            -- Cursor should be between { and }
            if col >= 0 and col < #line - 1 then
              local char_at_cursor = line:sub(col + 1, col + 1)
              local char_after = line:sub(col + 2, col + 2)
              
              -- Only expand if cursor is empty space between { and }
              if char_at_cursor == "" and char_after == "}" then
                local rest = line:sub(col + 3)
                -- Only expand if at end of line or followed by whitespace/comma/semicolon
                if rest == "" or rest:match("^%s*[,;]?%s*$") then
                  -- Get indentation
                  local indent = line:match("^%s*")
                  local indent_size = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
                  local indent_str = string.rep(" ", indent_size)
                  
                  -- Delete the closing brace
                  vim.api.nvim_buf_set_text(0, row - 1, col + 2, row - 1, col + 3, {})
                  
                  -- Insert expanded block: newline, indent+content_indent, newline, indent, closing brace
                  vim.api.nvim_put({ "", indent .. indent_str, indent .. "}" }, "l", false, true)
                  
                  -- Move cursor to content line (one line up, at proper indent)
                  local new_row = vim.api.nvim_win_get_cursor(0)[1] - 1
                  vim.api.nvim_win_set_cursor(0, { new_row, #indent + indent_size })
                end
              end
            end
          end)
        end,
      })
    end,
  },
}
