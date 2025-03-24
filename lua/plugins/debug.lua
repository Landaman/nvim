return {
  'mfussenegger/nvim-dap',
  cond = not vim.g.vscode,
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
    {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = { 'js-debug-adapter' },
      },
    },
    {
      'jay-babu/mason-nvim-dap.nvim',
      opts = {
        automatic_installation = false,
        handlers = {},
      },
    },
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug start/continue',
    },
    {
      '<F6>',
      function()
        require('dap').run_last()
      end,
      desc = 'Debug restart',
    },
    {
      '<F7>',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug terminate',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Step into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Step over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Step out',
    },
    {
      '<F4>',
      function()
        require('dap').step_back()
      end,
      desc = 'Step back',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Set breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F10>',
      function()
        require('dapui').toggle()
      end,
      desc = 'See last debug session result',
    },
    {
      '<F9>',
      function()
        require('dapui').toggle {
          layout = 0,
          reset = true,
        }
      end,
      desc = 'Reset debug UI layout',
    },
  },
  config = function(_, opts)
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
        -- Use custom setup and rewrites when necessary
        if opts.handlers[config.type] then
          result.configurations[index] = opts.handlers[config.type](config)
        else
          result.configurations[index] = config
        end
      end

      return result
    end
  end,
}
