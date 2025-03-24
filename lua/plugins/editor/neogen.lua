return {
  'danymat/neogen',
  cond = not vim.g.vscode,
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
