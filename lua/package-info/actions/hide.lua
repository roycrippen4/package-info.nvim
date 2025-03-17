local state = require('package-info.state')
local virtual_text = require('package-info.virtual_text')

local M = {}

---Runs the hide virtual text action
---@return nil
function M.run()
  if not state.is_loaded then
    vim.notify('Not in valid package.json file', vim.log.levels.WARN)
    return
  end

  virtual_text.clear()
end

return M
