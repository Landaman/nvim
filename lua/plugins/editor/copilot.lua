return {
  'github/copilot.vim',
  event = vim.g.lazy_file,
  cond = not vim.g.vscode,
}
