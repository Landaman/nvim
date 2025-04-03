return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonLog', 'MasonUpdate', 'MasonUninstall', 'MasonUninstallAll' },
    build = ':MasonUpdate',
    cond = not vim.g.vscode,
    opts = { ensure_installed = {} }, -- This is required to ensure setup actually happens
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require 'mason-registry'
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require('lazy.core.handler.event').trigger {
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          }
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    cond = not vim.g.vscode,
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
  {

    'jay-babu/mason-null-ls.nvim',
    cond = not vim.g.vscode,
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
  {

    'jay-babu/mason-nvim-dap.nvim',
    cond = not vim.g.vscode,
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
