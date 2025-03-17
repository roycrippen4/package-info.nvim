return function()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

  local hash = string.gsub(template, '[xy]', function(character)
    local random_character = (character == 'x') and math.random(0, 0xf) or math.random(8, 0xb)

    return string.format('%x', random_character)
  end)

  return hash
end
