return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'prisma-language-server', 'postgres-language-server' },
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
        ensure_installed = { 'sql-formatter', 'pgformatter' },
      },
    },
    opts = {
      formatters_by_ft = {
        sql = { 'pg_format', 'sql_formatter', stop_after_first = false },
      },
      formatters = {
        sql_formatter = {
          append_args = { '--language=postgresql' },
        },
        pg_format = {
          append_args = { '--spaces=2', '--keep-newline', '--wrap-limit=80' },
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
