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
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'prisma',
      },
    },
  },
}
