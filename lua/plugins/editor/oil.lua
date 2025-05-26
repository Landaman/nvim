return {
  'stevearc/oil.nvim',
  cmd = { 'Oil' },
  cond = not vim.g.vscode,
  init = function()
    local f = vim.fn.expand '%:p'
    if vim.fn.isdirectory(f) ~= 0 then
      require 'oil' -- Disable lazy loading if we are loading straight into a directory
      return -- No need for autocmd if we already loaded Oil
    end

    local augroup = vim.api.nvim_create_augroup('Oil_lazy_hijack_netrw', { clear = true })
    vim.api.nvim_create_autocmd('BufEnter', {
      group = augroup,
      desc = 'Start Oil when a directory is loaded',
      callback = function()
        local event_f = vim.fn.expand '%:p'
        if vim.fn.isdirectory(event_f) ~= 0 then
          require 'oil' -- Disable lazy loading if we are opening a directory and we haven't yet done oil
          vim.api.nvim_del_augroup_by_id(augroup) -- No more need for this augroup if we've loaded
        end
      end,
    })
  end,
  keys = {
    {
      '\\',
      function()
        -- Do nothing if we already have a dir open
        if require('oil').get_current_dir() ~= nil then
          return
        end

        require('oil').open()
      end,
      desc = 'Open oil in current files directory',
    },
  },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function(_, opts)
    local oil_git_augroup = vim.api.nvim_create_augroup('oil-git', { clear = true })
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      group = oil_git_augroup,
      pattern = { 'oil' },
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        -- Manually trigger refresh on buffer write to update git status
        vim.api.nvim_create_autocmd('BufWritePost', {
          callback = function()
            opts.refresh_filesystem_status()
            if buffer == vim.api.nvim_get_current_buf() then
              -- This will be handled for us internally, since we modified this buffer
              return
            end

            -- Schedule an update
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(buffer) then
                return -- Double check buffer exists
              end
              -- Double check we're not already mutating
              local mutator = require 'oil.mutator'
              if vim.bo[buffer].modified or vim.b[buffer].oil_dirty or mutator.is_mutating() then
                return
              end

              -- If the buffer is currently visible, rerender
              for _, winid in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == buffer then
                  require('oil.view').render_buffer_async(buffer)
                  return
                end
              end

              -- If it is not currently visible, mark it as dirty
              vim.b[buffer].oil_dirty = {}
            end)
          end,
        })
      end,
    })

    require('oil').setup(opts)

    require('oil.columns').register('git', opts.git_column)
  end,
  opts = function()
    -- Create HL groups for Oil Git
    vim.api.nvim_set_hl(0, 'OilGitUntracked', {
      fg = '#bb9af7',
    })
    vim.api.nvim_set_hl(0, 'OilGitConflict', {
      fg = '#ff8700',
      bold = true,
      italic = true,
    })
    vim.api.nvim_set_hl(0, 'OilGitUnstaged', {
      link = 'OilGitConflict',
    })
    vim.api.nvim_set_hl(0, 'OilGitModified', {
      fg = '#ff9e64',
    })
    vim.api.nvim_set_hl(0, 'OilGitRenamed', {
      link = 'OilGitModified',
    })
    vim.api.nvim_set_hl(0, 'OilGitStaged', {
      fg = '#73daca',
    })
    vim.api.nvim_set_hl(0, 'OilGitAdded', {
      link = 'GitSignsAdd',
    })

    -- helper function to parse output
    local function parse_output(proc)
      local result = proc:wait()
      local ret = {}
      if result.code == 0 then
        for line in vim.gsplit(result.stdout, '\n', { plain = true, trimempty = true }) do
          -- Remove trailing slash
          line = line:gsub('/$', '')

          -- Determine how many parts we have
          local line_split = vim.split(line, '\t')
          if #line_split == 1 then
            ret[line] = true -- If we only have one part, it's just the file name, just process that

            -- If this is a sub-item, the parent should be marked as modified
            local item_split = vim.split(line, '/') -- Split to the most basic path part, because sometimes diffs have multiple layers. Git always uses '/' so respect that
            if #item_split > 1 then
              ret[item_split[1]] = 'dir'
            end
          else
            local status = line_split[1]:sub(1, 1) -- Status. Trim out percentages, etc, we only want the first character
            local item = #line_split == 2 and line_split[2] or line_split[3] -- The file. For M, etc the 2nd one is the real path so respect that

            local item_split = vim.split(item, '/') -- Split to the most basic path part, because sometimes diffs have multiple layers. Git always uses '/' so respect that

            if #item_split == 1 then -- This means the raw directory/file itself has changed, so keep status
              ret[item_split[1]] = { -- This just removes the /, if there is one
                status = status,
              }
            else -- Change status to M, because something in the folder was changed not the folder itself
              ret[item_split[1]] = { status = 'M' }
            end
          end
        end
      end
      return ret
    end

    -- build git status cache
    local function new_filesystem_status()
      return setmetatable({}, {
        __index = function(self, key)
          local ignore_proc = vim.system({ 'git', 'ls-files', '--ignored', '--exclude-standard', '--others', '--directory' }, {
            cwd = key,
            text = true,
          })
          local tracked_proc = vim.system({ 'git', 'ls-tree', 'HEAD', '--name-only' }, {
            cwd = key,
            text = true,
          })
          local untracked_proc = vim.system({ 'git', 'ls-files', '--others', '--exclude-standard', '--directory', '--no-empty-directory' }, {
            cwd = key,
            text = true,
          })
          local staged_proc = vim.system({ 'git', 'diff', '--staged', '--name-status', '--relative' }, {
            cwd = key,
            text = true,
          })
          local unstaged_proc = vim.system({ 'git', 'diff', '--name-status', '--relative' }, {
            cwd = key,
            text = true,
          })
          local fd_unrestricted_proc = vim.system({ 'fd', '-uuu', '--exclude=.git/', '--exclude=.DS_Store' }, { cwd = key, text = true })
          local fd_proc = vim.system({ 'fd', '--hidden', '--exclude=.git/', '--exclude=.DS_Store' }, { cwd = key, text = true })

          local ret = {
            ignored = parse_output(ignore_proc),
            tracked = parse_output(tracked_proc),
            untracked = parse_output(untracked_proc),
            staged = parse_output(staged_proc),
            unstaged = parse_output(unstaged_proc),
            fd_unrestricted = parse_output(fd_unrestricted_proc),
            fd = parse_output(fd_proc),
          }

          rawset(self, key, ret)
          return ret
        end,
      })
    end
    local filesystem_status = new_filesystem_status()

    -- Clear git status cache on refresh
    local refresh = require('oil.actions').refresh
    local orig_refresh = refresh.callback
    refresh.callback = function(...)
      filesystem_status = new_filesystem_status()
      orig_refresh(...)
    end

    local detail = false -- This is the variable used to determine the status of the detail column

    local git_column = {
      render = function(entry, _, bufnr)
        local dir = require('oil').get_current_dir(bufnr)
        local entry_name = entry[2]

        -- If no dir, we can't do anything =( e.g., remote
        if dir == nil then
          return nil
        end

        if filesystem_status[dir].ignored[entry_name] == true then
          return { ' ', 'OilHidden' } -- If it's not hidden and git says it is, it's been overridden so display the correct highlight
        end

        -- If the entire directory is untracked, this is untracked
        if filesystem_status[dir].untracked['.'] == true then
          return { ' ', 'OilGitUntracked' }
        end

        -- Check untracked
        if filesystem_status[dir].untracked[entry_name] then
          if filesystem_status[dir].untracked[entry_name] == true then
            return { ' ', 'OilGitUntracked' }
          else
            -- This is when we are the parent of something untracked, in this case we
            -- are modified
            local type = filesystem_status[dir].untracked[entry_name]
            assert(type == 'dir')
            return { '󰄱 ', 'OilGitModified' }
          end
        end

        local status = nil
        local staged = false
        if filesystem_status[dir].unstaged[entry_name] then
          staged = false
          status = filesystem_status[dir].unstaged[entry_name].status
        elseif filesystem_status[dir].staged[entry_name] then
          staged = true
          status = filesystem_status[dir].staged[entry_name].status
        end

        -- Show status for each folder
        if status ~= nil then
          if status == 'A' or status == 'C' or status == 'T' or (status == 'M' and not filesystem_status[dir].tracked[entry_name]) then -- Add, create, typechange, last accounts for folder
            return { ' ', 'OilGitAdded' }
          end

          if status == 'M' then
            return staged and { ' ', 'OilGitStaged' } or { '󰄱 ', 'OilGitModified' }
          end

          if status == 'R' then
            return staged and { ' ', 'OilGitStaged' } or { '󰄱 ', 'OilGitRenamed' }
          end

          if status == 'U' then
            return { ' ', 'OilGitConflict' }
          end

          assert(false) -- Assert we understand status
        end

        return nil
      end,
      parse = function(line)
        return line:match '^(.*)%s+(.*)$'
      end,
    }

    return {
      refresh_filesystem_status = function()
        filesystem_status = new_filesystem_status()
      end,
      git_column = git_column,
      watch_for_changes = true,
      default_file_explorer = true,
      columns = {
        'icon',
        'git',
      },
      constrain_cursor = 'name', -- Do not allow editing details when those are shown
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, bufnr)
          local dir = require('oil').get_current_dir(bufnr)
          if not dir then
            return false -- Handle remote, etc. We just have to allow the file to be visible in that case
          end

          -- We can delegate this entirely to FD. This will handle the three possibilities:
          -- 1. File is unignored by fd (will exist in the list, so will not hide)
          -- 2. File is ignored by fd (will not exist in the list, so will hide)
          -- 3. File is untouched by fd (will be handled by git, which fd does for us)
          return not filesystem_status[dir].fd[name]
        end,
        is_always_hidden = function(name, bufnr)
          local dir = require('oil').get_current_dir(bufnr)

          -- Don't show the parent directory setter
          if name == '..' then
            return true
          end

          -- If we don't have a dir, just assume the file isn't hidden. Nothing to be done in that case
          if not dir then
            return false
          end

          -- The only reason the file wouldn't be in the fd -uuu list is if it's been set to always-ignore by the FD config. In that case, we should definitely hide it
          return not filesystem_status[dir].fd_unrestricted[name]
        end,
        highlight_filename = function(entry, is_hidden, _, _, bufnr)
          local dir = require('oil').get_current_dir(bufnr)

          -- If no dir, we can't do anything =( e.g., remote
          if dir == nil then
            return nil
          end

          if is_hidden or filesystem_status[dir].ignored[entry.name] == true then
            return 'OilHidden' -- If it's not hidden and git says it is, it's been overridden so display the correct highlight
          end

          -- If the entire directory is untracked, this is untracked
          if filesystem_status[dir].untracked['.'] == true then
            return 'OilGitUntracked'
          end

          -- Check untracked
          if filesystem_status[dir].untracked[entry.name] then
            if filesystem_status[dir].untracked[entry.name] == true then
              return 'OilGitUntracked'
            else
              -- This is when we are the parent of something untracked, in this case we
              -- are modified
              local type = filesystem_status[dir].untracked[entry.name]
              assert(type == 'dir')
              return 'OilGitModified'
            end
          end

          local status = nil
          if filesystem_status[dir].unstaged[entry.name] then
            status = filesystem_status[dir].unstaged[entry.name].status
          elseif filesystem_status[dir].staged[entry.name] then
            status = filesystem_status[dir].staged[entry.name].status
          end

          -- Show status for each folder
          if status ~= nil then
            if status == 'A' or status == 'C' or status == 'T' or (status == 'M' and not filesystem_status[dir].tracked[entry.name]) then -- Add, create, typechange, last accounts for folder
              return 'OilGitAdded'
            end

            if status == 'M' then
              return 'OilGitModified'
            end

            if status == 'R' then
              return 'OilGitRenamed'
            end

            if status == 'U' then
              return 'OilGitConflict'
            end

            assert(false) -- Assert we understand status
          end

          return nil -- Use default
        end,
      },
      keymaps = {
        ['gd'] = {
          desc = 'Toggle file detail view',
          callback = function()
            detail = not detail
            if detail then
              require('oil').set_columns {
                'icon',
                { 'permissions', highlight = 'OilHidden' },
                { 'size', highlight = 'OilHidden' },
                {
                  'mtime',
                  highlight = 'OilHidden',
                },
                'git',
              }
            else
              require('oil').set_columns { 'icon', 'git' }
            end
          end,
        },
      },
    }
  end,
}
