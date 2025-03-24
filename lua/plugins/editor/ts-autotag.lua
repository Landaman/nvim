return {
  'windwp/nvim-ts-autotag',
  cond = not vim.g.vscode,
  event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
  opts = {},
}
