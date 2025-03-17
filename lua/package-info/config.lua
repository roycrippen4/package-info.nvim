local autocmd = vim.api.nvim_create_autocmd
local constants = require('package-info.utils.constants')
local job = require('package-info.utils.job')
local state = require('package-info.state')

local default_config = {
  colors = {
    up_to_date = '#3C4048',
    outdated = '#d19a66',
    statusline_text = '#00fff2',
    statusline_spinner = '#00fff2',
    statusline_bg = vim.fn.synIDattr(vim.fn.hlID('Statusline'), 'bg'),
  },
  icons = {
    enable = true,
    style = {
      up_to_date = '  ',
      outdated = '  ',
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

---Register namespace for usage for virtual text
---@return nil
local function register_namespace()
  state.namespace.create()
end

---Check which lock file exists and set package manager accordingly
---@return nil
local function register_package_manager()
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
        vim.notify('Error detecting yarn version. Falling back to yarn <2', vim.log.levels.WARN)
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

  local bun_lock = io.open('bun.lockb', 'r')

  if bun_lock ~= nil then
    M.options.package_manager = constants.PACKAGE_MANAGERS.bun

    io.close(bun_lock)
    state.is_in_project = true

    return
  end
end

---Prepare a clean augroup for the plugin to use
---@return nil
local function prepare_augroup()
  vim.api.nvim_create_augroup(constants.AUGROUP, { clear = true })
end

---Register autocommand for loading the plugin
---@return nil
local function register_start()
  autocmd('BufEnter', {
    group = constants.AUGROUP,
    pattern = 'package.json',
    callback = require('package-info.core').load_plugin,
  })

  autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = constants.AUGROUP,
    pattern = 'package.json',
    callback = function()
      vim.notify('reload')
      if require('package-info.core').is_valid_package_json() then
        require('package-info.virtual_text').clear()
        require('package-info.actions.show').run(M.options)
      end
    end,
  })
end

---Register autocommand for auto-starting plugin
---@return nil
local function register_autostart()
  if M.options.autostart then
    autocmd('BufEnter', {
      group = constants.AUGROUP,
      pattern = 'package.json',
      callback = require('package-info').show,
    })
  end
end

---Register all highlight groups
---@return nil
local function register_highlight_groups()
  local colors = {
    up_to_date = M.options.colors.up_to_date,
    outdated = M.options.colors.outdated,
    statusline_text = M.options.colors.statusline_text,
    statusline_spinner = M.options.colors.statusline_spinner,
    statusline_bg = M.options.colors.statusline_bg,
  }

  vim.api.nvim_set_hl(0, constants.HIGHLIGHT_GROUPS.outdated, { fg = colors.outdated })
  vim.api.nvim_set_hl(0, constants.HIGHLIGHT_GROUPS.up_to_date, { fg = colors.up_to_date })
  vim.api.nvim_set_hl(0, constants.HIGHLIGHT_GROUPS.statusline_text, { fg = colors.statusline_text, bg = colors.statusline_bg })
  vim.api.nvim_set_hl(0, constants.HIGHLIGHT_GROUPS.statusline_spinner, { fg = colors.statusline_spinner, bg = colors.statusline_bg })
end

---Register all plugin commands
---@return nil
local function register_commands()
  vim.cmd('command! ' .. constants.COMMANDS.show .. " lua require('package-info').show()")
  vim.cmd('command! ' .. constants.COMMANDS.show_force .. " lua require('package-info').show({ force = true })")
  vim.cmd('command! ' .. constants.COMMANDS.hide .. " lua require('package-info').hide()")
  vim.cmd('command! ' .. constants.COMMANDS.delete .. " lua require('package-info').delete()")
  vim.cmd('command! ' .. constants.COMMANDS.update .. " lua require('package-info').update()")
  vim.cmd('command! ' .. constants.COMMANDS.install .. " lua require('package-info').install()")
  vim.cmd('command! ' .. constants.COMMANDS.change_version .. " lua require('package-info').change_version()")
end

--- TODO: Fix types
---
---Take all user options and setup the config
---@param user_options default M table - all options user can provide in the plugin config
---@return nil
function M.setup(user_options)
  M.options = vim.tbl_deep_extend('force', default_config, user_options or {})
  register_highlight_groups()
  register_package_manager()
  register_namespace()
  prepare_augroup()
  register_start()
  register_autostart()
  register_commands()
end

return M
