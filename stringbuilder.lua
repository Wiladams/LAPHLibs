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
    
    __add = function(self, ...)
    --print("__add")
        self:append(...)
        return self
    end,

    __concat = function(self, ...)
    print("__concat: ", select(1, ...))
        self:append(...)
        return self
    end,

    __tostring = function(self)
        return self:toString();
	end,
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

function StringBuilder.append(self, other)
    if type(other) == "string" then
        table.insert(self.accumulator, other)
        return self
    elseif type(other) == table then
        for _, value in ipairs(other) do
            table.insert(self.accumulator, value)
        end
    end
    

    return self;
end

function StringBuilder.toString(self, perLine)
    perLine = perLine or ""
    return table.concat(self.accumulator, perLine)
end


return StringBuilder