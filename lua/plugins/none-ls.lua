local function is_null_ls_formatting_enabled(bufnr)
  local file_type = vim.bo[bufnr].filetype
  local generators = require('null-ls.generators').get_available(file_type, require('null-ls.methods').internal.FORMATTING)
  return #generators > 0
end

local function format_with_lsp(bufnr)
  vim.lsp.buf.format {
    filter = function(client)
      return client.name == 'null-ls' or not is_null_ls_formatting_enabled(bufnr)
    end,
    bufnr = bufnr,
  }
end

return {
  'nvimtools/none-ls.nvim',
  event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
  dependencies = {
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = {
          'stylua',
          'prettierd',
          'markdownlint',
          'black',
          'cspell',
        },
      },
    },
    'davidmh/cspell.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local cspell = require 'cspell'

    vim.keymap.set({ 'n' }, '<leader>ff', function()
      format_with_lsp(vim.api.nvim_get_current_buf())
    end, { desc = '[f]ormat buffer' })

    local lsp_save_augroup = vim.api.nvim_create_augroup('LspSaveFormatting', {})
    null_ls.setup {
      on_attach = function(_, bufnr)
        vim.api.nvim_clear_autocmds { group = lsp_save_augroup, buffer = bufnr }
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = lsp_save_augroup,
          buffer = bufnr,
          callback = function()
            format_with_lsp(bufnr)
          end,
        })
      end,

      sources = {
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.markdownlint,
        cspell.diagnostics.with {
          -- info rather than errors
          diagnostics_postprocess = function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity.INFO
          end,
        },
        cspell.code_actions,
      },
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
