local get_dirs = require('telescope-oil.utils').get_dirs
local M = {}

function M.find_dirs(opts)
  get_dirs(opts, require('oil').open)
end

return M
