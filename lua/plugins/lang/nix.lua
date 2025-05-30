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
      config = {
        nixd = {
          settings = {
            nixd = {
              formatting = {
                command = { 'nixfmt' },
              },
              options = {
                ['nix-darwin'] = {
                  expr = '(builtins.getFlake (builtins.toString <flakepath>)).editorDarwinConfiguration.options',
                },
                ['home-manager'] = {
                  expr = '(builtins.getFlake (builtins.toString <flakepath>)).editorHomeManagerConfiguration.options',
                },
              },
            },
          },
        },
      },
    },
  },
}
