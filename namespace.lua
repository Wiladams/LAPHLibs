--[[
    namespace()

    This function will allow you to create a local 
    namespace.  Things that are added to it will look
    like they are global, but they will actually be
    local to the module you are in.

    local namespace = require("namespace")
    local myns = namespace()

    myns.floor = math.floor
    myns.a = 100.2

    print(floor(a))
]]
local function namespace(res)
    res = res or {}
    setmetatable(res, {__index= _G})
    setfenv(2, res)
    return res
end

return namespace

