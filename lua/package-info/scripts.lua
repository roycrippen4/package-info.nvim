local core = require('package-info.core')
local ns = vim.api.nvim_create_namespace('package_json_runner')

local M = {}

---@class PackageInfo.Config.Scripts
M.defaults = {
  --- Whether to show virtual text or not. Default = true.
  enabled = true,
  --- The highlight group to use for the virtual text. Default = 'PackageInfoRunScript'.
  hl_group = 'PackageInfoRunScript',
  --- The text to render. Default = '  '.
  text = '  ',
}

---@param lines string[]
---@return integer, integer
local function find_script_range(lines)
  local start_line = 0
  local end_line = 0

  for i, line in ipairs(lines) do
    if line:find('scripts') then
      start_line = i
      break
    end
  end

  for i = start_line + 1, #lines do
    if lines[i]:find('}') then
      end_line = i
      break
    end
  end

  return start_line, end_line
end

---@param scripts { line: integer, script_key: string }[]
---@return string?
local function match_script(scripts)
  local cursor = vim.fn.line('.')

  for _, script in ipairs(scripts) do
    if cursor == script.line then
      return script.script_key
    end
  end
end

---@param scripts { line: integer, script_key: string }[]
---@return boolean
local function cursor_on_script(scripts)
  local cursor = vim.fn.line('.')

  for _, script in ipairs(scripts) do
    if cursor == script.line then
      return true
    end
  end

  return false
end

---@param scripts { line: integer, script_key: string }[]
local function can_run_script(scripts)
  if not core.is_valid_package_json() then
    return false
  end

  if not cursor_on_script(scripts) then
    vim.notify('Cursor not on a script', vim.log.levels.ERROR)
    return false
  end

  return true
end

---@return { line: integer, script_key: string }[]
local function get_script_table()
  local scripts = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) ---@type string[]
  local start_line, end_line = find_script_range(lines)

  if start_line == 0 or end_line == 0 then
    return {}
  end

  for i = start_line + 1, end_line do
    local script_key = lines[i]:match('"[%s]*(.-)[%s]*":')
    if script_key then
      script_key = script_key:gsub('%-', '%%-')
      table.insert(scripts, { line = i, script_key = script_key })
    end
  end

  return scripts
end

---@param opts PackageInfo.Config.Scripts
---Updates the virtual text in the package.json
local function update_virtual_text(opts)
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  if not core.is_valid_package_json() then
    return
  end

  if not opts.enabled then
    vim.notify('return true')
    return true
  end

  vim.iter(get_script_table()):each(function(script)
    vim.api.nvim_buf_set_extmark(0, ns, script.line - 1, 0, {
      virt_text = { { opts.text, opts.hl_group } },
      hl_mode = 'combine',
      virt_text_win_col = 1,
    })
  end)
end

---@param opts PackageInfo.Config.Scripts
local function set_autocmd(opts)
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI' }, {
    group = vim.api.nvim_create_augroup('PackageJsonRunner', { clear = true }),
    pattern = 'package.json',
    callback = function()
      return update_virtual_text(opts)
    end,
  })
end

---@param opts PackageInfo.Config.Scripts
function M.disable_virtual_text(opts)
  opts.enabled = false
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

---@param opts PackageInfo.Config.Scripts
function M.enable_virtual_text(opts)
  opts.enabled = true
  update_virtual_text(opts)
  set_autocmd(opts)
end

---Sets up autocmds for handling virtual text inside the package.json
---@param opts? PackageInfo.Config.Scripts
function M.setup(opts)
  opts = vim.tbl_deep_extend('force', M.defaults, opts or {})
  vim.api.nvim_set_hl(0, 'PackageInfoRunScript', { fg = '#08F000' })

  if opts.enabled then
    set_autocmd(opts)
  end

  vim.api.nvim_create_user_command('PackageInfoToggleScriptVirtualText', function()
    M.toggle_virtual_text(opts)
  end, { desc = "Toggles the script runner's virtual text" })

  vim.api.nvim_create_user_command('PackageInfoDisableScriptVirtualText', function()
    M.disable_virtual_text(opts)
  end, { desc = "Disables the script runner's virtual text" })

  vim.api.nvim_create_user_command('PackageInfoEnableScriptVirtualText', function()
    M.enable_virtual_text(opts)
  end, { desc = "Enables the script runner's virtual text" })

  vim.api.nvim_create_user_command('PackageInfoRunScript', M.run, { desc = 'Runs the script under the cursor' })
end

---@param opts PackageInfo.Config.Scripts
---Toggles the virtual text for the script runner
function M.toggle_virtual_text(opts)
  if opts.enabled then
    M.disable_virtual_text(opts)
  else
    M.enable_virtual_text(opts)
  end
end

---Runs the script under the cursor
function M.run()
  local scripts = get_script_table()

  if not can_run_script(scripts) then
    return
  end

  local runner = (vim.fn.filereadable('bun.lockb') == 1 and 'bun run ') or 'npm run '
  local matched = match_script(scripts)

  if not matched then
    return
  end

  vim.cmd.TermExec('cmd="' .. runner .. matched .. '"')
end

return M
