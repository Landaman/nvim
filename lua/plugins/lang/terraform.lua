return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = {
          'terraform-ls',
        },
      },
    },
    opts = {
      config = {
        terraformls = {},
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'terraform',
      },
    },
  },
}
