-- Diagnostic signs to use by default
vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = ' ',
  [vim.diagnostic.severity.WARN] = ' ',
  [vim.diagnostic.severity.INFO] = ' ',
  [vim.diagnostic.severity.HINT] = '󰌵 ',
}

vim.keymap.set({ 'n' }, '<leader>pd', vim.diagnostic.open_float, { desc = 'Peek diagnostics' }) -- This can be used to peek the diagnostic for something that is hidden (see below)

local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go { severity = severity }
  end
end
vim.keymap.set('n', ']d', diagnostic_goto(true), { desc = 'Next diagnostic' })
vim.keymap.set('n', '[d', diagnostic_goto(false), { desc = 'Prev diagnostic' })
vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next error' })
vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Previous error' })
vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next warning' })
vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Previous warning' })

vim.diagnostic.config {
  severity_sort = true,
  update_in_insert = false,
  virtual_text = {
    severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.HINT }, -- Don't show virtual text for info because it gets annoying
  },
  float = {
    prefix = function(diagnostic, i)
      -- Prefix the diagnostic with the correctly highlighted symbol
      local sign = vim.g.diagnostic_signs[diagnostic.severity]

      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        return sign, 'DiagnosticError'
      elseif diagnostic.severity == vim.diagnostic.severity.WARN then
        return sign, 'DiagnosticWarn'
      elseif diagnostic.severity == vim.diagnostic.severity.INFO then
        return sign, 'DiagnosticInfo'
      elseif diagnostic.severity == vim.diagnostic.severity.HINT then
        return sign, 'DiagnosticHint'
      end

      return tostring(i), '' -- This should never happen
    end,
    suffix = function(diagnostic)
      if diagnostic.source == nil then
        return '', '' -- This happens with Oil, among others
      end

      return ' ' .. diagnostic.source, 'TroubleSource'
    end,
  },
  signs = {
    text = vim.g.diagnostic_signs,
    severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.HINT },
    linehl = {
      [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
      [vim.diagnostic.severity.WARN] = 'WarningMsg',
    },
  },
}
