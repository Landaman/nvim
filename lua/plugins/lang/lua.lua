return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and pluginslspconf
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    cond = not vim.g.vscode,
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
    dependencies = {
      {
        'saghen/blink.cmp',
        opts = {
          sources = {
            -- add lazydev to your completion providers
            default = { 'lazydev' },
            providers = {
              lazydev = {
                name = 'LazyDev',
                module = 'lazydev.integrations.blink',
                score_offset = 100, -- show at a higher priority than lsp
              },
            },
          },
        },
      },
      'Bilal2453/luvit-meta',
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'lua_ls' },
      handlers = {
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Disable',
              },
              hint = {
                enable = true,
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    dependencies = {
      {

        'williamboman/mason.nvim',
        opts = {
          ensure_installed = { 'stylua' },
        },
      },
    },
    opts = { formatters_by_ft = { lua = { 'stylua' } } },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'lua',
        'luadoc',
      },
    },
  },
}
