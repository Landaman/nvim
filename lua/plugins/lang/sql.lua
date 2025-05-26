return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'prisma-language-server', 'postgrestools' },
        },
      },
    },
    opts = {
      config = {
        prismals = {},
        postgres_lsp = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = { 'pgformatter' },
      },
    },
    opts = {
      formatters_by_ft = {
        sql = { 'pg_format' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'prisma',
      },
    },
  },
}
