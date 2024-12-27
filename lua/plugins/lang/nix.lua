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
                expr = 'import <nixpkgs> { }',
              },
              formatting = {
                command = { 'nixfmt' },
              },
              options = {
                ['nix-darwin'] = {
                  expr = '(builtins.getFlake (builtins.toString <flakepath>)).darwinConfigurations.Ians-MacBook-Pro-12928.options',
                },
              },
            },
          },
        },
      },
    },
  },
}
