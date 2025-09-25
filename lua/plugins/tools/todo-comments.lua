-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    cond = not vim.g.vscode,
    cmd = { 'TodoTrouble', 'TodoFzfLua' },
    event = vim.g.lazy_file,
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
    keys = {
      {
        '<leader>wo',
        '<cmd>Trouble todo<cr>',
        desc = 'Todo list',
      },
      {
        '<leader>do',
        '<cmd>Trouble todo filter.buf=0<cr>',
        desc = 'Document todo list',
      },
      {
        '<leader>so',
        '<cmd>TodoFzfLua<cr>',
        desc = 'Search todo',
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
