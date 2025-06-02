vim.g.mapleader = ' '

local in_vscode = vim.g.vscode ~= nil

-- Basic settings that work in both VSCode and regular Neovim
vim.opt.tabstop       = 2    -- number of visual spaces per TAB
vim.opt.softtabstop   = 2    -- number of spaces for a <Tab> in insert mode
vim.opt.shiftwidth    = 2    -- size of an indent
vim.opt.expandtab     = true -- convert tabs to spaces
vim.opt.smartindent   = true
vim.opt.autoindent    = true

if not in_vscode then
  -- Settings that only apply to regular Neovim (not VSCode)
  require("vim-settings")
  
  -- Enhanced auto-reload configuration
  vim.o.autoread = true -- Automatically read files when they change outside of Vim
  vim.o.autowrite = false -- Don't auto-write unless explicitly requested
  vim.o.autowriteall = false -- Don't auto-write all buffers
  
  -- Disable swap file warnings for auto-reload
  vim.o.shortmess = vim.o.shortmess .. "A" -- Don't give ATTENTION messages for existing swap files
  
  -- And now I make an edit here
  -- More frequent file change checking
  vim.opt.updatetime = 250 -- Faster CursorHold events (0.25 seconds)
  --Check this out
  -- Timer-based auto-reload (4x per second = every 250ms)
  local reload_timer = vim.uv.new_timer()
  reload_timer:start(250, 250, function()
    vim.schedule(function()
      -- Only check if we're in a valid buffer and not in command mode
      if vim.bo.buftype == "" and vim.fn.filereadable(vim.fn.expand("%")) == 1 and vim.fn.mode() ~= "c" then
        vim.cmd("silent! checktime")
      end
    end)
  end)
  
  -- More aggressive auto-reload with better conflict handling and debugging
  vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained", "CursorHold", "CursorHoldI" },
    {
      pattern = "*",
      callback = function()
        -- Only check if we're not in command mode and buffer is readable
        if vim.fn.mode() ~= "c" and vim.bo.buftype == "" and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          -- Silent checktime - will only warn if there are real conflicts
          vim.cmd("silent! checktime")
        end
      end,
      desc = "Auto-reload files when changed externally"
    }
  )
  
  -- Add more aggressive polling as backup
  local last_check = vim.uv.hrtime()
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      local now = vim.uv.hrtime()
      -- Check every 500ms when cursor moves
      if (now - last_check) > 500000000 then -- 500ms in nanoseconds
        last_check = now
        if vim.bo.buftype == "" and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          vim.cmd("silent! checktime")
        end
      end
    end,
    desc = "Backup file change detection on cursor movement"
  })
  
  -- Manual command to test file change detection
  vim.api.nvim_create_user_command("CheckFileChanges", function()
    vim.cmd("checktime")
    vim.notify("Manual file check triggered", vim.log.levels.INFO, { title = "Debug" })
  end, { desc = "Manually check for file changes" })
  
  -- Rapid auto-save: Save immediately when you start editing to prevent conflicts
  local auto_save_enabled = true
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    pattern = "*",
    callback = function()
      if auto_save_enabled and vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
        -- Check if this is a real file (not scratch buffer)
        local filename = vim.fn.expand("%:p")
        if vim.fn.filereadable(filename) == 1 then
          vim.cmd("silent! write")
        end
      end
    end,
    desc = "Immediately save changes to prevent external editing conflicts"
  })
  
  -- Toggle rapid auto-save
  vim.api.nvim_create_user_command("ToggleAutoSave", function()
    auto_save_enabled = not auto_save_enabled
    vim.notify("Rapid auto-save: " .. (auto_save_enabled and "ON" or "OFF"), vim.log.levels.INFO, { title = "Auto-save" })
  end, { desc = "Toggle rapid auto-save on/off" })
  
  -- Debug command to show file stats
  vim.api.nvim_create_user_command("FileDebug", function()
    local filename = vim.fn.expand("%")
    local modified = vim.bo.modified
    local autoread = vim.o.autoread
    local readable = vim.fn.filereadable(filename)
    
    vim.notify(string.format([[File Debug Info:
File: %s
Modified: %s
Autoread: %s
Readable: %s
Update time: %s ms]], 
      filename, 
      modified and "Yes" or "No",
      autoread and "Yes" or "No", 
      readable == 1 and "Yes" or "No",
      vim.o.updatetime
    ), vim.log.levels.INFO, { title = "File Debug" })
  end, { desc = "Show file change debug info" })

  -- Handle external file changes more gracefully with intelligent merging
  vim.api.nvim_create_autocmd("FileChangedShell", {
    pattern = "*",
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local filename = vim.api.nvim_buf_get_name(bufnr)
      
      -- Debug: Show current state
      local is_modified = vim.bo.modified
      
      -- If buffer is unmodified, just reload silently
      if not is_modified then
        vim.cmd("silent! edit")
        vim.notify("File reloaded: " .. vim.fn.expand("%:t"), vim.log.levels.INFO, { title = "Auto-reload" })
        return
      end
      
      -- Buffer has unsaved changes - perform smart diff-based merge ON TOP of unsaved content
      local function smart_diff_merge()
        vim.notify("Intelligently merging external and local changes...", vim.log.levels.INFO, { title = "Smart Merge" })
        
        -- Get current buffer content (includes ALL unsaved changes)
        local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        
        -- Get external file content (what's actually on disk now)
        local external_lines = {}
        local ok, file = pcall(io.open, filename, "r")
        if ok and file then
          for line in file:lines() do
            table.insert(external_lines, line)
          end
          file:close()
        else
          return false -- Can't read external file
        end
        
        local current_text = table.concat(current_lines, "\n")
        local external_text = table.concat(external_lines, "\n")
        
        -- If they're identical, nothing to do
        if current_text == external_text then
          vim.notify("No differences to merge", vim.log.levels.INFO, { title = "Auto-merge" })
          return true
        end
        
        -- Intelligent merge: Preserve ALL unsaved content and add external additions
        local function intelligent_merge()
          -- Use external structure as a guide but preserve local modifications
          local result = {}
          local current_set = {}
          local current_index = {}
          
          -- Build lookup tables for current content
          for i, line in ipairs(current_lines) do
            current_set[line] = true
            if not current_index[line] then
              current_index[line] = i
            end
          end
          
          -- Process external lines and integrate with current content
          local processed = {}
          for i, ext_line in ipairs(external_lines) do
            if current_set[ext_line] then
              -- Line exists in current - use it (preserves local modifications if any)
              if not processed[ext_line] then
                table.insert(result, ext_line)
                processed[ext_line] = true
              end
            else
              -- New line from external - add it in proper position
              if ext_line:match("%S") then -- Only non-empty lines
                table.insert(result, ext_line)
              end
            end
          end
          
          -- Add any local lines that weren't in external (local additions)
          for _, curr_line in ipairs(current_lines) do
            if not processed[curr_line] and curr_line:match("%S") then
              table.insert(result, curr_line)
            end
          end
          
          return result
        end
        
        -- Perform the intelligent merge
        local merged_content = intelligent_merge()
        
        -- Only update if content actually changed
        local new_text = table.concat(merged_content, "\n")
        if new_text ~= current_text then
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, merged_content)
          vim.notify("Merged external changes while preserving local additions", vim.log.levels.INFO, { title = "Smart Merge" })
        else
          vim.notify("No changes needed - keeping current content", vim.log.levels.INFO, { title = "Smart Merge" })
        end
        
        -- Keep the buffer marked as modified since we still have unsaved changes
        vim.bo.modified = true
        
        return true
      end
      
      -- Attempt the smart merge
      if not smart_diff_merge() then
        -- Fallback: just keep local changes
        vim.notify("Could not read external file, keeping your unsaved changes", vim.log.levels.WARN, { title = "File Conflict" })
      end
    end,
    desc = "Handle external file changes with smart diff-based merging preserving unsaved content"
  })

  -- Install lazy.nvim if not already installed
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Configure Lazy to use HTTPS instead of SSH for regular Neovim
  require("lazy").setup("plugins", {
    git = {
      url_format = "https://github.com/%s.git",
    },
  })
