return {
  {
    'scalameta/nvim-metals',
    dependencies = {
      'saghen/blink.cmp',
      'nvim-lua/plenary.nvim',
      'j-hui/fidget.nvim',
      'mfussenegger/nvim-dap',
    },
    ft = { 'scala', 'sbt', 'java' },
    opts = function()
      local metals_config = require('metals').bare_config()
      metals_config.init_options.statusBarProvider = 'off' -- Statusbar is annoying

      metals_config.capabilities = require('blink.cmp').get_lsp_capabilities() -- Enable capabilities

      metals_config.on_attach = function(_, _)
        require('metals').setup_dap()
      end

      return metals_config
    end,
    config = function(self, metals_config)
      function attach_metals()
        require('metals').initialize_or_attach(metals_config)
      end

      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        callback = attach_metals,
        group = nvim_metals_group,
      })

      -- Avoids a race condition on first attach
      attach_metals()
    end,
  },
  {
    'mfussenegger/nvim-dap',
    opts = function()
      -- Add the default Scala runtimes to the dap
      local dap = require 'dap'
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

      return {
        handlers = {
          scala = function(config)
            require('lazy').load { plugins = { 'nvim-metals' } } -- Ensure that F5 on startup always works for Python launch configs
            require('metals').setup_dap()
            scala_config = {}
            scala_config['metals'] = {}

            for key, value in pairs(config) do
              if key == 'type' or key == 'request' or key == 'name' then
                scala_config[key] = value
              else
                scala_config['metals'][key] = value
              end
            end

            return scala_config
          end,
        },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'scala',
      },
    },
  },
}
