return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require('gitsigns').setup {
      signs = {
        add          = {hl = 'GitSignsAddLn',  text = ''},
        change       = {hl = 'GitSignsChangeLn', text = ''},
        delete       = {hl = 'GitSignsDeleteLn', text = ''},
        topdelete    = {hl = 'GitSignsDeleteLn', text = ''},
        changedelete = {hl = 'GitSignsChangeLn', text = ''},
      },
      signcolumn = false,    -- don't show symbols in the sign‐column
      numhl      = false,    -- disable number‐column highlighting
      linehl     = true,     -- highlight entire changed lines
      word_diff  = true,     -- highlight changed words inside the line
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      preview_config = {
        -- Enhanced floating window with more context
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 1,
        col = 0,
        width = 80,
        height = 15,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Enhanced navigation with automatic preview
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk("next")
            -- Auto-preview the hunk for easier review
            vim.defer_fn(function()
              gs.preview_hunk_inline()
            end, 100)
          end
        end, { desc = "Next hunk (with preview)" })

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk("prev")
            -- Auto-preview the hunk for easier review
            vim.defer_fn(function()
              gs.preview_hunk_inline()
            end, 100)
          end
        end, { desc = "Previous hunk (with preview)" })

        map('n', ']H', function() gs.nav_hunk("last") end, { desc = "Last hunk" })
        map('n', '[H', function() gs.nav_hunk("first") end, { desc = "First hunk" })

        -- CORE ACTIONS: Accept/Reject hunks (primary workflow)
        map({ 'n', 'v' }, '<leader>ha', ':Gitsigns stage_hunk<CR>', { desc = "✅ Accept hunk (stage)" })
        map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = "❌ Reject hunk (reset)" })
        
        -- Alternative single-key bindings for quick workflow
        map('n', '<leader>y', gs.stage_hunk, { desc = "✅ Accept hunk (quick)" })
        map('n', '<leader>n', gs.reset_hunk, { desc = "❌ Reject hunk (quick)" })
        
        -- File-level operations
        map('n', '<leader>hA', gs.stage_buffer, { desc = "✅ Accept all hunks in file" })
        map('n', '<leader>hR', gs.reset_buffer, { desc = "❌ Reject all hunks in file" })
        
        -- Undo staging (if you change your mind)
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "↩️  Undo hunk staging" })
        
        -- Preview and information
        map('n', '<leader>hp', gs.preview_hunk_inline, { desc = "👀 Preview hunk" })
        map('n', '<leader>hd', gs.diffthis, { desc = "📊 Diff this file" })
        map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = "🕵️  Blame line" })
        
        -- Text object for hunk operations
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select hunk" })
        
        -- Git workflow commands
        map('n', '<leader>hc', function()
          -- Show commit after accepting changes
          vim.cmd('Git commit')
        end, { desc = "💾 Commit accepted changes" })
        
        map('n', '<leader>hs', function()
          -- Status summary
          local status = vim.fn.system('git status --porcelain')
          if status == '' then
            vim.notify("No changes", vim.log.levels.INFO)
          else
            vim.notify("Git status:\n" .. status, vim.log.levels.INFO, { title = "Git Status" })
          end
        end, { desc = "📋 Show git status" })
      end
    }

    -- Better auto-preview with proper persistence
    vim.api.nvim_create_augroup("AutoPreviewGitsigns", { clear = true })
    
    -- Shorter delay for more responsive preview
    vim.opt.updatetime = 500
    
    -- Track if we're currently in a hunk to avoid flickering
    local last_hunk_line = nil
    local preview_active = false
    
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
      group = "AutoPreviewGitsigns",
      callback = function()
        local gs = require('gitsigns')
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        
        -- Get all hunks for current buffer
        local hunks = gs.get_hunks(vim.api.nvim_get_current_buf())
        if not hunks or #hunks == 0 then
          last_hunk_line = nil
          preview_active = false
          return
        end
        
        -- Check if current line is in any hunk
        for _, h in ipairs(hunks) do
          if h and h.start and h.vend and current_line >= h.start and current_line <= h.vend then
            -- Only show preview if we're on a different hunk or first time
            if last_hunk_line ~= h.start or not preview_active then
              gs.preview_hunk()
              last_hunk_line = h.start
              preview_active = true
            end
            return
          end
        end
        
        -- Not in a hunk anymore
        last_hunk_line = nil
        preview_active = false
      end,
      desc = "Auto-preview git hunk on cursor hold with persistence"
    })
    
    -- Close preview when leaving buffer or going to insert mode
    vim.api.nvim_create_autocmd({ "BufLeave", "InsertEnter" }, {
      group = "AutoPreviewGitsigns",
      callback = function()
        preview_active = false
        last_hunk_line = nil
        -- Close any existing preview windows
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name:match("gitsigns://") then
            vim.api.nvim_win_close(win, true)
          end
        end
      end,
      desc = "Close preview when leaving buffer"
    })

    -- Toggle between two states: minimal vs full
    local gitsigns_full_mode = true -- Start in full mode
    local function toggle_gitsigns_mode()
      local gs = require('gitsigns')
      
      if gitsigns_full_mode then
        -- Switch to MINIMAL mode: just gutter signs, no highlights, no auto-preview
        gs.setup({
          signcolumn = true,    -- Show symbols in gutter
          linehl = false,       -- No line highlighting
          word_diff = false,    -- No word-level diff
          signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
          },
        })
        
        -- Disable auto-preview and close any existing ones
        vim.api.nvim_clear_autocmds({ group = "AutoPreviewGitsigns" })
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name:match("gitsigns://") then
            vim.api.nvim_win_close(win, true)
          end
        end
        
        vim.notify("📍 Gitsigns: Minimal mode (gutter signs only)", vim.log.levels.INFO)
        gitsigns_full_mode = false
      else
        -- Switch to FULL mode: full highlighting + auto-preview
        gs.setup({
          signcolumn = false,   -- No gutter symbols
          linehl = true,        -- Full line highlighting
          word_diff = true,     -- Word-level diff highlighting
          signs = {
            add          = {hl = 'GitSignsAddLn',  text = ''},
            change       = {hl = 'GitSignsChangeLn', text = ''},
            delete       = {hl = 'GitSignsDeleteLn', text = ''},
            topdelete    = {hl = 'GitSignsDeleteLn', text = ''},
            changedelete = {hl = 'GitSignsChangeLn', text = ''},
          },
          preview_config = {
            border = 'rounded',
            style = 'minimal',
            relative = 'cursor',
            row = 1,
            col = 0,
            width = 80,
            height = 15,
          },
        })
        
        -- Re-enable auto-preview with the enhanced version
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
          group = "AutoPreviewGitsigns",
          callback = function()
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            local hunks = gs.get_hunks(vim.api.nvim_get_current_buf())
            
            if not hunks or #hunks == 0 then
              last_hunk_line = nil
              preview_active = false
              return
            end
            
            -- Check if current line is in any hunk
            for _, h in ipairs(hunks) do
              if h and h.start and h.vend and current_line >= h.start and current_line <= h.vend then
                if last_hunk_line ~= h.start or not preview_active then
                  gs.preview_hunk()
                  last_hunk_line = h.start
                  preview_active = true
                end
                return
              end
            end
            
            last_hunk_line = nil
            preview_active = false
          end,
          desc = "Auto-preview git hunk on cursor hold with persistence"
        })
        
        vim.api.nvim_create_autocmd({ "BufLeave", "InsertEnter" }, {
          group = "AutoPreviewGitsigns",
          callback = function()
            preview_active = false
            last_hunk_line = nil
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local buf_name = vim.api.nvim_buf_get_name(buf)
              if buf_name:match("gitsigns://") then
                vim.api.nvim_win_close(win, true)
              end
            end
          end,
          desc = "Close preview when leaving buffer"
        })
        
        vim.notify("🎨 Gitsigns: Full mode (highlights + auto-preview)", vim.log.levels.INFO)
        gitsigns_full_mode = true
      end
    end

    -- Global keybinding for toggle
    vim.keymap.set('n', '<leader>gS', toggle_gitsigns_mode, { desc = "🔄 Toggle Gitsigns: Minimal ↔ Full" })
  end,
} 