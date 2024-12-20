return {
  'danymat/neogen',
  cmd = 'Neogen',
  keys = {
    {
      '<leader>cd',
      function()
        require('neogen').generate()
      end,
      desc = 'Generate code documentation',
    },
  },
  opts = {
    snippet_engine = 'nvim',
  },
}
