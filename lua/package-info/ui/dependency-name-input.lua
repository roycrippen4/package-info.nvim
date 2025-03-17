--- TODO: remote dependency on ui
local Input = require('nui.input')

local safe_call = require('package-info.utils.safe-call')

local M = {}

--- TODO: Fix types
---
--- Spawn a new input for the package name
---@param props.on_submit function - executed after selection
---@param props.on_close? function - executed if user closes the input
---@param props.on_error? function - executed if users enters an invalid dependency name
---@return nil
function M.new(props)
  local style = {
    relative = 'cursor',
    position = {
      row = 0,
      col = 0,
    },
    size = {
      width = 50,
      height = 2,
    },
    focusable = true,
    border = {
      style = 'rounded',
      text = {
        top = ' Enter Dependency Name ',
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }

  M.instance = Input(style, {
    prompt = '> ',
    on_submit = function(dependency_name)
      if dependency_name == '' then
        vim.notify('No dependency name specified', vim.log.levels.ERROR)

        safe_call(props.on_error)

        return
      end

      props.on_submit(dependency_name)
    end,
    on_close = function()
      safe_call(props.on_close)
    end,
  })
end

--- TODO: Fix types
---
---Opens the input
---@param props.on_success? function - executed after successful input open
---@param props.on_error? function - executed if input instance not properly spawned
---@return nil
function M.open(props)
  props = props or {}

  if M.instance == nil then
    vim.notify('Failed to open dependency name input. Not spawned properly', vim.log.levels.ERROR)

    safe_call(props.on_error)

    return
  end

  M.instance:mount()

  safe_call(props.on_success)
end

--- TODO: Fix types
---
--- Closes the input
---@param props.on_success? function - executed after successful input close
---@param props.on_error? function - executed if input instance not properly spawned or opened
---@return nil
function M.close(props)
  props = props or {}

  if M.instance == nil then
    vim.notify('Failed to close dependency name input. Not spawned properly', vim.log.levels.ERROR)

    safe_call(props.on_error)

    return
  end

  M.instance:unmount()

  safe_call(props.on_success)
end

return M
