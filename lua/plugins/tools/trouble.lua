return {
  'folke/trouble.nvim',
  cond = not vim.g.vscode,
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = 'Trouble',
  keys = {
    {
      '<leader>wq',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Trouble workspace diagnostics',
    },
    {
      '<leader>dd',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Trouble document diagnostics',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
