--- TODO: remove nui
local Menu = require('nui.menu')

local CONSTANTS = require('package-info.utils.constants')

local safe_call = require('package-info.utils.safe-call')

local ACTIONS = {
  PRODUCTION = {
    text = 'Production',
    id = CONSTANTS.DEPENDENCY_TYPE.production,
  },
  DEVELOPMENT = {
    text = 'Development',
    id = CONSTANTS.DEPENDENCY_TYPE.development,
  },
  CANCEL = {
    text = 'Cancel',
    id = 3,
  },
}

local M = {}

---TODO : see if the style config for components can be shared
---       Fix types
---
---Spawn a new dependency type select prompt
---@param props.on_submit function - executed after selection
---@param props.on_cancel? function - executed if user selects ACTIONS.cancel
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
      height = 3,
    },
    focusable = true,
    border = {
      style = 'rounded',
      text = {
        top = ' Select Dependency Type ',
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }

  M.instance = Menu(style, {
    lines = {
      Menu.item(ACTIONS.PRODUCTION),
      Menu.item(ACTIONS.DEVELOPMENT),
      Menu.item(ACTIONS.CANCEL),
    },
    keymap = {
      focus_next = { 'j', '<Down>', '<Tab>' },
      focus_prev = { 'k', '<Up>', '<S-Tab>' },
      close = { '<Esc>', '<C-c>', 'q' },
      submit = { '<CR>', '<Space>' },
    },
    on_submit = function(answer)
      if answer.id == ACTIONS.DEVELOPMENT.id or answer.id == ACTIONS.PRODUCTION.id then
        props.on_submit(answer.id)
      end
    end,
    on_close = function()
      safe_call(props.on_cancel)
    end,
  })
end

--- TODO: Fix types
---
---Opens the prompt
---@param props.on_success? function - executed after successful prompt open
---@param props.on_error? function - executed if prompt instance not properly spawned
---@return nil
function M.open(props)
  props = props or {}

  if M.instance == nil then
    vim.notify('Failed to open dependency type select prompt. Not spawned properly', vim.log.levels.ERROR)

    safe_call(props.on_error)

    return
  end

  M.instance:mount()

  safe_call(props.on_success)
end

--- TODO: Fix types
---
--- Closes the prompt
---@param props.on_success? function - executed after successful prompt close
---@param props.on_error? function - executed if prompt instance not properly spawned or opened
---@return nil
function M.close(props)
  props = props or {}

  if M.instance == nil then
    vim.notify('Failed to close dependency type select prompt. Not spawned properly', vim.log.levels.ERROR)

    safe_call(props.on_error)

    return
  end

  M.instance:unmount()

  safe_call(props.on_success)
end

return M