else
  -- VSCode-specific configuration
  require("vscode-settings")
  
  -- Install lazy.nvim for VSCode-compatible plugins
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
  
  -- Load only VSCode-compatible plugins
  require("lazy").setup("plugins.vscode-plugins", {
    git = {
      url_format = "https://github.com/%s.git",
    },
  })
end


-- External changes:

-- Deoptimize
vim.g.mapleader = ' '

-- Detect if we're running in VSCode
local in_vscode = vim.g.vscode ~= nil

-- Basic settings that work in both VSCode and regular Neovim
vim.opt.tabstop       = 2    -- number of visual spaces per TAB
vim.opt.softtabstop   = 2    -- number of spaces for a <Tab> in insert mode
vim.opt.shiftwidth    = 2    -- size of an indent
vim.opt.expandtab     = true -- convert tabs to spaces
vim.opt.smartindent   = true
vim.opt.autoindent    = true

if not in_vscode then
  -- Settings that only apply to regular Neovim (not VSCode)
  require("vim-settings")
  
  -- Enhanced auto-reload configuration
  vim.o.autoread = true -- Automatically read files when they change outside of Vim
  vim.o.autowrite = false -- Don't auto-write unless explicitly requested
  vim.o.autowriteall = false -- Don't auto-write all buffers
  
  -- Disable swap file warnings for auto-reload
  vim.o.shortmess = vim.o.shortmess .. "A" -- Don't give ATTENTION messages for existing swap files
  
  -- More frequent file change checking
  vim.opt.updatetime = 250 -- Faster CursorHold events (0.25 seconds)
  
  -- Timer-based auto-reload (4x per second = every 250ms)
  local reload_timer = vim.uv.new_timer()
  reload_timer:start(250, 250, function()
    vim.schedule(function()
      -- Only check if we're in a valid buffer and not in command mode
      if vim.bo.buftype == "" and vim.fn.filereadable(vim.fn.expand("%")) == 1 and vim.fn.mode() ~= "c" then
        vim.cmd("silent! checktime")
      end
    end)
  end)
  
  -- More aggressive auto-reload with better conflict handling and debugging
  vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained", "CursorHold", "CursorHoldI" },
    {
      pattern = "*",
      callback = function()
        -- Only check if we're not in command mode and buffer is readable
        if vim.fn.mode() ~= "c" and vim.bo.buftype == "" and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          -- Silent checktime - will only warn if there are real conflicts
          vim.cmd("silent! checktime")
        end
      end,
      desc = "Auto-reload files when changed externally"
    }
  )
  
  -- Add more aggressive polling as backup
  local last_check = vim.uv.hrtime()
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      local now = vim.uv.hrtime()
      -- Check every 500ms when cursor moves
      if (now - last_check) > 500000000 then -- 500ms in nanoseconds
        last_check = now
        if vim.bo.buftype == "" and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
          vim.cmd("silent! checktime")
        end
      end
    end,
    desc = "Backup file change detection on cursor movement"
  })
  
  -- Manual command to test file change detection
  vim.api.nvim_create_user_command("CheckFileChanges", function()
    vim.cmd("checktime")
    vim.notify("Manual file check triggered", vim.log.levels.INFO, { title = "Debug" })
  end, { desc = "Manually check for file changes" })
  
  -- Rapid auto-save: Save immediately when you start editing to prevent conflicts
  local auto_save_enabled = true
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    pattern = "*",
    callback = function()
      if auto_save_enabled and vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
        -- Check if this is a real file (not scratch buffer)
        local filename = vim.fn.expand("%:p")
        if vim.fn.filereadable(filename) == 1 then
          vim.cmd("silent! write")
        end
      end
    end,
    desc = "Immediately save changes to prevent external editing conflicts"
  })
  
  -- Toggle rapid auto-save
  vim.api.nvim_create_user_command("ToggleAutoSave", function()
    auto_save_enabled = not auto_save_enabled
    vim.notify("Rapid auto-save: " .. (auto_save_enabled and "ON" or "OFF"), vim.log.levels.INFO, { title = "Auto-save" })
  end, { desc = "Toggle rapid auto-save on/off" })
  
  -- Debug command to show file stats
  vim.api.nvim_create_user_command("FileDebug", function()
    local filename = vim.fn.expand("%")
    local modified = vim.bo.modified
    local autoread = vim.o.autoread
    local readable = vim.fn.filereadable(filename)
    
    vim.notify(string.format([[File Debug Info:
File: %s
Modified: %s
Autoread: %s
Readable: %s
Update time: %s ms]], 
      filename, 
      modified and "Yes" or "No",
      autoread and "Yes" or "No", 
      readable == 1 and "Yes" or "No",
      vim.o.updatetime
    ), vim.log.levels.INFO, { title = "File Debug" })
  end, { desc = "Show file change debug info" })

  -- Handle external file changes more gracefully with intelligent merging
  vim.api.nvim_create_autocmd("FileChangedShell", {
    pattern = "*",
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local filename = vim.api.nvim_buf_get_name(bufnr)
      
      -- Debug: Show current state
      local is_modified = vim.bo.modified
      
      -- If buffer is unmodified, just reload silently
      if not is_modified then
        vim.cmd("silent! edit")
        vim.notify("File reloaded: " .. vim.fn.expand("%:t"), vim.log.levels.INFO, { title = "Auto-reload" })
        return
      end
      
      -- Buffer has unsaved changes - perform smart diff-based merge ON TOP of unsaved content
      local function smart_diff_merge()
        vim.notify("Intelligently merging external and local changes...", vim.log.levels.INFO, { title = "Smart Merge" })
        
        -- Get current buffer content (includes ALL unsaved changes)
        local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        
        -- Get external file content (what's actually on disk now)
        local external_lines = {}
        local ok, file = pcall(io.open, filename, "r")
        if ok and file then
          for line in file:lines() do
            table.insert(external_lines, line)
          end
          file:close()
        else
          return false -- Can't read external file
        end
        
        local current_text = table.concat(current_lines, "\n")
        local external_text = table.concat(external_lines, "\n")
        
        -- If they're identical, nothing to do
        if current_text == external_text then
          vim.notify("No differences to merge", vim.log.levels.INFO, { title = "Auto-merge" })
          return true
        end
        
        -- Intelligent merge: Preserve ALL unsaved content and add external additions
        local function intelligent_merge()
          -- Use external structure as a guide but preserve local modifications
          local result = {}
          local current_set = {}
          local current_index = {}
          
          -- Build lookup tables for current content
          for i, line in ipairs(current_lines) do
            current_set[line] = true
            if not current_index[line] then
              current_index[line] = i
            end
          end
          
          -- Process external lines and integrate with current content
          local processed = {}
          for i, ext_line in ipairs(external_lines) do
            if current_set[ext_line] then
              -- Line exists in current - use it (preserves local modifications if any)
              if not processed[ext_line] then
                table.insert(result, ext_line)
                processed[ext_line] = true
              end
            else
              -- New line from external - add it in proper position
              if ext_line:match("%S") then -- Only non-empty lines
                table.insert(result, ext_line)
              end
            end
          end
          
          -- Add any local lines that weren't in external (local additions)
          for _, curr_line in ipairs(current_lines) do
            if not processed[curr_line] and curr_line:match("%S") then
              table.insert(result, curr_line)
            end
          end
          
          return result
        end
        
        -- Perform the intelligent merge
        local merged_content = intelligent_merge()
        
        -- Only update if content actually changed
        local new_text = table.concat(merged_content, "\n")
        if new_text ~= current_text then
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, merged_content)
          vim.notify("Merged external changes while preserving local additions", vim.log.levels.INFO, { title = "Smart Merge" })
        else
          vim.notify("No changes needed - keeping current content", vim.log.levels.INFO, { title = "Smart Merge" })
        end
        
        -- Keep the buffer marked as modified since we still have unsaved changes
        vim.bo.modified = true
        
        return true
      end
      
      -- Attempt the smart merge
      if not smart_diff_merge() then
        -- Fallback: just keep local changes
        vim.notify("Could not read external file, keeping your unsaved changes", vim.log.levels.WARN, { title = "File Conflict" })
      end
    end,
    desc = "Handle external file changes with smart diff-based merging preserving unsaved content"
  })

  -- Install lazy.nvim if not already installed
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Configure Lazy to use HTTPS instead of SSH for regular Neovim
  require("lazy").setup("plugins", {
    git = {
      url_format = "https://github.com/%s.git",
    },
  })
else
  -- VSCode-specific configuration
  require("vscode-settings")
  
  -- Install lazy.nvim for VSCode-compatible plugins
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
  
  require("lazy").setup("plugins.vscode-plugins", {
    git = {
      url_format = "https://github.com/%s.git",
    },
  })
end