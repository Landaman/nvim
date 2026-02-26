return {
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        yaml = { 'web' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'yaml',
      },
    },
  },
}
