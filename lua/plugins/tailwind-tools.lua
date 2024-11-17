return {
  'luckasRanarison/tailwind-tools.nvim',
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
    'nvim-telescope/telescope.nvim', -- optional
    'neovim/nvim-lspconfig', -- optional
  },
  opts = {}, -- your configuration
}
