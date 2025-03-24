return {
  {

    'williamboman/mason.nvim',
    opts = {
      ensure_installed = { 'tailwindcss-language-server' },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'cssls' },
      handlers = {
        cssls = {},
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'css',
        'scss',
      },
    },
  },
  {
    'luckasRanarison/tailwind-tools.nvim',
    cond = not vim.g.vscode,
    ft = {
      'html',
      'css',
      'php',
      'twig',
      'vue',
      'heex',
      'astro',
      'templ',
      'svelte',
      'elixir',
      'htmldjango',
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'rust',
    },
    build = ':UpdateRemotePlugins',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'neovim/nvim-lspconfig',
    },
    opts = {},
  },
}
