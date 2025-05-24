return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'docker-compose-language-service', 'dockerfile-language-server' },
        },
      },
    },
    opts = {
      config = {
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
