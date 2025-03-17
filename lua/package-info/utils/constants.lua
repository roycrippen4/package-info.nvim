local M = {}

---@class HighlightGroups
M.HIGHLIGHT_GROUPS = {
  outdated = 'PackageInfoOutdatedVersion',
  up_to_date = 'PackageInfoUpToDateVersion',
  statusline_text = 'PackageInfoStatuslineText',
  statusline_spinner = 'PackageInfoStatuslineSpinner',
}

---@class PackageManagers
M.PACKAGE_MANAGERS = {
  yarn = 'yarn',
  npm = 'npm',
  pnpm = 'pnpm',
  bun = 'bun',
}

---@class DependencyType
M.DEPENDENCY_TYPE = {
  production = 'prod',
  development = 'dev',
}

---@class Commands
M.COMMANDS = {
  show = 'PackageInfoShow',
  show_force = 'PackageInfoShowForce',
  hide = 'PackageInfoHide',
  delete = 'PackageInfoDelete',
  update = 'PackageInfoUpdate',
  install = 'PackageInfoInstall',
  change_version = 'PackageInfoChangeVersion',
}

M.AUGROUP = 'PackageInfoAutogroup'

return M
