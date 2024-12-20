return {
  'folke/trouble.nvim',
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = 'Trouble',
  keys = {
    {
      '<leader>wq',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Trouble: [q] Workspace diagnostics',
    },
    {
      '<leader>dd',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Trouble: Document [d]iagnostics',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
