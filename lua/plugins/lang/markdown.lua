return {
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        markdown = { 'web' },
        ['markdown.mdx'] = { 'web' },
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
