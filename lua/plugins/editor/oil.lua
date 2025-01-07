return {
  'landaman/oil.nvim',
  cmd = { 'Oil' },
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
      '_',
      function()
        require('oil.actions').open_cwd.callback()
      end,
      desc = 'Open Oil in current working directory',
    },
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
            opts.refresh_git_status()
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
    local function new_git_status()
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
          local ret = {
            ignored = parse_output(ignore_proc),
            tracked = parse_output(tracked_proc),
            untracked = parse_output(untracked_proc),
            staged = parse_output(staged_proc),
            unstaged = parse_output(unstaged_proc),
          }

          rawset(self, key, ret)
          return ret
        end,
      })
    end
    local git_status = new_git_status()

    -- Clear git status cache on refresh
    local refresh = require('oil.actions').refresh
    local orig_refresh = refresh.callback
    refresh.callback = function(...)
      git_status = new_git_status()
      orig_refresh(...)
    end

    local detail = false

    --- Pre-processes a filter to contain the items in the form we can use to process patterns from
    ---@param filter {folders: table<string>, files: table<string>} the filter to turn into patterns
    ---@return table<string> resulting filters
    local function pre_process_filters(filter)
      -- Get folders and files
      local folders = vim.tbl_map(function(path)
        return path .. '/'
      end, filter.folders)
      local files = filter.files

      local joined = vim.list_extend(folders, files) -- Join the lists

      return vim.iter(joined):map(vim.g.os_encode_path_separators):totable() -- Encode the path separators
    end

    -- Pro-processed filters
    local hide_filters = pre_process_filters(vim.g.file_visibility.hide)
    local never_show_filters = pre_process_filters(vim.g.file_visibility.never_show)
    local always_show_filters = pre_process_filters(vim.g.file_visibility.always_show)

    --- Checks if a filter matches the provided file and name
    ---@param filter string the filter to check the file and name against
    ---@param path string the path to check
    ---@param name string the name of the file
    ---@return boolean whether the filter matches the specified file/path
    local function filter_matches_file_and_name(filter, path, name)
      local full_path = path .. name
      local stat = vim.uv.fs_stat(full_path)

      if stat.type == 'directory' then -- Should never be nil
        full_path = full_path .. require('oil.fs').sep -- Ensure we keep files and directories separate
      end

      return (full_path):match(filter)
    end

    --- Determines if any of the provided filters match the given file and name
    ---@param filters table<string> the filters to check
    ---@param path string the path of the file to check
    ---@param name string the name of the file to check
    ---@return boolean if any of the provided filters match the given file
    local function filters_match_file_and_name(filters, path, name)
      -- Return true if any filter matches
      return vim.iter(filters):any(function(filter)
        return filter_matches_file_and_name(filter, path, name)
      end)
    end

    local git_column = {
      render = function(entry, bufnr)
        local dir = require('oil').get_current_dir(bufnr)
        local entry_name = entry[2]

        -- If no dir, we can't do anything =( e.g., remote
        if dir == nil then
          return nil
        end

        if git_status[dir].ignored[entry_name] == true then
          return { ' ', 'OilHidden' } -- If it's not hidden and git says it is, it's been overridden so display the correct highlight
        end

        -- If the entire directory is untracked, this is untracked
        if git_status[dir].untracked['.'] == true then
          return { ' ', 'OilGitUntracked' }
        end

        -- Check untracked
        if git_status[dir].untracked[entry_name] then
          if git_status[dir].untracked[entry_name] == true then
            return { ' ', 'OilGitUntracked' }
          else
            -- This is when we are the parent of something untracked, in this case we
            -- are modified
            local type = git_status[dir].untracked[entry_name]
            assert(type == 'dir')
            return { '󰄱 ', 'OilGitModified' }
          end
        end

        local status = nil
        local staged = false
        if git_status[dir].unstaged[entry_name] then
          staged = false
          status = git_status[dir].unstaged[entry_name].status
        elseif git_status[dir].staged[entry_name] then
          staged = true
          status = git_status[dir].staged[entry_name].status
        end

        -- Show status for each folder
        if status ~= nil then
          if status == 'A' or status == 'C' or status == 'T' or (status == 'M' and not git_status[dir].tracked[entry_name]) then -- Add, create, typechange, last accounts for folder
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
      refresh_git_status = function()
        git_status = new_git_status()
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
            dir = '' -- Handle remote cases, etc
          end

          -- If this matches the always show filter, then don't hide it
          if filters_match_file_and_name(always_show_filters, dir, name) then
            return false
          end

          -- If the file is in the hide list, hide it
          if filters_match_file_and_name(hide_filters, dir, name) then
            return true
          end

          -- Otherwise, revert to git if present
          if dir ~= '' then
            if git_status[dir].ignored['.'] then -- If the directory is ignored, the file definitely is
              return true
            end

            return git_status[dir].ignored[name] == true
          end
          return false
        end,
        is_always_hidden = function(name, bufnr)
          local dir = require('oil').get_current_dir(bufnr)

          -- Don't show the parent directory setter
          if name == '..' then
            return true
          end

          -- -- If this matches the always show filter, then don't hide it
          if filters_match_file_and_name(always_show_filters, dir, name) then
            return false
          end

          -- If the file is in the hide list, hide it
          if filters_match_file_and_name(never_show_filters, dir, name) then
            return true
          end

          -- Otherwise, not always hidden
          return false
        end,
        highlight_filename = function(entry, is_hidden, _, _, bufnr)
          local dir = require('oil').get_current_dir(bufnr)

          -- If no dir, we can't do anything =( e.g., remote
          if dir == nil then
            return nil
          end

          if is_hidden or git_status[dir].ignored[entry.name] == true then
            return 'OilHidden' -- If it's not hidden and git says it is, it's been overridden so display the correct highlight
          end

          -- If the entire directory is untracked, this is untracked
          if git_status[dir].untracked['.'] == true then
            return 'OilGitUntracked'
          end

          -- Check untracked
          if git_status[dir].untracked[entry.name] then
            if git_status[dir].untracked[entry.name] == true then
              return 'OilGitUntracked'
            else
              -- This is when we are the parent of something untracked, in this case we
              -- are modified
              local type = git_status[dir].untracked[entry.name]
              assert(type == 'dir')
              return 'OilGitModified'
            end
          end

          local status = nil
          if git_status[dir].unstaged[entry.name] then
            status = git_status[dir].unstaged[entry.name].status
          elseif git_status[dir].staged[entry.name] then
            status = git_status[dir].staged[entry.name].status
          end

          -- Show status for each folder
          if status ~= nil then
            if status == 'A' or status == 'C' or status == 'T' or (status == 'M' and not git_status[dir].tracked[entry.name]) then -- Add, create, typechange, last accounts for folder
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
