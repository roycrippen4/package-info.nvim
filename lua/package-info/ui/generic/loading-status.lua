local constants = require('package-info.utils.constants')

local frame = {
  '⠋',
  '⠙',
  '⠹',
  '⠸',
  '⠼',
  '⠴',
  '⠦',
  '⠧',
  '⠇',
  '⠏',
}

local M = {
  queue = {},
  state = {
    current_spinner = '',
    index = 1,
    is_running = false,
  },
}

local function redraw()
  vim.cmd('redrawstatus')
end

--- Spawn a new loading instance
--- @param message string - message to display in the loading status
--- @return number - id of the created instance
M.new = function(message)
  local instance = {
    id = math.random(),
    message = message,
    is_ready = false,
  }

  table.insert(M.queue, instance)

  return instance.id
end

--- Start the instance by given id by marking it as ready to run
--- @param id number - id of the instance to start
--- @return nil
M.start = function(id)
  for _, instance in ipairs(M.queue) do
    if instance.id == id then
      instance.is_ready = true
    end
  end
end

--- Stop the instance by given id by removing it from the list
--- @param id number - id of the instance to stop and remove
--- @return nil
M.stop = function(id)
  local filtered_list = {}
  M.timer:stop()

  for _, instance in ipairs(M.queue) do
    if instance.id ~= id then
      table.insert(filtered_list, instance)
    end
  end

  M.queue = filtered_list
end

--- Update the spinner instance recursively
--- @return nil
M.update_spinner = function()
  M.state.current_spinner = frame[M.state.index]
  M.state.index = M.state.index + 1

  if M.state.index == 10 then
    M.state.index = 1
  end
  vim.schedule(redraw)
end

--- Get the first ready instance message if there are instances
--- @return string
M.get = function()
  local active_instance = nil

  for _, instance in pairs(M.queue) do
    if not active_instance and instance.is_ready then
      active_instance = instance
    end
  end

  if not active_instance then
    M.state.is_running = false
    M.state.current_spinner = ''
    M.state.index = 1

    return ''
  end

  if active_instance and not M.state.is_running then
    M.state.is_running = true

    if M.timer == nil then
      M.timer = vim.uv.new_timer()
    end

    M.timer:start(100, 100, M.update_spinner)
  end

  local spinner = '%#' .. constants.HIGHLIGHT_GROUPS.statusline_spinner .. '#' .. M.state.current_spinner .. '%*'
  local text = 'package-info: ' .. '%#' .. constants.HIGHLIGHT_GROUPS.statusline_text .. '#' .. active_instance.message

  return text .. ' ' .. spinner
end

return M
