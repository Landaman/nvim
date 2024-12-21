return {
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'jsonls' },
      handlers = {
        jsonls = {
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
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
        'json',
        'json5',
        'jsonc',
      },
    },
  },
}
