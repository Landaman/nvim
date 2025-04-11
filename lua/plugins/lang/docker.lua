return {
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'dockerls', 'docker_compose_language_service' },
      handlers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'dockerfile',
        'yaml',
      },
    },
  },
}
