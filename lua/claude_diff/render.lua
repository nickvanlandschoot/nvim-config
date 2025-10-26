-- Rendering logic for Claude diff plugin
--
-- RESPONSIBILITIES:
-- - Render hunks as extmarks in buffer
-- - Create visual highlights and virtual text
-- - Bounds checking before rendering
-- - No state modification, no diff calculation
local M = {}

-- Create namespace for extmarks
M.ns = vim.api.nvim_create_namespace("ClaudeDiff")

-- Initialize highlight groups
function M.setup_highlights()
  vim.api.nvim_set_hl(0, "ClaudeAdd", { link = "DiffAdd" })
  vim.api.nvim_set_hl(0, "ClaudeDel", { link = "DiffDelete" })
  vim.api.nvim_set_hl(0, "ClaudeChange", { link = "DiffChange" })
  vim.api.nvim_set_hl(0, "ClaudeConflict", { link = "ErrorMsg" })
  vim.api.nvim_set_hl(0, "ClaudeDeletedText", { fg = "#ff6b6b", italic = true, bg = "#3a1f1f" })
end

-- Clear all extmarks for given hunks
function M.clear_marks(buf, hunks)
  for _, h in ipairs(hunks or {}) do
    if h.mark_ids then
      for _, id in ipairs(h.mark_ids) do
        pcall(vim.api.nvim_buf_del_extmark, buf, M.ns, id)
      end
    end
  end
end

-- Render all hunks in the buffer with extmarks
function M.render_hunks(buf, st)
  -- Clear all extmarks in the namespace (old hunks may have been replaced/removed)
  vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)

  -- Get buffer line count for bounds checking
  local buf_line_count = vim.api.nvim_buf_line_count(buf)

  -- Render highlights and virtual text for each hunk
  for _, h in ipairs(st.hunks) do
    h.mark_ids = {}

    -- Validate hunk positions
    if h.s < 1 or h.e < h.s - 1 then
      goto continue
    end

    if h.kind == "add" then
      -- Addition: green highlight on new lines
      if h.e <= buf_line_count then
        local ok, id = pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, h.s - 1, 0, {
          end_row = h.e,
          end_col = 0,
          hl_group = h.conflicted and "ClaudeConflict" or "ClaudeAdd",
          hl_eol = true,
        })
        if ok then
          table.insert(h.mark_ids, id)
        end

        -- Add annotation
        local ok2, id2 = pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, h.s - 1, 0, {
          virt_text = { { " AI added", "NonText" } },
          virt_text_pos = "eol",
          priority = 200,
        })
        if ok2 then
          table.insert(h.mark_ids, id2)
        end
      end

    elseif h.kind == "del" then
      -- Deletion: show deleted content as virtual lines
      -- Position is where content was deleted (h.s = h.e + 1 for deletions)
      local virt_lines = {}
      for _, line in ipairs(h.old) do
        table.insert(virt_lines, { { "- " .. line, "ClaudeDeletedText" } })
      end

      if h.s - 1 <= buf_line_count and #virt_lines > 0 then
        local ok, id = pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, h.s - 1, 0, {
          virt_lines = virt_lines,
          virt_lines_above = false,
        })
        if ok then
          table.insert(h.mark_ids, id)
        end
      end

    elseif h.kind == "change" then
      -- Change: green highlight on new lines + virtual text showing old content
      if h.e <= buf_line_count then
        -- Highlight new content in green
        local ok, id = pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, h.s - 1, 0, {
          end_row = h.e,
          end_col = 0,
          hl_group = h.conflicted and "ClaudeConflict" or "ClaudeAdd",
          hl_eol = true,
        })
        if ok then
          table.insert(h.mark_ids, id)
        end

        -- Show old content as virtual lines below
        local virt_lines = {}
        for _, line in ipairs(h.old) do
          table.insert(virt_lines, { { "- " .. line, "ClaudeDeletedText" } })
        end

        if #virt_lines > 0 then
          local ok2, id2 = pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, h.e - 1, 0, {
            virt_lines = virt_lines,
            virt_lines_above = false,
          })
          if ok2 then
            table.insert(h.mark_ids, id2)
          end
        end

        -- Add annotation
        local ok3, id3 = pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, h.s - 1, 0, {
          virt_text = { { " AI changed", "NonText" } },
          virt_text_pos = "eol",
          priority = 200,
        })
        if ok3 then
          table.insert(h.mark_ids, id3)
        end
      end
    end

    ::continue::
  end
end

-- Clear all marks in a buffer
function M.clear_buffer(buf)
  vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
end

return M
