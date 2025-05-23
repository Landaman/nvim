return {
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'svelte' },
      handlers = {
        svelte = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = vim.fn.has 'nvim-0.10' == 0 and { dynamicRegistration = true },
            },
          },
        },
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
        svelte = { 'prettierd' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'svelte',
      },
    },
  },
}
