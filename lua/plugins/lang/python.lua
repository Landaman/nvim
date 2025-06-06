return {
  {
    'mfussenegger/nvim-dap-python',
    ft = { 'python' },
    cond = not vim.g.vscode,
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'debugpy' },
        },
      },
    },
    config = function()
      local python = vim.fn.expand '$MASON/packages/debugpy/venv/bin/python'
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
    'stevearc/conform.nvim',
    dependencies = {
      {

        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'black' },
        },
      },
    },
    opts = {
      formatters_by_ft = {
        python = { 'black' },
        htmldjango = { 'prettierd' },
      },
    },
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
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'basedpyright' },
        },
      },
    },
    opts = {
      config = {
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
        'htmldjango',
      },
    },
  },
}
