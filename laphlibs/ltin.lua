local table = require('table')
local ltin = {}
local sandbox = {}

-- Parse ltin code by reusing the lua parser in a sandbox
function ltin.decode(string)
    local fn, message = loadstring("return " .. string)
    if not fn then 
        error(message) 
    end
    setfenv(fn, sandbox)
    
    return fn()
end

-- stringify data to ltin using a pretty-printer
function ltin.encode(value)
  local t = type(value)
  if t == "number" or t == "boolean" or t == "nil" then
    return tostring(value)
  end

  if t == "string" then
    return '"' .. value:gsub("\\", "\\\\")
      :gsub("%z", "\\0"):gsub("\a", "\\a"):gsub("\b", "\\b")
      :gsub("\f", "\\f"):gsub("\n", "\\n"):gsub("\r", "\\r")
      :gsub("\t", "\\t"):gsub("\v", "\\v"):gsub('"', '\\"') .. '"'
  end
  
  if t == 'table' then
    local parts = {}
    local index = 1
    for key, item in pairs(value) do
      local keyString
      if key == index then
        keyString = ""
      elseif type(key) == "string" and key:match("^[_%a][_%w]*$") then
        keyString = key .. "="
      else
        keyString = "[" .. ltin.stringify(key) .. "]="
      end
      parts[index] = keyString .. ltin.stringify(item)
      index = index + 1
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  
  return "'" .. tostring(value):gsub("\\", "\\\\")
    :gsub("%z", "\\0"):gsub("\a", "\\a"):gsub("\b", "\\b")
    :gsub("\f", "\\f"):gsub("\n", "\\n"):gsub("\r", "\\r")
    :gsub("\t", "\\t"):gsub("\v", "\\v"):gsub("'", "\\'") .. "'"
end

return ltin
