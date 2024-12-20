return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
      signature = {
        enabled = false, -- Allow blink.cmp to handle signature help
      },
    },
    presets = {
      command_palette = true, -- position the cmdline and popupmenu together
    },
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
}
