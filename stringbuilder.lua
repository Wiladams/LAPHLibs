--[[
    A simple class to help build up strings
--]]

local table = table;

local StringBuilder = {}
setmetatable(StringBuilder, {
    __call = function(self, ...)
        return self:create(...);
    end,
})

local StringBuilder_mt = {
    __index = StringBuilder;
}

function StringBuilder.init(self, ...)
    local obj = {
        accumulator = {}
    }
    setmetatable(obj, StringBuilder_mt)

    return obj;
end

function StringBuilder.create(self, ...)
    return self:init(...)
end

function StringBuilder.append(self, str)
    table.insert(self.accumulator, str)
end

function StringBuilder.toString(self, perLine)
    perLine = perLine or ""
    return table.concat(self.accumulator, perLine)
end


return StringBuilder