return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Only enable notification system (used by keymaps)
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
    
    -- Progress notifications (needed by claudecode for long-running operations)
    progress = {
      enabled = true,
      style = "compact",
    },
    
    -- Terminal enhancements (needed by claudecode for running commands)
    terminal = {
      enabled = true,
      win = {
        style = "terminal",
      },
    },
    
    -- Disable unused features
    bigfile = { enabled = false },
    quickfile = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  
  keys = {
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>nd", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  },
  
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup debug helper (used for _G.dd and vim.print)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        vim.print = _G.dd
      end,
    })

    -- Set up tmux navigation for terminal buffers (needed for proper pane switching)
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