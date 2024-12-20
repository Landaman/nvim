return {
  'mfussenegger/nvim-dap-python',
  ft = { 'python' },
  dependencies = {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
      ensure_installed = {
        'debugpy',
      },
    },
  },
  config = function()
    local python = require('mason-registry').get_package('debugpy'):get_install_path() .. '/venv/bin/python'
    require('dap-python').setup(python)
  end,
}
