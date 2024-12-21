return {
  {
    'mfussenegger/nvim-dap-python',
    ft = { 'python' },
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'debugpy' },
        },
      },
    },
    config = function()
      local python = require('mason-registry').get_package('debugpy'):get_install_path() .. '/venv/bin/python'
      require('dap-python').setup(python)
    end,
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    opts = {
      handlers = {
        python = function() end, -- Without this, python venv detection breaks
      },
    },
  },
  {
    'jay-babu/mason-null-ls.nvim',
    opts = { ensure_installed = { 'black' } },
  },
  {
    'mfussenegger/nvim-dap',
    opts = {
      handlers = {
        debugpy = function(config)
          require('lazy').load { plugins = { 'nvim-dap-python' } } -- Ensure that F5 on startup always works for Python launch configs
          return config
        end,
      },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'basedpyright' },
      handlers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticMode = 'workspace',
                typeCheckingMode = 'standard',
                diagnosticSeverityOverrides = {
                  reportUnnecessaryComparison = 'warning',
                  reportUnnecessaryIsInstance = 'warning',
                  reportUnnecessaryCast = 'warning',
                  reportUnnecessaryContains = 'warning',
                  reportAssertAlwaysTrue = 'warning',
                },
              },
            },
          },
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'python',
      },
    },
  },
}
