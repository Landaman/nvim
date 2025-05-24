return {
  {

    'williamboman/mason.nvim',
    opts = {
      ensure_installed = { 'tailwindcss-language-server' },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = { 'css-lsp' },
      },
    },
    opts = {
      config = {
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
        css = { 'prettierd' },
        scss = { 'prettierd' },
        less = { 'prettierd' },
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
