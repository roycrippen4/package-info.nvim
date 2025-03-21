---@class PackageInfo.State
local M = {
  ---If true, the plugin has detected JS/TS project
  is_in_project = false,
  ---If true the current buffer is package json, with content and correct format
  is_loaded = false,
  ---If true the virtual text versions are displayed in package.json
  is_virtual_text_displayed = false,
  ---If true the project is using yarn 2<
  has_old_yarn = false,
}

---@class PackageInfo.OutdatedDependency
---@field current string - current dependency version
---@field latest string - latest dependency version

---@class PackageInfo.InstalledDependency
---@field current string - current dependency version

---@class PackageInfo.Dependencies
M.dependencies = {
  ---Outdated dependencies from `npm outdated --json` as a list of
  ---@type table<string, PackageInfo.OutdatedDependency>
  outdated = {},

  ---Installed dependencies from package.json as a list of
  ---@type table<string, PackageInfo.InstalledDependency>
  installed = {},
}

M.buffer = {
  id = nil,

  ---String value of buffer from vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
  lines = {},

  ---Set the buffer id to current buffer id
  ---@return nil
  save = function()
    M.buffer.id = vim.fn.bufnr()
  end,
}

M.last_run = {
  time = nil,

  ---Update M.last_run.time to now in milliseconds
  ---@return nil
  update = function()
    M.last_run.time = os.time()
  end,

  ---Determine if the next run should be skipped
  ---Skip if there was a run within the past hour
  ---@return boolean
  should_skip = function()
    if M.last_run.time == nil then
      return false
    end

    return os.time() < M.last_run.time + 3600
  end,
}

M.namespace = {
  id = nil,

  ---Creates plugin specific namespace
  ---@return nil
  create = function()
    M.namespace.id = vim.api.nvim_create_namespace('package-info')
  end,
}

return M
