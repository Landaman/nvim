return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = {
          'html-lsp',
        },
      },
    },
    opts = {
      config = {
        html = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    dependencies = {
      {

        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'prettierd' },
        },
      },
    },
    opts = {
      formatters_by_ft = {
        html = { 'prettierd' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'html',
      },
    },
  },
}
