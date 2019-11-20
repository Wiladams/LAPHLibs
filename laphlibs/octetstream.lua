--[[
    This file is a general memory stream interface.

    Octetstream serves up 8-bit bytes, one at a time 
    with a readOctet() function.  You can also read
    multiple octets at once with readBytes().

    
]]
local ffi = require("ffi")
local min = math.min

--[[
    Standard 'object' construct.
    __call is implemented so we get a 'constructor'
    sort of feel:
    octetstream(data, size, position)
]]
local octetstream = {
    EOF = -1
}
setmetatable(octetstream, {
		__call = function(self, ...)
		return self:new(...)
	end,
})

local octetstream_mt = {
	__index = octetstream;
}


function octetstream.init(self, data, size, position)
    position = position or 0
    size = size or #data

    local obj = {
        data = ffi.cast("uint8_t *", data);
        size = tonumber(size);
        cursor = tonumber(position);
    }
 
    setmetatable(obj, octetstream_mt)
    return obj
end

function octetstream.new(self, data, size, position)
    return self:init(data, size, position);
end

--[[
-- get a subrange of the stream
-- this is an alias to the data
-- not a copy
    BUGBUG - Need to worry about losing the 
    pointer reference to garbage collection.

    Should probably retain a reference to it.
--]]
function octetstream.range(self, size, pos)
    pos = pos or self.cursor;

    if pos < 0 or size < 0 then
        return false, "pos or size < 0"
    end

    if pos > self.size then
        return false, "pos > self.size"
    end

    if ((size > (self.size - pos))) then 
        return false, "size is greater than remainder";
    end

    return octetstream(self.data+pos, size, 0)
end

-- report how many bytes remain to be read
-- from stream
function octetstream.remaining(self)
    return self.size - self.cursor
end

function octetstream.isEOF(self)
    return self:remaining() < 1
end

--[[
    seekFromBeginning(self, pos)

    pos - an absolute position number
        if you specify < 0, it will be set to 0
            remaining() will be whatever the length of
            the data is
        if you specify > size, it will be set to size
            isEOF() will return true
            remaining() will return 0
 --]]
function octetstream.seekFromBeginning(self, pos)
    if not pos then return self end

    if pos < 0 then pos = 0 end
    if pos > self.size then pos = self.size end

    self.cursor = pos;
 
    return self;
end

--[[
    seekFromCurrent(self, size)

    Move the cursor by the specified amount.
    Usually you skip in a positive direction, but
    you can actually move in either direction.
    if size < 0, move towards beginning of stream
    if size > 1, move towards end of stream

    This is essentially a seek() relative to current
    position, rather than to an absolute position
]]

function octetstream.seekFromCurrent(self, size)
    size = size or 1;
    return self:seekFromBeginning(self.cursor + size);
end
octetstream.skip = octetstream.seekFromCurrent

function octetstream.seekFromEnd(self, size)
    return self:seekFromBeginning(self.size - size)
end

--[[
    tell(self)

    Return the current position within the stream.
]]
function octetstream.tell(self)
    return self.cursor;
end

--[[
    Get a pointer to the current position
]]
function octetstream.getPositionPointer(self)
    return self.data + self.cursor;
end

--[[
-- get 8 bits, and don't advance the cursor
-- the offset parameter can be used to peek further
    into the future than the current byte.
--]]

function octetstream.peekOctet(self, offset)
    offset = offset or 0
    if (self.cursor+offset >= self.size) then
        return -1;
    end

    return self.data[self.cursor+offset];
end



-- get 8 bits, and advance the cursor
function octetstream.readOctet(self)
    -- check to ensure we don't go beyond end
    if (self.cursor >= self.size) then
       return false, "EOF";
    end

    self.cursor = self.cursor + 1;
    
    return self.data[self.cursor-1]
 end
 



-- BUGBUG, do error checking against end of stream
function octetstream.readBytes(self, size, bytes)
    if size < 1 then 
        return 0, "must specify a size > 0 octets" 
    end

    if self:isEOF() then
        return -1;
    end

    -- calculate how many bytes we can actually 
    -- read, based on what's remaining
    local sizeActual = min(size, self:remaining())

    -- read the minimum between remaining and 'n'
    bytes = bytes or ffi.new("uint8_t[?]", sizeActual)
    ffi.copy(bytes, self.data+self.cursor, sizeActual)
    self:skip(sizeActual)

    return bytes, nActual;
end


--[[
    writeOctet(self, octet)

    octet - the single parameter to be written

    Return:
        -1 if failure
        1 if octet was written
--]]
function octetstream.writeOctet(self, octet)
    if self:remaining() < 1 then
        return -1;
    end

    self.data[self.cursor] = octet;
    self.cursor = self.cursor + 1;

    return 1;
end

function octetstream.writeOctetStream(self, stream)
    for _, c in stream:octets() do
        -- we should bail early if we can't write
        -- the full stream
        local result = self:writeOctet(c)
        if result == -1 then
            break;
        end
    end

    -- should we return number of octets written?
    -- what to return if there was an error?
    return true;
end

--[[
-- Need to think about proper semantics here
function octetstream.writeOctets(self, octets, size, allowTruncate)
    if not octets then
        return false, "no octets specified"
    end

    size = size or #bytes
    if size > self:remaining() then 
        return false, "Not enough space"
    end

    ffi.copy(self.data+self.cursor, ffi.cast("const char *", bytes, n))
    self:skip(n)

    return true;
end
--]]





--[[
    octets()

    A pure functional iterator of the octets in the stream.
    There are no side effects on the original octecstream, unless
    the data member has a metamethod which causes side effects
    when the __index metamethod is called.

    The iterator can be started at any given offset
    indicated by the initial 'state'
    offset will default to 0 if not specified
--]]

function octetstream.octets(self, state)
    state = state or 0

    local function octet_gen(params, state)
        -- if we've reached the end of the stream
        -- terminate the iteration
        if params.size - state < 1 then
            return nil;
        end

        return state+1, params.data[state]
    end

    return octet_gen, self, state
end


return octetstream