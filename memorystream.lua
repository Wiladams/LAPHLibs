
local ffi = require "ffi"
local stream = require "stream"


local MemoryStream = {}
setmetatable(MemoryStream, {
		__call = function(self, ...)
		return self:new(...)
	end,
})

local MemoryStream_mt = {
	__index = MemoryStream;
}

function MemoryStream.init(self, buff, bufflen, byteswritten)
	if not buff then return nil end
	if not bufflen then return nil end

	byteswritten = byteswritten or 0

	local obj = {
		Length = bufflen,
		Buffer = buff,
		Position = 0,
		BytesWritten = byteswritten,
		}

	setmetatable(obj, MemoryStream_mt)

	return obj
end

-- MemoryStream constructors
--
-- MemoryStream:new(8192)	-- Create a buffer with 8192 bytes
-- MemoryStream:new("string" [, len])	-- create a buffer atop some lua string
-- MemoryStream:new(cdata, len)			-- create a buffer atop some cdata structure with length

function MemoryStream.new(self, ...)
	local buff = nil;
	local bufflen = nil;
	local byteswritten = 0;

	local nargs = select('#', ...);

	if nargs == 1 then
		if type(select(1, ...)=="number") then
			bufflen = select(1,...);
			buff = ffi.new("uint8_t[?]", bufflen)
			byteswritten = 0
		elseif type(select(1,...)=="string") then
			buff = select(1, ...);
			bufflen = #buff;
			byteswritten = bufflen;
		end
	elseif nargs == 2 then
		if type(select(1, ...))=="string" then
			if type(select(2,...)) ~= "number" then
				return nil;
			end

			buff = select(1,...);
			bufflen = #buff;
			byteswritten = bufflen;
		elseif type(select(1,...))=="ctype" then
			buff = select(1,...);
			bufflen = ffi.sizeof(buff);
			byteswritten = bufflen;
		end
	end


	return self:init(buff, bufflen, byteswritten);
end


function MemoryStream:reset()
	self.Position = 0
	self.BytesWritten = 0
end

function MemoryStream:length()
	return self.Length
end

function MemoryStream:position(pos, origin)
	if pos ~= nil then
		return self:seek(pos, origin);
	end

	return self.Position
end

function MemoryStream:remaining()
	return self.Length - self.Position
end

function MemoryStream:bytesReadyToBeRead()
	return self.BytesWritten - self.Position
end

function MemoryStream:canRead()
	return self:bytesReadyToBeRead() > 0
end

function MemoryStream:seek(pos, origin)
	origin = origin or stream.SEEK_SET

	if origin == stream.SEEK_CUR then
		local newpos = self.Position + pos
		if newpos >= 0 and newpos < self.Length then
			self.Position = newpos
		end
	elseif origin == stream.SEEK_SET then
		if pos >= 0 and pos < self.Length then
			self.Position = pos;
		end
	elseif origin == stream.SEEK_END then
		local newpos = self.Length-1 + pos
		if newpos >= 0 and newpos < self.Length then
			self.Position = newpos
		end
	end

	return self.Position
end

--[[
	Reading interface
--]]
-- The Bytes() function acts as an iterator on bytes
-- from the stream.
function MemoryStream:bytes(maxbytes)
	local buffptr = ffi.cast("const uint8_t *", self.Buffer);
	local bytesleft = maxbytes or math.huge
	local pos = -1

	local function closure()
		--print("-- REMAINING: ", bytesleft)
		-- if we've read the maximum nuber of bytes
		-- then just return nil to indicate finished
		if bytesleft == 0 then return end

		pos = pos + 1

		-- We've reached the end of the stream
		if pos >= self.Position then
			return nil
		end
		bytesleft = bytesleft - 1

		return buffptr[pos]
	end

	return closure
end

function MemoryStream:readByte()
	local buffptr = ffi.cast("const uint8_t *", self.Buffer);

	local pos = self.Position
	if pos < self.BytesWritten then
		self.Position = pos + 1
		return buffptr[pos];
	end

	return nil, "eof"
end

function MemoryStream:readBytes(buff, count, offset)
	offset = offset or 0

	local pos = self.Position
	local remaining = self:remaining()
	local src = ffi.cast("const uint8_t *", self.Buffer)+pos
	local dst = ffi.cast("uint8_t *", buff)+offset

	local maxbytes = math.min(count, remaining)
	if maxbytes < 1 then
		return nil, "eof"
	end

	ffi.copy(dst, src, maxbytes)

	self.Position = pos + maxbytes

	return maxbytes
