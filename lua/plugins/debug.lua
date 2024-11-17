return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Creates a beautiful debugger UI
    {
      'rcarriga/nvim-dap-ui',
      opts = {},
      config = function(_, opts)
        local dap = require 'dap'
        local dapui = require 'dapui'
        dapui.setup(opts)
        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open {}
        end
      end,
      dependencies = {
        'nvim-neotest/nvim-nio',
      },
    },

    -- Adds inline comments
    { 'theHamsta/nvim-dap-virtual-text', opts = { clear_on_continue = false, enabled_commands = true } },

    -- Installs the debug adapters for you
    { 'WhoIsSethDaniel/mason-tool-installer.nvim', opts = { ensure_installed = 'js-debug-adapter' } },
    {
      'jay-babu/mason-nvim-dap.nvim',
      config = function() end, -- This is loaded when DAP itself loads
    },
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F6>',
      function()
        require('dap').run_last()
      end,
      desc = 'Debug: Restart',
    },
    {
      '<F7>',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Terminate',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<F4>',
      function()
        require('dap').step_back()
      end,
      desc = 'Debug: Step Back',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle [b]reakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set [B]reakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F10>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result',
    },
    {
      '<F9>',
      function()
        require('dapui').toggle {
          layout = 0,
          reset = true,
        }
      end,
    },
  },
  opts = function()
    local dap = require 'dap'

    pcall(require, 'mason') -- make sure Mason is loaded
    local root = vim.env.MASON or (vim.fn.stdpath 'data' .. '/mason') -- Base path for the debug adapter

    if not dap.adapters['node-terminal'] then
      require('dap').adapters['node-terminal'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            root .. '/packages/' .. 'js-debug-adapter' .. '/' .. '/js-debug/src/dapDebugServer.js',
            '${port}',
          },
        },
      }
    end

    if not dap.adapters['pwa-chrome'] then -- This is the Chrome adapter
      require('dap').adapters['pwa-chrome'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            root .. '/packages/' .. 'js-debug-adapter' .. '/' .. '/js-debug/src/dapDebugServer.js',
            '${port}',
          },
        },
      }
    end
    if not dap.adapters['chrome'] then -- This provides compatibility with (technically wrong) launch.json files
      dap.adapters['chrome'] = function(cb, config)
        if config.type == 'chrome' then
          config.type = 'pwa-chrome'
        end
        local nativeAdapter = dap.adapters['pwa-chrome']
        if type(nativeAdapter) == 'function' then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    if not dap.adapters['pwa-node'] then -- This is the node adapter
      require('dap').adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            root .. '/packages/' .. 'js-debug-adapter' .. '/' .. '/js-debug/src/dapDebugServer.js',
            '${port}',
          },
        },
      }
    end
    if not dap.adapters['node'] then -- This provides compatibility with (technically wrong) launch.json files
      dap.adapters['node'] = function(cb, config)
        if config.type == 'node' then
          config.type = 'pwa-node'
        end
        local nativeAdapter = dap.adapters['pwa-node']
        if type(nativeAdapter) == 'function' then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

    local vscode = require 'dap.ext.vscode'
    vscode.type_to_filetypes['pwa-node'] = js_filetypes
    vscode.type_to_filetypes['node'] = js_filetypes
    vscode.type_to_filetypes['pwa-chrome'] = js_filetypes
    vscode.type_to_filetypes['chrome'] = js_filetypes

    -- This makes it so that you can launch any JS/TS file in Node and can always attach in those cases
    for _, language in ipairs(js_filetypes) do
      if not dap.configurations[language] then
        dap.configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file (Node.js)',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach (Node.js)',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end

    dap.configurations.scala = {
      {
        type = 'scala',
        request = 'launch',
        name = 'Run or Test File',
        metals = {
          runType = 'runOrTestFile',
        },
      },
      {
        type = 'scala',
        request = 'launch',
        name = 'Test Target',
        metals = {
          runType = 'testTarget',
        },
      },
    }
  end,
  config = function()
    -- Setup nvim-dap here, now that we've loaded everything we want to load to avoid conflicts
    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = false,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {
        python = function() end, -- Without this, python venv detection breaks
      },

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
      },
    }
    -- Define breakpoint icons
    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DAPUIStop' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DAPUIStop' })
    vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DAPUIStop' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = 'DAPUIStop' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DAPUIStop' })

    -- setup dap config by VsCode launch.json file
    local vscode = require 'dap.ext.vscode'
    local json = require 'plenary.json'
    vscode.json_decode = function(str)
      raw_config = vim.json.decode(json.json_strip_comments(str))

      -- Scala needs special handling because metals sucks
      result = {}
      result.version = raw_config.version
      result.configurations = {}
      for index, config in ipairs(raw_config.configurations) do
        if config.type == 'debugpy' then
          require('lazy').load { plugins = { 'nvim-dap-python' } } -- Ensure that F5 on startup always works for Python launch configs
        end

        if config.type == 'scala' then
          require('lazy').load { plugins = { 'nvim-metals' } } -- Ensure that F5 on startup always works for Scala launch configs
          require('metals').setup_dap()
        end

        if config.type == 'java' then
          require('lazy').load { plugins = { 'nvim-jdtls' } } -- Ensure that F5 on startup always works for Java launch configs
        end

        if config.type ~= 'scala' then
          result.configurations[index] = config
        else
          scala_config = {}
          scala_config['metals'] = {}

          for key, value in pairs(config) do
            if key == 'type' or key == 'request' or key == 'name' then
              scala_config[key] = value
            else
              scala_config['metals'][key] = value
            end
          end

          result.configurations[index] = scala_config
        end
      end

      return result
    end
  end,
}
