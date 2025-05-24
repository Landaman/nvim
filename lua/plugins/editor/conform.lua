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

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('ConformLspAttach', { clear = true }),
      desc = 'Setup Conform as the formatexpr on LspAttach',
      callback = function(event)
        vim.bo[event.buf].formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    })
  end,
}
