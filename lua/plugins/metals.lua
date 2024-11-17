return {
  'scalameta/nvim-metals',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'j-hui/fidget.nvim',
    'mfussenegger/nvim-dap',
  },
  ft = { 'scala', 'sbt', 'java' },
  opts = function()
    local metals_config = require('metals').bare_config()
    metals_config.init_options.statusBarProvider = 'off' -- Statusbar is annoying

    metals_config.capabilities = require('cmp_nvim_lsp').default_capabilities() -- Disable capabilities

    metals_config.on_attach = function(client, bufnr)
      require('metals').setup_dap()
    end

    return metals_config
  end,
  config = function(self, metals_config)
    function attach_metals()
      require('metals').initialize_or_attach(metals_config)
    end

    local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = self.ft,
      callback = attach_metals,
      group = nvim_metals_group,
    })

    -- Avoids a race condition on first attach
    attach_metals()
  end,
}
