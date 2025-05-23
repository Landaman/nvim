return {
  {
    'nvimtools/none-ls.nvim',
    cond = not vim.g.vscode,
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    dependencies = {
      {
        'jay-babu/mason-null-ls.nvim',
        opts = {
          handlers = {},
          automatic_installation = false,
          ensure_installed = {
            'markdownlint',
          },
        },
      },
    },
    config = function()
      local null_ls = require 'null-ls'

      null_ls.setup {
        update_in_insert = false,
        sources = {},
      }
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
