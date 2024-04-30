--- Register given highlight group
--- @param highlight_group string - highlight group to register
--- @param color string - color to use with the highlight group
return function(highlight_group, color)
  vim.api.nvim_set_hl(0, highlight_group, { fg = color })
end
