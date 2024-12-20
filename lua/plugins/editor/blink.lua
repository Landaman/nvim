return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  dependencies = 'rafamadriz/friendly-snippets',

  -- use a release tag to download pre-built binaries
  version = 'v0.*',
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- see the "default configuration" section below for full documentation on how to define
    -- your own keymap.
    keymap = {
      preset = 'default',
      ['<Tab>'] = {},
      ['<S-Tab>'] = {},
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<C-h>'] = { 'snippet_backward', 'fallback' },
    },

    nerd_font_variant = 'mono',

    windows = {
      autocomplete = {
        winblend = vim.o.pumblend,
      },
      documentation = {
        auto_show = true,
      },
    },

    sources = {
      completion = {
        enabled_providers = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },

    accept = { auto_brackets = { enabled = true } },
    signature = { enabled = true },
  },
  opts_extend = { 'sources.completion.enabled_providers' },
}
