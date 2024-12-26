return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'nix',
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      setup_with_executable = { 'nixd' },
      handlers = {
        nixd = {},
      },
    },
  },
}
