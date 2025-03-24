return {
  'Aasim-A/scrollEOF.nvim',
  cond = not vim.g.vscode,
  event = { 'CursorMoved', 'WinScrolled' },
  opts = {},
}
