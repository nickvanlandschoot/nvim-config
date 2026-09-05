-- C# language configuration
-- LSP (csharp_ls), DAP (netcoredbg), formatting (csharpier)

local M = {}

local function dotnet_root()
  if vim.env.DOTNET_ROOT and vim.env.DOTNET_ROOT ~= "" then
    return vim.env.DOTNET_ROOT
  end

  if vim.fn.executable("dotnet") ~= 1 then
    return nil
  end

  local info = vim.fn.system({ "dotnet", "--info" })
  local base_path = info:match("Base Path:%s*([^\n]+)")
  if not base_path then
    return nil
  end

  return vim.fn.fnamemodify(base_path:gsub("/sdk/.*$", ""), ":p:h")
end

local function ensure_dotnet_env()
  local root = dotnet_root()
  if root and root ~= "" then
    vim.env.DOTNET_ROOT = root
    vim.env.DOTNET_ROOT_ARM64 = root
  end

  return root
end

function M.setup_lsp(capabilities, on_attach)
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  local csharp_ls = mason_bin .. "/csharp-ls"
  local root = ensure_dotnet_env()

  local function csharp_on_attach(client, bufnr)
    -- csharp-ls 0.24 responds to these requests but does not advertise them,
    -- which makes vim.lsp/telescope reject definition/hover commands up front.
    client.server_capabilities.definitionProvider = true
    client.server_capabilities.hoverProvider = true

    if on_attach then
      on_attach(client, bufnr)
    end
  end

  local function csharp_root_dir(fname, on_dir)
    if type(fname) == "number" then
      fname = vim.api.nvim_buf_get_name(fname)
    end
    local dir = fname and fname ~= "" and vim.fs.dirname(fname) or vim.fn.getcwd()

    local broad_projects_dir = vim.fs.normalize(vim.fn.expand("~/Projects"))
    for parent in vim.fs.parents(dir) do
      local normalized_parent = vim.fs.normalize(parent)
      if normalized_parent ~= broad_projects_dir and (vim.fn.glob(parent .. "/*.sln") ~= "" or vim.fn.glob(parent .. "/*.csproj") ~= "" or vim.uv.fs_stat(parent .. "/global.json")) then
        if on_dir then
          on_dir(parent)
        end
        return parent
      end
    end

    -- Standalone .cs files should not make csharp-ls scan a broad parent like
    -- ~/Projects just because it is a git repository.
    if on_dir then
      on_dir(dir)
    end
    return dir
  end

  vim.lsp.config("csharp_ls", {
    cmd = { csharp_ls },
    cmd_env = root and {
      DOTNET_ROOT = root,
      DOTNET_ROOT_ARM64 = root,
    } or nil,
    filetypes = { "cs" },
    root_dir = csharp_root_dir,
    capabilities = capabilities,
    on_attach = csharp_on_attach,
    init_options = {
      AutomaticWorkspaceInit = true,
    },
  })
end

function M.setup_dap()
  local dap = require("dap")
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  local netcoredbg = mason_bin .. "/netcoredbg"
  local root = ensure_dotnet_env()

  dap.adapters.coreclr = {
    type = "executable",
    command = netcoredbg,
    args = { "--interpreter=vscode" },
    env = root and {
      DOTNET_ROOT = root,
      DOTNET_ROOT_ARM64 = root,
    } or nil,
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "Launch .NET assembly",
      request = "launch",
      program = function()
        return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopAtEntry = false,
      console = "integratedTerminal",
    },
    {
      type = "coreclr",
      name = "Attach to .NET process",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
  }
end

function M.get_formatters()
  ensure_dotnet_env()

  return {
    cs = { "csharpier" },
  }
end

return M
