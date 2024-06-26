local M = {}

M.HIGHLIGHT_GROUPS = {
  outdated = 'PackageInfoOutdatedVersion',
  up_to_date = 'PackageInfoUpToDateVersion',
  statusline_text = 'PackageInfoStatuslineText',
  statusline_spinner = 'PackageInfoStatuslineSpinner',
}

M.PACKAGE_MANAGERS = {
  yarn = 'yarn',
  npm = 'npm',
  pnpm = 'pnpm',
  bun = 'bun',
}

M.DEPENDENCY_TYPE = {
  production = 'prod',
  development = 'dev',
}

M.LEGACY_COLORS = {
  up_to_date = '237',
  outdated = '173',
}

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
