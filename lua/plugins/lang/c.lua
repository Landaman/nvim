return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      setup_with_executable = { 'clangd' },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'clangd' },
      handlers = {
        clangd = {},
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'c',
      },
    },
  },
}
