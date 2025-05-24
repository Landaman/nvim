return {
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
        markdown = { 'prettierd' },
        ['markdown.mdx'] = { 'prettierd' },
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = { 'markdownlint' },
      },
    },
    opts = {
      linters_by_ft = {
        markdown = { 'markdownlint' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'markdown',
        'markdown_inline',
      },
    },
  },
}
