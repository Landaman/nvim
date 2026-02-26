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
    opts = {
      formatters_by_ft = {
        html = { 'web' },
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
