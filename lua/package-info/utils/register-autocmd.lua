local autocmd = vim.api.nvim_create_autocmd
local constants = require('package-info.utils.constants')

--- Register given command when the event fires
--- @param event string - event that will trigger the autocommand
--- @param command function - command to fire when the event is triggered
return function(event, command)
  autocmd(event, {
    group = constants.AUGROUP,
    pattern = 'package.json',
    callback = function()
      command()
    end,
  })
  -- vim.cmd('autocmd ' .. constants.AUGROUP .. ' ' .. event .. ' package.json ' .. command)
end
