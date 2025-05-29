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
        ensure_installed = { 'sql-formatter' },
      },
    },
    opts = {
      formatters_by_ft = {
        sql = { 'sql_formatter' },
      },
      formatters = {
        sql_formatter = {
          append_args = { '--language=postgresql' },
        },
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
