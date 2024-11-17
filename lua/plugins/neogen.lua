return {
  'danymat/neogen',
  cmd = 'Neogen',
  keys = {
    {
      '<leader>cd',
      function()
        require('neogen').generate()
      end,
      desc = 'Neogen: Generate [d]ocumentation',
    },
  },
  opts = {
    snippet_engine = 'luasnip',
  },
}
