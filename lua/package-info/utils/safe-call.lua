---Call the function if its not nil
---@param callback fun() - function to try and call
return function(callback)
  if callback ~= nil then
    callback()
  end
end
