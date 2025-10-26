return {
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        default_remote = { "origin", "upstream" },
        default_merge_method = "squash",
        ssh_aliases = {},
        picker = "telescope",
        use_local_fs = false,
        enable_builtin = false,
        default_to_projects_v2 = false,  -- Disabled: requires 'read:project' or 'project' GitHub token scope
        timeout = 5000,

        -- UI Configuration - Use floating windows for TUI elements
        ui = {
          use_signcolumn = true,
          use_signstatus = true,
        },

        -- Bubble configuration for floating windows
        bubble = {
          enabled = true,
          style = "rounded",
          width = 80,
        },

        -- Mappings for octo buffers
        mappings = {
          issue = {
            close_issue = { lhs = "<leader>ic", desc = "close issue" },
            reopen_issue = { lhs = "<leader>io", desc = "reopen issue" },
            list_issues = { lhs = "<leader>il", desc = "list open issues" },
            reload = { lhs = "<C-r>", desc = "reload issue" },
            open_in_browser = { lhs = "<leader>gb", desc = "open in browser" },
            copy_url = { lhs = "<leader>yu", desc = "copy url" },
            add_assignee = { lhs = "<leader>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<leader>ad", desc = "remove assignee" },
            create_label = { lhs = "<leader>lc", desc = "create label" },
            add_label = { lhs = "<leader>la", desc = "add label" },
            remove_label = { lhs = "<leader>ld", desc = "remove label" },
            goto_issue = { lhs = "<leader>gi", desc = "goto issue" },
            add_comment = { lhs = "<leader>gpa", desc = "add comment" },
            delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "next comment" },
            prev_comment = { lhs = "[c", desc = "prev comment" },
            react_hooray = { lhs = "<leader>rp", desc = "react hooray" },
            react_heart = { lhs = "<leader>rh", desc = "react heart" },
            react_eyes = { lhs = "<leader>re", desc = "react eyes" },
            react_thumbs_up = { lhs = "<leader>r+", desc = "react thumbs up" },
            react_thumbs_down = { lhs = "<leader>r-", desc = "react thumbs down" },
            react_rocket = { lhs = "<leader>rr", desc = "react rocket" },
            react_laugh = { lhs = "<leader>rl", desc = "react laugh" },
            react_confused = { lhs = "<leader>rc", desc = "react confused" },
          },
          pull_request = {
            checkout_pr = { lhs = "<leader>po", desc = "checkout PR" },
            merge_pr = { lhs = "<leader>pm", desc = "merge PR" },
            list_commits = { lhs = "<leader>pc", desc = "list PR commits" },
            list_changed_files = { lhs = "<leader>pf", desc = "list PR changed files" },
            show_pr_diff = { lhs = "<leader>pd", desc = "show PR diff" },
            add_reviewer = { lhs = "<leader>va", desc = "add reviewer" },
            remove_reviewer = { lhs = "<leader>vd", desc = "remove reviewer" },
            close_issue = { lhs = "<leader>ic", desc = "close PR" },
            reopen_issue = { lhs = "<leader>io", desc = "reopen PR" },
            list_issues = { lhs = "<leader>il", desc = "list open PRs" },
            reload = { lhs = "<C-r>", desc = "reload PR" },
            open_in_browser = { lhs = "<leader>gb", desc = "open in browser" },
            copy_url = { lhs = "<leader>yu", desc = "copy url" },
            goto_file = { lhs = "gf", desc = "goto file" },
            add_assignee = { lhs = "<leader>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<leader>ad", desc = "remove assignee" },
            create_label = { lhs = "<leader>lc", desc = "create label" },
            add_label = { lhs = "<leader>la", desc = "add label" },
            remove_label = { lhs = "<leader>ld", desc = "remove label" },
            goto_issue = { lhs = "<leader>gi", desc = "goto issue" },
            add_comment = { lhs = "<leader>gpa", desc = "add comment" },
            delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "next comment" },
            prev_comment = { lhs = "[c", desc = "prev comment" },
            react_hooray = { lhs = "<leader>rp", desc = "react hooray" },
            react_heart = { lhs = "<leader>rh", desc = "react heart" },
            react_eyes = { lhs = "<leader>re", desc = "react eyes" },
            react_thumbs_up = { lhs = "<leader>r+", desc = "react thumbs up" },
            react_thumbs_down = { lhs = "<leader>r-", desc = "react thumbs down" },
            react_rocket = { lhs = "<leader>rr", desc = "react rocket" },
            react_laugh = { lhs = "<leader>rl", desc = "react laugh" },
            react_confused = { lhs = "<leader>rc", desc = "react confused" },
            review_start = { lhs = "<leader>vs", desc = "start review" },
            review_resume = { lhs = "<leader>vr", desc = "resume review" },
          },
          review_thread = {
            goto_issue = { lhs = "<leader>gi", desc = "goto issue" },
            add_comment = { lhs = "<leader>gpa", desc = "add comment" },
            add_suggestion = { lhs = "<leader>sa", desc = "add suggestion" },
            delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "next comment" },
            prev_comment = { lhs = "[c", desc = "prev comment" },
            select_next_entry = { lhs = "]q", desc = "next entry" },
            select_prev_entry = { lhs = "[q", desc = "prev entry" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            react_hooray = { lhs = "<leader>rp", desc = "react hooray" },
            react_heart = { lhs = "<leader>rh", desc = "react heart" },
            react_eyes = { lhs = "<leader>re", desc = "react eyes" },
            react_thumbs_up = { lhs = "<leader>r+", desc = "react thumbs up" },
            react_thumbs_down = { lhs = "<leader>r-", desc = "react thumbs down" },
            react_rocket = { lhs = "<leader>rr", desc = "react rocket" },
            react_laugh = { lhs = "<leader>rl", desc = "react laugh" },
            react_confused = { lhs = "<leader>rc", desc = "react confused" },
          },
          submit_win = {
            approve_review = { lhs = "<C-a>", desc = "approve review" },
            comment_review = { lhs = "<C-m>", desc = "comment review" },
            request_changes = { lhs = "<C-r>", desc = "request changes" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
          },
          review_diff = {
            submit_review = { lhs = "<leader>vs", desc = "submit review" },
            discard_review = { lhs = "<leader>vd", desc = "discard review" },
            add_review_comment = { lhs = "<leader>gpa", desc = "add review comment" },
            add_review_suggestion = { lhs = "<leader>sa", desc = "add suggestion" },
            focus_files = { lhs = "<leader>e", desc = "focus files" },
            toggle_files = { lhs = "<leader>b", desc = "toggle files" },
            next_thread = { lhs = "]t", desc = "next thread" },
            prev_thread = { lhs = "[t", desc = "prev thread" },
            select_next_entry = { lhs = "]q", desc = "next entry" },
            select_prev_entry = { lhs = "[q", desc = "prev entry" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewed" },
            goto_file = { lhs = "gf", desc = "goto file" },
          },
          file_panel = {
            submit_review = { lhs = "<leader>vs", desc = "submit review" },
            discard_review = { lhs = "<leader>vd", desc = "discard review" },
            next_entry = { lhs = "j", desc = "next entry" },
            prev_entry = { lhs = "k", desc = "prev entry" },
            select_entry = { lhs = "<cr>", desc = "select entry" },
            refresh_files = { lhs = "R", desc = "refresh files" },
            focus_files = { lhs = "<leader>e", desc = "focus files" },
            toggle_files = { lhs = "<leader>b", desc = "toggle files" },
            select_next_entry = { lhs = "]q", desc = "next entry" },
            select_prev_entry = { lhs = "[q", desc = "prev entry" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewed" },
          },
        },

        -- File panel configuration
        file_panel = {
          size = 10,
          use_icons = true,
        },

        -- Colors
        colors = {
          white = "#ffffff",
          grey = "#2A354C",
          black = "#000000",
          red = "#fdb8c0",
          dark_red = "#da3633",
          green = "#acf2bd",
          dark_green = "#238636",
          yellow = "#d3c846",
          dark_yellow = "#735c0f",
          blue = "#58A6FF",
          dark_blue = "#0366d6",
          purple = "#6f42c1",
        },
      })

      -- Global keybindings for common operations
      local opts = { noremap = true, silent = true }

      -- PR operations
      vim.keymap.set("n", "<leader>gpr", "<cmd>Octo pr list<CR>", vim.tbl_extend("force", opts, { desc = "List PRs" }))
      vim.keymap.set("n", "<leader>gpc", "<cmd>Octo pr create<CR>", vim.tbl_extend("force", opts, { desc = "Create PR" }))
      vim.keymap.set("n", "<leader>gps", "<cmd>Octo pr search<CR>", vim.tbl_extend("force", opts, { desc = "Search PRs" }))
      vim.keymap.set("n", "<leader>gpe", "<cmd>Octo pr edit<CR>", vim.tbl_extend("force", opts, { desc = "Edit PR" }))
      vim.keymap.set("n", "<leader>gpp", "<cmd>Octo pr checkout<CR>", vim.tbl_extend("force", opts, { desc = "Checkout PR" }))
      vim.keymap.set("n", "<leader>gpd", "<cmd>Octo pr diff<CR>", vim.tbl_extend("force", opts, { desc = "PR diff" }))
      vim.keymap.set("n", "<leader>gpm", "<cmd>Octo pr merge<CR>", vim.tbl_extend("force", opts, { desc = "Merge PR" }))
      vim.keymap.set("n", "<leader>gpo", "<cmd>Octo pr browser<CR>", vim.tbl_extend("force", opts, { desc = "Open PR in browser" }))

      -- Issue operations
      vim.keymap.set("n", "<leader>gir", "<cmd>Octo issue list<CR>", vim.tbl_extend("force", opts, { desc = "List issues" }))
      vim.keymap.set("n", "<leader>gic", "<cmd>Octo issue create<CR>", vim.tbl_extend("force", opts, { desc = "Create issue" }))
      vim.keymap.set("n", "<leader>gis", "<cmd>Octo issue search<CR>", vim.tbl_extend("force", opts, { desc = "Search issues" }))
      vim.keymap.set("n", "<leader>gie", "<cmd>Octo issue edit<CR>", vim.tbl_extend("force", opts, { desc = "Edit issue" }))
      vim.keymap.set("n", "<leader>gio", "<cmd>Octo issue browser<CR>", vim.tbl_extend("force", opts, { desc = "Open issue in browser" }))

      -- Review operations
      vim.keymap.set("n", "<leader>gvs", "<cmd>Octo review start<CR>", vim.tbl_extend("force", opts, { desc = "Start review" }))
      vim.keymap.set("n", "<leader>gvr", "<cmd>Octo review resume<CR>", vim.tbl_extend("force", opts, { desc = "Resume review" }))
      vim.keymap.set("n", "<leader>gvc", "<cmd>Octo review comments<CR>", vim.tbl_extend("force", opts, { desc = "Review comments" }))
      vim.keymap.set("n", "<leader>gvt", "<cmd>Octo review submit<CR>", vim.tbl_extend("force", opts, { desc = "Submit review" }))
      vim.keymap.set("n", "<leader>gvd", "<cmd>Octo review discard<CR>", vim.tbl_extend("force", opts, { desc = "Discard review" }))

      -- Comment operations
      vim.keymap.set("n", "<leader>gpa", "<cmd>Octo comment add<CR>", vim.tbl_extend("force", opts, { desc = "Add comment" }))
      vim.keymap.set("n", "<leader>gcd", "<cmd>Octo comment delete<CR>", vim.tbl_extend("force", opts, { desc = "Delete comment" }))

      -- Reaction operations
      vim.keymap.set("n", "<leader>grt", "<cmd>Octo reaction thumbs_up<CR>", vim.tbl_extend("force", opts, { desc = "React thumbs up" }))
      vim.keymap.set("n", "<leader>grh", "<cmd>Octo reaction heart<CR>", vim.tbl_extend("force", opts, { desc = "React heart" }))
      vim.keymap.set("n", "<leader>gre", "<cmd>Octo reaction eyes<CR>", vim.tbl_extend("force", opts, { desc = "React eyes" }))
      vim.keymap.set("n", "<leader>grr", "<cmd>Octo reaction rocket<CR>", vim.tbl_extend("force", opts, { desc = "React rocket" }))

      -- Thread navigation
      vim.keymap.set("n", "<leader>gtn", "<cmd>Octo thread next<CR>", vim.tbl_extend("force", opts, { desc = "Next thread" }))
      vim.keymap.set("n", "<leader>gtp", "<cmd>Octo thread prev<CR>", vim.tbl_extend("force", opts, { desc = "Prev thread" }))

      -- Gist operations
      vim.keymap.set("n", "<leader>ggl", "<cmd>Octo gist list<CR>", vim.tbl_extend("force", opts, { desc = "List gists" }))

      -- Card operations (Projects)
      vim.keymap.set("n", "<leader>gkm", "<cmd>Octo card move<CR>", vim.tbl_extend("force", opts, { desc = "Move card" }))
      vim.keymap.set("n", "<leader>gka", "<cmd>Octo card add<CR>", vim.tbl_extend("force", opts, { desc = "Add card" }))
      vim.keymap.set("n", "<leader>gkd", "<cmd>Octo card remove<CR>", vim.tbl_extend("force", opts, { desc = "Remove card" }))

      -- Label operations
      vim.keymap.set("n", "<leader>gla", "<cmd>Octo label add<CR>", vim.tbl_extend("force", opts, { desc = "Add label" }))
      vim.keymap.set("n", "<leader>gld", "<cmd>Octo label remove<CR>", vim.tbl_extend("force", opts, { desc = "Remove label" }))
      vim.keymap.set("n", "<leader>glc", "<cmd>Octo label create<CR>", vim.tbl_extend("force", opts, { desc = "Create label" }))

      -- Search operations
      vim.keymap.set("n", "<leader>gsp", "<cmd>Octo search<CR>", vim.tbl_extend("force", opts, { desc = "Search GitHub" }))
    end,
  },
}
