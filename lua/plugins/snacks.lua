return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- bigfile configuration to handle large files efficiently
    bigfile = { enabled = true },
    
    -- notification system
    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      level = vim.log.levels.TRACE,
      icons = {
        error = " ",
        warn = " ", 
        info = " ",
        debug = " ",
        trace = " ",
      },
      keep = function(notif)
        return vim.fn.getcmdpos() > 0
      end,
      style = "compact",
    },
    
    -- quickfile for faster file loading
    quickfile = { enabled = true },
    
    -- status column enhancements
    statuscolumn = { enabled = false }, -- Keep simple status column
    
    -- word highlighting on cursor hold
    words = { enabled = true },
    
    -- progress notifications for long-running operations
    progress = {
      enabled = true,
      style = "compact",
    },
    
    -- LazyGit integration improvements
    lazygit = {
      enabled = true,
      theme = {
        activeBorderColor = { fg = "Special" },
        inactiveBorderColor = { fg = "FloatBorder" },
        selectedLineBgColor = { bg = "Visual" },
      },
    },
    
    -- Terminal enhancements
    terminal = {
      enabled = true,
      win = {
        style = "terminal",
      },
    },
  },
  
  keys = {
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>nd", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  },
  
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for easier access
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        vim.print = _G.dd
      end,
    })

    -- Set up tmux navigation for terminal buffers
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function()
        vim.keymap.set("t", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { buffer = true })
        vim.keymap.set("t", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { buffer = true })
        vim.keymap.set("t", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { buffer = true })
        vim.keymap.set("t", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { buffer = true })
      end,
    })
  end,
} 