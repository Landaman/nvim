return {
  {
    'neovim/nvim-lspconfig',
    {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = { 'clangd' },
      },
    },
    opts = {
      config = {
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
