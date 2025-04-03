return {
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    cond = not vim.g.vscode,
    dependencies = {
      'saghen/blink.cmp',
      {
        -- DON'T install via mason-lspconfig because we don't want that to set this up
        'williamboman/mason.nvim',
        opts = {
          ensure_installed = {
            'jdtls',
            'java-debug-adapter',
          },
        },
      },
    },
    opts = function()
      local mason_registry = require 'mason-registry'
      local lombok_jar = mason_registry.get_package('jdtls'):get_install_path() .. '/lombok.jar'
      return {
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = require('lspconfig.configs.jdtls').default_config.root_dir,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,

        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/config'
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/workspace'
        end,

        -- How to run jdtls. This can be overridden to a full java command-line
        -- if the Python wrapper script doesn't suffice.
        cmd = {
          vim.fn.exepath 'jdtls',
          string.format('--jvm-arg=-javaagent:%s', lombok_jar),
        },
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(cmd, {
              '-configuration',
              opts.jdtls_config_dir(project_name),
              '-data',
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return cmd
        end,
        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = 'auto', config_overrides = {} },
        dap_main = {},
        test = true,
        settings = {
          java = {
            inlayHints = {
              parameterNames = {
                enabled = 'all',
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      -- Setup debug and tester
      local mason_registry = require 'mason-registry'
      local bundles = {} ---@type string[]

      local java_dbg_pkg = mason_registry.get_package 'java-debug-adapter'
      local java_dbg_path = java_dbg_pkg:get_install_path()
      local jar_patterns = {
        java_dbg_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar',
      }

      local java_test_pkg = mason_registry.get_package 'java-test'
      local java_test_path = java_test_pkg:get_install_path()
      vim.list_extend(jar_patterns, {
        java_test_path .. '/extension/server/*.jar',
      })
      for _, jar_pattern in ipairs(jar_patterns) do
        for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), '\n')) do
          table.insert(bundles, bundle)
        end
      end

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        -- Existing server will be reused if the root_dir matches.
        require('jdtls').start_or_attach {
          root_dir = opts.root_dir(fname),
          cmd = opts.full_cmd(opts),
          settings = opts.settings,
          capabilities = require('blink.cmp').get_lsp_capabilities(),
          init_options = {
            bundles = bundles,
          },
        }
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = attach_jdtls,
      })

      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      attach_jdtls()
    end,
  },
  {
    'mfussenegger/nvim-dap',
    opts = {
      handlers = {
        java = function(config)
          require('lazy').load { plugins = { 'nvim-jdtls' } } -- Ensure that F5 on startup always works for Java launch configs
          return config
        end,
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'java',
      },
    },
  },
}
