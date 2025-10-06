return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      'mfussenegger/nvim-dap-python',
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require "dap"
      local ui = require "dapui"

      require("dapui").setup()
      require("dap-go").setup()
      require("dap-python").setup("uv")

      require("nvim-dap-virtual-text").setup {
        -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match "secret" or name:match "api" or value:match "secret" or value:match "api" then
            return "*****"
          end

          if #variable.value > 15 then
            return " " .. string.sub(variable.value, 1, 15) .. "... "
          end

          return " " .. variable.value
        end,
      }

      -- VS Code JS Debug Adapter (modern, works for JS/TS/Node)
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', "${port}"},
        }
      }

      -- Chrome/Browser debugging
      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', "${port}"},
        }
      }

      -- JavaScript configurations
      dap.configurations.javascript = {
        {
          name = 'Launch Node.js (current file)',
          type = 'pwa-node',
          request = 'launch',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        {
          name = 'Launch Node.js with args',
          type = 'pwa-node',
          request = 'launch',
          program = '${file}',
          args = function()
            local input = vim.fn.input('Arguments: ')
            return vim.split(input, ' ')
          end,
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        {
          name = 'Attach to Node.js process',
          type = 'pwa-node',
          request = 'attach',
          processId = require'dap.utils'.pick_process,
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },
        {
          name = 'Debug React App (Chrome)',
          type = 'pwa-chrome',
          request = 'launch',
          url = 'http://localhost:3000',
          webRoot = '${workspaceFolder}/src',
          sourceMaps = true,
          userDataDir = false,
        }
      }

      -- TypeScript configurations
      dap.configurations.typescript = {
        {
          name = 'Launch TypeScript (ts-node)',
          type = 'pwa-node',
          request = 'launch',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
          runtimeExecutable = 'npx',
          runtimeArgs = {'ts-node'},
        },
        {
          name = 'Launch TypeScript (tsx)',
          type = 'pwa-node',
          request = 'launch',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
          runtimeExecutable = 'npx',
          runtimeArgs = {'tsx'},
        },
        {
          name = 'Launch compiled JavaScript',
          type = 'pwa-node',
          request = 'launch',
          program = '${workspaceFolder}/dist/${fileBasenameNoExtension}.js',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
          outFiles = {"${workspaceFolder}/dist/**/*.js"},
        },
        {
          name = 'Attach to TypeScript process',
          type = 'pwa-node',
          request = 'attach',
          processId = require'dap.utils'.pick_process,
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        }
      }

      -- React TypeScript configurations
      dap.configurations.typescriptreact = {
        {
          name = 'Debug React TypeScript App',
          type = 'pwa-chrome',
          request = 'launch',
          url = 'http://localhost:3000',
          webRoot = '${workspaceFolder}/src',
          sourceMaps = true,
          userDataDir = false,
        },
        {
          name = 'Debug Next.js (dev)',
          type = 'pwa-node',
          request = 'launch',
          program = '${workspaceFolder}/node_modules/.bin/next',
          args = {'dev'},
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          console = 'integratedTerminal',
        },
        {
          name = 'Debug Next.js (custom port)',
          type = 'pwa-node',
          request = 'launch',
          program = '${workspaceFolder}/node_modules/.bin/next',
          args = {'dev', '--port', '3001'},
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          console = 'integratedTerminal',
        }
      }

      -- JSX configurations (same as React TypeScript)
      dap.configurations.javascriptreact = dap.configurations.typescriptreact

      -- Python configurations (fallback if nvim-dap-python doesn't set them)
      if not dap.configurations.python then
        dap.configurations.python = {
          {
            type = 'python',
            request = 'launch',
            name = "Launch file",
            program = "${file}",
            pythonPath = function()
              return 'uv'
            end,
          },
          {
            type = 'python',
            request = 'launch',
            name = "Launch file with arguments",
            program = "${file}",
            args = function()
              local input = vim.fn.input('Arguments: ')
              return vim.split(input, ' ')
            end,
            pythonPath = function()
              return 'uv'
            end,
          },
        }
      end

      -- Handled by nvim-dap-go
      -- dap.adapters.go = {
      --   type = "server",
      --   port = "${port}",
      --   executable = {
      --     command = "dlv",
      --     args = { "dap", "-l", "127.0.0.1:${port}" },
      --   },
      -- }

      local elixir_ls_debugger = vim.fn.exepath "elixir-ls-debugger"
      if elixir_ls_debugger ~= "" then
        dap.adapters.mix_task = {
          type = "executable",
          command = elixir_ls_debugger,
        }

        dap.configurations.elixir = {
          {
            type = "mix_task",
            name = "phoenix server",
            task = "phx.server",
            request = "launch",
            projectDir = "${workspaceFolder}",
            exitAfterTaskReturns = false,
            debugAutoInterpretAllModules = false,
          },
        }
      end

      -- Enhanced key mappings
      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor, { desc = "Run to cursor" })

      -- Enhanced configuration selection
      vim.keymap.set("n", "<space>dl", function()
        dap.run_last()
      end, { desc = "Debug: Run last configuration" })

      vim.keymap.set("n", "<space>dc", function()
        dap.continue()
      end, { desc = "Debug: Continue/Start" })

      vim.keymap.set("n", "<space>ds", function()
        local filetype = vim.bo.filetype
        local configs = dap.configurations[filetype]
        if not configs or #configs == 0 then
          vim.notify("No debug configurations found for filetype: " .. filetype, vim.log.levels.WARN)
          vim.notify("Supported filetypes: javascript, typescript, typescriptreact, javascriptreact, python, go, elixir", vim.log.levels.INFO)
          return
        end
        
        if #configs == 1 then
          dap.run(configs[1])
        else
          -- Present selection menu
          vim.ui.select(configs, {
            prompt = "Select debug configuration:",
            format_item = function(config)
              return config.name or "Unknown"
            end,
          }, function(choice)
            if choice then
              dap.run(choice)
            end
          end)
        end
      end, { desc = "Debug: Select and run configuration" })

      -- Eval var under cursor
      vim.keymap.set("n", "<space>?", function()
        require("dapui").eval(nil, { enter = true })
      end, { desc = "Evaluate expression" })

      vim.keymap.set("n", "<F1>", dap.continue)
      vim.keymap.set("n", "<F2>", dap.step_into)
      vim.keymap.set("n", "<F3>", dap.step_over)
      vim.keymap.set("n", "<F4>", dap.step_out)
      vim.keymap.set("n", "<F5>", dap.step_back)
      vim.keymap.set("n", "<F6>", dap.toggle_breakpoint)
      vim.keymap.set("n", "<F13>", dap.restart)

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
