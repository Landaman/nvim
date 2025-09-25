return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    cond = not vim.g.vscode,
    event = vim.list_extend({ 'BufReadPre' }, vim.g.lazy_file),
    opts = {
      config = {}, -- Config for the system
    },
    dependencies = {
      'saghen/blink.cmp', -- This ensures the LSP capabilities are augmented correctly. Blink does this automatically
      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function(_, opts)
      require 'lspconfig' -- Ensure that LSPConfig loads the default mappings. This is done since it injects to runtimepath/lsp/...

      -- Configure each LSP
      for lsp, config in pairs(opts.config) do
        vim.lsp.config(lsp, config) -- Ensure the config is updated. This is better than lsp/* since here we know for sure everything will overwrite that

        -- If we don't have the executable *somewhere* for the final (merged) config, notify the user
        if not vim.fn.executable(vim.lsp.config[lsp]['cmd'][1]) then
          vim.notify('lspconfig: Failed to find executable for LSP ' .. lsp, vim.log.levels.WARN)
        else
          vim.lsp.enable(lsp) -- Otherwise, start up
        end
      end

      -- Autocommand to set LSP specific keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspKeymaps', { clear = true }),
        desc = 'Restore Configuration on LSP Attach',
        callback = function(event)
          local Keys = require 'lazy.core.handler.keys'

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return -- This shouldn't matter
          end

          for _, keymap in pairs(Keys.resolve(opts.keymaps)) do
            -- Check if each keymap should be bound
            if not keymap.has or client:supports_method(keymap.has, event.buf) then
              -- Set the opts to as it should be for the vim proper
              local keyOpts = Keys.opts(keymap)
              keyOpts.cond = nil
              keyOpts.has = nil
              keyOpts.silent = keyOpts.silent ~= false
              keyOpts.buffer = event.buf

              -- Assign the keymap
              vim.keymap.set(keymap.mode or 'n', keymap.lhs, keymap.rhs, keyOpts)
            end
          end
        end,
      })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
