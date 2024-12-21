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
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'svelte',
      },
    },
  },
}
