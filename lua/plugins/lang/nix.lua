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
                home_manager = {
                  expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
                },
              },
            },
          },
        },
      },
    },
  },
}
