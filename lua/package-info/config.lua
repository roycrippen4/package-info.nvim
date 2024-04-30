local constants = require('package-info.utils.constants')
local register_autocmd = require('package-info.utils.register-autocmd')
local state = require('package-info.state')
local job = require('package-info.utils.job')
local logger = require('package-info.utils.better_logger')

local default_config = {
  colors = {
    up_to_date = '#3C4048',
    outdated = '#d19a66',
  },
  icons = {
    enable = true,
    style = {
      up_to_date = '|  ',
      outdated = '|  ',
    },
  },
  autostart = true,
  package_manager = constants.PACKAGE_MANAGERS.npm,
  hide_up_to_date = false,
  hide_unstable_versions = false,
  debug = false,
}

local M = {}

-- Initialize default options
M.options = default_config

--- Register namespace for usage for virtual text
--- @return nil
M.__register_namespace = function()
  state.namespace.create()
end

-- Check which lock file exists and set package manager accordingly
--- @return nil
M.__register_package_manager = function()
  local yarn_lock = io.open('yarn.lock', 'r')

  if yarn_lock ~= nil then
    M.options.package_manager = constants.PACKAGE_MANAGERS.yarn

    job({
      command = 'yarn -v',
      on_success = function(full_version)
        local major_version = full_version:sub(1, 1)

        if major_version == '1' then
          state.has_old_yarn = true
        end
      end,
      on_error = function()
        logger:log('Error detecting yarn version. Falling back to yarn <2')
      end,
    })

    io.close(yarn_lock)
    state.is_in_project = true

    return
  end

  local package_lock = io.open('package-lock.json', 'r')

  if package_lock ~= nil then
    M.options.package_manager = constants.PACKAGE_MANAGERS.npm

    io.close(package_lock)
    state.is_in_project = true

    return
  end

  local pnpm_lock = io.open('pnpm-lock.yaml', 'r')

  if pnpm_lock ~= nil then
    M.options.package_manager = constants.PACKAGE_MANAGERS.pnpm

    io.close(pnpm_lock)
    state.is_in_project = true

    return
  end
end

--- Clone options and replace empty ones with default ones
-- @param user_options: M.__DEFAULT_OPTIONS - all the options user can provide in the plugin config
--- @return nil
M.__register_user_options = function(user_options)
  M.options = vim.tbl_deep_extend('keep', user_options or {}, M.__DEFAULT_OPTIONS)
end

--- Prepare a clean augroup for the plugin to use
--- @return nil
M.__prepare_augroup = function()
  vim.cmd('augroup ' .. constants.AUTOGROUP)
  vim.cmd('autocmd!')
  vim.cmd('augroup end')
end

--- Register autocommand for loading the plugin
--- @return nil
M.__register_start = function()
  register_autocmd('BufEnter', "lua require('package-info.core').load_plugin()")
end

--- Register autocommand for auto-starting plugin
--- @return nil
M.__register_autostart = function()
  if M.options.autostart then
    register_autocmd('BufEnter', "lua require('package-info').show()")
  end
end

--- Register all highlight groups
--- @return nil
M.__register_highlight_groups = function()
  local colors = {
    up_to_date = M.options.colors.up_to_date,
    outdated = M.options.colors.outdated,
  }

  -- 256 color support
  if not vim.o.termguicolors then
    colors = {
      up_to_date = constants.LEGACY_COLORS.up_to_date,
      outdated = constants.LEGACY_COLORS.outdated,
    }
  end

  vim.api.nvim_set_hl(0, constants.HIGHLIGHT_GROUPS.outdated, { fg = colors.outdated })
  vim.api.nvim_set_hl(0, constants.HIGHLIGHT_GROUPS.up_to_date, { fg = colors.up_to_date })
end

--- Register all plugin commands
--- @return nil
M.__register_commands = function()
  vim.cmd('command! ' .. constants.COMMANDS.show .. " lua require('package-info').show()")
  vim.cmd('command! ' .. constants.COMMANDS.show_force .. " lua require('package-info').show({ force = true })")
  vim.cmd('command! ' .. constants.COMMANDS.hide .. " lua require('package-info').hide()")
  vim.cmd('command! ' .. constants.COMMANDS.delete .. " lua require('package-info').delete()")
  vim.cmd('command! ' .. constants.COMMANDS.update .. " lua require('package-info').update()")
  vim.cmd('command! ' .. constants.COMMANDS.install .. " lua require('package-info').install()")
  vim.cmd('command! ' .. constants.COMMANDS.change_version .. " lua require('package-info').change_version()")
end

--- Take all user options and setup the config
-- @param user_options default M table - all options user can provide in the plugin config
--- @return nil
M.setup = function(user_options)
  M.__register_user_options(user_options)
  M.__register_highlight_groups()
  M.__register_package_manager()
  M.__register_namespace()
  M.__prepare_augroup()
  M.__register_start()
  M.__register_autostart()
  M.__register_commands()
end

return M
