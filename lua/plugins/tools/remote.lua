return {
  'amitds1997/remote-nvim.nvim',
  cmd = { 'RemoteStart', 'RemoteStop', 'RemoteInfo', 'RemoteCleanup', 'RemoteConfigDel', 'RemoteLog' },
  dependencies = {
    'nvim-lua/plenary.nvim', -- For standard functions
    'MunifTanjim/nui.nvim', -- To build the plugin UI
    'nvim-telescope/telescope.nvim', -- For picking b/w different remote methods
  },
  opts = {},
}
