--[[
    enum.lua

    In many cases when you're converting some typical C code to Lua, 
    you come across this typical enum construct to deal with error codes.
    

    typedef enum {
        LIB_ERROR_NoError = 0,
        LIB_ERROR_ErrorNumber1 = 1,
        LIB_ERROR_ErrorNumber2 = 2,
        LIB_ERROR_ErrorNumber3 = 3,
        LIB_ERROR_ErrorNumber4 = 4,
        LIB_ERROR_ErrorNumber5 = 5
    }

    Then you might find some code that's like

    char * getErrorName(const int value);

    This is very typical of C code because there is no base type for a table
    like there is in Lua, so table and dictionary functionality is repeated 
    over and over again.

    In Lua, you have a much simpler scenario.  You simply need to construct a table
    and then do a lookup:

    local values = {
        [0] = "LIB_ERROR_NoError",
        [1] = "LIB_ERROR_ErrorNumber1",
        [2] = "LIB_ERROR_ErrorNumber2",
        [3] = "LIB_ERROR_ErrorNumber3",
        [4] = "LIB_ERROR_ErrorNumber4",
        [5] = "LIB_ERROR_ErrorNumber5",
    }

    And then the lookup is simply:

        print("name: ", values[2]);
        >> LIB_ERROR_ErrorNumber2

    Sometimes you want to bridge these two worlds.  You want the ease that Lua
    provides, which also being interactive with the C world using C constructs,
    and that's where this Lua enum construct comes in.
]]

local ffi = require("ffi")
local StringBuilder = require("stringbuilder")

local enum = {}
setmetatable(enum, {
    __call = function(self, ...)
        return self:create(...)
    end,
})
local enum_mt = {
    __index = enum;
}

function enum.init(self, alist)
    setmetatable(alist, enum_mt)

    return alist;
end

function enum.create(self, alist)
    local alist = alist or {}
    return self:init(alist);
end

function enum.stringToValue(self, aname)
    return  self[aname] or false;
end

function enum.valueToString(self, aValue)
    -- enumerate through the table looking for value
    for k,v in pairs(self) do
        if v == aValue then
            return k;
        end
    end

    return false;
end

local function dictLength(dict)
    local len = 0;
    for k,v in pairs(dict) do
        len = len + 1;
    end

    return len;
end

function enum.getCdef(self, enumname, prefix, inorder)
    enumname = enumname or ""
    prefix = prefix or ""
    local sb = StringBuilder()
    
    sb:append("typedef enum {")
    if not inorder then
        for k,v in pairs(self) do
            local keyname = prefix..k
            local cString = string.format("    %s = %d,", keyname, v);
            sb:append(cString)
        end
    else
        -- Want to do them in numerical order
        -- best way is to put in sorted table
        local len = dictLength(self);
        --print("LENGTH: ", len)
    end
    sb:append(string.format("} %s;", enumname))

    return sb:toString("\n")
end

function enum.importCdef(self, enumname, prefix)
    ffi.cdef(self:getCdef(enumname, prefix))
end


return enum