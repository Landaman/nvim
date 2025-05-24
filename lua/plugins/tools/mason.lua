return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonLog', 'MasonUpdate', 'MasonUninstall', 'MasonUninstallAll' },
    build = ':MasonUpdate',
    cond = not vim.g.vscode,
    opts = { ensure_installed = {} }, -- This is required to ensure setup actually happens
    config = function(_, opts)
      require('mason').setup(opts)

      -- This actually does the "ensure installed" work
      local mr = require 'mason-registry'
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
    'jay-babu/mason-nvim-dap.nvim',
    cond = not vim.g.vscode,
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
