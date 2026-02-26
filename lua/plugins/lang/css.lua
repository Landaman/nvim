return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = { 'css-lsp', 'tailwindcss-language-server' },
      },
    },
    opts = {
      config = {
        cssls = {},
        tailwindCSS = {},
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'css',
        'scss',
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        css = { 'web' },
        scss = { 'web' },
        less = { 'web' },
      },
    },
  },
}
