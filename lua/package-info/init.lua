-- TODO: check if there is a text changes event, if so, redraw the dependencies in the buffer, TextChanged autocmd

local M = {}

function M.setup(options)
  require('package-info.config').setup(options)
end

function M.show(options)
  require('package-info.actions.show').run(options)
end

function M.hide()
  require('package-info.actions.hide').run()
end

function M.toggle(options)
  if require('package-info.state').is_virtual_text_displayed then
    M.hide()
  else
    M.show(options)
  end
end

function M.delete()
  require('package-info.actions.delete').run()
end

function M.update()
  require('package-info.actions.update').run()
end

function M.install()
  require('package-info.actions.install').run()
end

function M.change_version()
  require('package-info.actions.change-version').run()
end

function M.get_status()
  return require('package-info.ui.generic.loading-status').get()
end

return M
