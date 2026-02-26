return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'json-lsp' },
        },
      },
    },
    opts = {
      config = {
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
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        json = { 'web' },
        jsonc = { 'web' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'json',
        'json5',
      },
    },
  },
}
