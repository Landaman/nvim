--- Base handler for setting up an LSP based on parameters from either Mason or base exec
---@param server_name string the name of the server to setup
---@param handlers table<string, function | table> handlers to setup with
function base_handler(server_name, handlers)
  -- Do nothing if no handler
  if handlers[server_name] == nil then
    return
    -- Use handler in opts if we have it
  elseif type(handlers[server_name]) == 'function' then
    -- Try to see if this is just setup before the handler
    local result = handlers[server_name]()
    if not result then
      return -- If nothing, we can assume this is done
    end
  end

  -- If we got a result or we have a base handler then try setup
  if result or handlers[server_name] ~= nil then
    local server = result or handlers[server_name]

    -- Extend capabilities with blink
    server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)
    require('lspconfig')[server_name].setup(server)
  end
end

return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    opts = {
      handlers = {}, -- Setup handlers
    },
    dependencies = {
      'saghen/blink.cmp',
      {
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
          'saghen/blink.cmp',
          'williamboman/mason.nvim',
        },
        opts = {}, -- This will be populated by handlers and ensure_installed in submodules
        config = function(_, opts)
          require('mason-lspconfig').setup(vim.tbl_deep_extend('force', opts, {
            handlers = {
              function(server_name)
                base_handler(server_name, opts.handlers)
              end,
            },
          }))
        end,
      },

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      'ibhagwan/fzf-lua',
    },
    config = function(_, opts)
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('fzf-lua').lsp_definitions, 'Goto definition')

          -- Find referencss for the word under your cursor.
          map('gr', require('fzf-lua').lsp_references, 'Goto references')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('fzf-lua').lsp_implementations, 'Goto implementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('gy', require('fzf-lua').lsp_typedefs, 'Type definition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('fzf-lua').lsp_document_symbols, 'Document symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('fzf-lua').lsp_workspace_symbols, 'Workspace symbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, 'Rename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, 'Goto declaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay hints')
          end

          -- Enable jumping by hover reference
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            map(']]', function()
              Snacks.words.jump(vim.v.count1)
            end, 'Next reference', { 'n', 't' })
            map('[[', function()
              Snacks.words.jump(-vim.v.count1)
            end, 'Previous reference', { 'n', 't' })
          end
        end,
      })

      -- Now load fallback plugins
      local handlers = vim.tbl_extend(
        'force',
        require('lazy.core.plugin').values(require('lazy.core.config').plugins['mason-lspconfig.nvim'], 'opts', false).handlers,
        opts.handlers
      ) -- Merge handlers between mason and raw

      -- Now setup each LSP that we deem should be setup this way
      for _, lsp in ipairs(opts.setup_with_executable) do
        -- If it's already setup with Mason, no need
        if not require('mason-registry').is_installed(require('mason-lspconfig').get_mappings().lspconfig_to_mason[lsp]) then
          if vim.fn.executable(lsp) == 1 then
            base_handler(lsp, handlers)
          else
            vim.notify('lspconfig: Failed to find executable for LSP ' .. lsp, vim.log.levels.WARN)
          end
        end
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
