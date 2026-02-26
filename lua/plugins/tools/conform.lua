function get_web_formatter()
  if #vim.fs.find('.oxfmtrc.json', { upward = true, type = 'file' }) >= 1 then
    return 'oxfmt'
  end

  return 'prettierd'
end

return {
  'stevearc/conform.nvim',
  dependencies = {
    {
      'williamboman/mason.nvim',
      opts = {
        ensure_installed = { 'prettierd', 'oxfmt' },
      },
    },
  },
  cond = not vim.g.vscode,
  event = { 'BufWritePre' },
  opts = {
    format_on_save = {},
    default_format_opts = {
      lsp_format = 'fallback',
      stop_after_first = true,
    },
    formatters = {
      web = {
        inherit = get_web_formatter(),
      },
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
