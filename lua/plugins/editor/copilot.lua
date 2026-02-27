return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  cond = not vim.g.vscode,
  build = ':Copilot auth',
  event = 'BufReadPost',
  opts = {
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = '<Tab>',
        accept_word = '<M-Right>',
        accept_line = '<M-C-Right>',
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
      },
    },
    panel = { enabled = false },
  },
}
