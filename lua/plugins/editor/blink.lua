return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  dependencies = 'rafamadriz/friendly-snippets',
  cond = not vim.g.vscode,
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
      ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback' }
    },

    appearance = { nerd_font_variant = 'mono' },

    signature = { enabled = true },

    snippets = {
      expand = function(snippet)
        vim.snippet.expand(snippet)
      end,
      active = function(filter)
        return vim.snippet.active(filter)
      end,
      jump = function(direction)
        vim.snippet.jump(direction)
      end,
    },

    completion = {
      accept = { auto_brackets = { enabled = true } },
      documentation = {
        auto_show = true,
      },
      menu = {
        draw = {
          treesitter = { 'lsp' },
        },
      },
    },

    cmdline = {
      enabled = false,
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
  },
}
