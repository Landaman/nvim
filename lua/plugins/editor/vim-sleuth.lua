return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  cond = not vim.g.vscode,
  event = vim.g.lazy_file,
}
