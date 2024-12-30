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
        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = '(builtins.getFlake (builtins.toString <flakepath>)).inputs.nixpkgs',
              },
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
