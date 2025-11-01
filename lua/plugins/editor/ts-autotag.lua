return {
  'windwp/nvim-ts-autotag',
  cond = not vim.g.vscode,
  event = vim.g.lazy_file,
  opts = {},
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
}
