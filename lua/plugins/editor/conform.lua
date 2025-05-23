return {
  'stevearc/conform.nvim',
  cond = not vim.g.vscode,
  event = { 'BufWritePre' },
  opts = {
    format_on_save = {},
    default_format_opts = {
      lsp_format = 'fallback',
      stop_after_first = true,
    },
  },
  init = function()
    -- Ensure that we can use gq to format with this
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
