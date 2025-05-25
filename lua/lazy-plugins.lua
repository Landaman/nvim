-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require('lazy').setup({
  -- This makes it so that the opts_extends are specified, so we can do real setup anywhere.
  -- Otherwise, we'd have to figure out what the first package to load is, and make sure it's there
  {
    'saghen/blink.cmp',
    opts = {
      sources = {
        default = {},
      },
    },
    opts_extend = { 'sources.default' },
  },
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = {} },
    opts_extend = { 'ensure_installed' },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      keymaps = {},
    },
    opts_extend = { 'keymaps' },
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    opts = { ensure_installed = {} },
    opts_extend = { 'ensure_installed' },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    ensure_installed = {},
    opts_extend = { 'ensure_installed' },
  },
  { import = 'plugins' },
}, {
  defaults = { lazy = true },
  rocks = {
    enabled = false,
  },
})

-- vim: ts=2 sts=2 sw=2 et