end

function MemoryStream:readString(count)
	local pos = self.Position
	local remaining = self.Length - pos

	local maxbytes = math.min(count, remaining)
	if maxbytes < 1 then return nil end


	local src = ffi.cast("const uint8_t *", self.Buffer)+pos

	-- advance the stream position
	self.Position = pos + maxbytes

	return ffi.string(src, maxbytes)
end

-- Read characters from a stream until the specified
-- ending is found, or until the stream runs out of bytes
local CR = string.byte("\r")
local LF = string.byte("\n")

function MemoryStream:readLine(maxbytes)
--print("-- MemoryStream:ReadLine()");

	local readytoberead = self:bytesReadyToBeRead()

	maxbytes = maxbytes or readytoberead

	local maxlen = math.min(maxbytes, readytoberead)
	local buffptr = ffi.cast("uint8_t *", self.Buffer);

	local nchars = 0;
	local bytesconsumed = 0;
	local startptr = buffptr + self.Position
	local abyte
	local err

--print("-- MemoryStream:ReadLine(), maxlen: ", maxlen);

	for n=1, maxlen do
		abyte, err = self:readByte()
		if not abyte then
			break
		end

		bytesconsumed = bytesconsumed + 1

		if abyte == LF then
			break
		elseif abyte ~= CR then
			nchars = nchars+1
		end
	end

	-- End of File, nothing consumed
	if bytesconsumed == 0 then
		return nil, "eof"
	end

	-- A blank line
	if nchars == 0 then
		return ''
	end

	-- an actual line of data
	return ffi.string(startptr, nchars);
end

--[[
	Writing interface
--]]

function MemoryStream:writeByte(byte)
	-- don't write a nil value
	-- a nil is not the same as a '0'
	if not byte then return end

	local pos = self.Position
	if pos < self.Length-1 then
		(ffi.cast("uint8_t *", self.Buffer)+pos)[0] = byte

		self.Position = pos + 1
		if self.Position > self.BytesWritten then
			self.BytesWritten = self.Position
		end

		return 1
	end

	return false
end

function MemoryStream:writeBytes(buff, count, offset)
	offset = offset or 0
	local pos = self.Position
	local size = self.Length
	local remaining = size - pos
	local maxbytes = math.min(remaining, count)

	if maxbytes <= 0
		then return 0
	end

	local dst = ffi.cast("uint8_t *", self.Buffer)+pos
	local src = ffi.cast("const uint8_t *", buff)+offset

	ffi.copy(dst, src, maxbytes);


	self.Position = pos + maxbytes;
	if self.Position > self.BytesWritten then
		self.BytesWritten = self.Position
	end

	return maxbytes;
end

function MemoryStream:writeString(str, count, offset)
	offset = offset or 0
	count = count or #str

	--print("-- MemoryStream:WriteString():", str);

	return self:writeBytes(str, count, offset)
end

--[[
	Write the specified number of bytes from the current
	stream into the specified stream.

	Start from the current position in the current stream
--]]

function MemoryStream:writeStream(stream, size)
	local count = 0
	local abyte = stream:readByte()
	while abyte and count < size do
		self:writeByte(abyte)
		count = count + 1
		abyte = stream:readByte()
	end

	return count
end

function MemoryStream:writeLine(line)
	local status, err

	if line then
		status, err = self:writeString(line)
		if err then
			return nil, err
		end
	end

	-- write the terminator
	status, err = self:writeString("\r\n");

	return status, err
end

--[[
	Moving big chunks around
--]]

function MemoryStream:copyTo(stream)
	-- copy from the beginning
	-- to the current position
	local remaining = self.BytesWritten
	local byteswritten = 0

	while (byteswritten < remaining) do
		byteswritten = byteswritten + stream:writeBytes(self.Buffer, self.Position, byteswritten)
	end
end



--[[
	Utility
--]]
function MemoryStream:toString()
	local len = self.Position

	if len > 0 then
		--print("Buffer: ", self.Buffer, len);
		local str = ffi.string(self.Buffer, len)
		return str;
	end

	return nil
end

return MemoryStream;
