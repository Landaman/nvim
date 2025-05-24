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
      setup_with_executable = { 'clangd' },
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
