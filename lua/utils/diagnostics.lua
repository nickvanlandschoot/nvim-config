-- Diagnostic utilities

local M = {}

-- Copy all diagnostics from current buffer to clipboard
function M.copy_all_diagnostics()
  local diagnostics = vim.diagnostic.get(0) -- Get diagnostics for current buffer
  if #diagnostics == 0 then
    vim.notify("No diagnostics to copy", vim.log.levels.INFO)
    return
  end

  -- Severity mapping
  local severity_map = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT"
  }

  local lines = {}
  for _, diag in ipairs(diagnostics) do
    local severity = severity_map[diag.severity] or "UNKNOWN"
    local filename = vim.fn.bufname(diag.bufnr)
    if filename == "" then
      filename = "[No Name]"
    end
    table.insert(lines, string.format("[%s] %s:%d:%d %s", severity, filename, diag.lnum + 1, diag.col + 1, diag.message))
  end
  local text_to_copy = table.concat(lines, "\n")
  vim.fn.setreg('"', text_to_copy) -- Copy to default register
  vim.fn.setreg('+', text_to_copy) -- Copy to system clipboard
  vim.notify("Copied " .. #diagnostics .. " diagnostic(s) to clipboard", vim.log.levels.INFO)
end

return M
