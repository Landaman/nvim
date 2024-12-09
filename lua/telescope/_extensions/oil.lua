local find_dirs = require('telescope-oil').find_dirs
local settings = require 'telescope-oil.settings'

return require('telescope').register_extension {
  setup = function(ext_config)
    settings.set(ext_config)
  end,
  exports = {
    oil = function(opts)
      if opts == nil then
        opts = {}
      end

      find_dirs(vim.tbl_extend('force', settings.current, opts))
    end,
  },
}
