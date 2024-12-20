return {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    opts = {}, -- This is required to ensure setup actually happens
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    lazy = true,
    dependencies = {
      'williamboman/mason.nvim',
    },
    opts = {
      ensure_installed = {},
    },
    config = function(_, opts)
      require('mason-tool-installer').setup(opts)
    end,
    opts_extend = {
      'ensure_installed',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et