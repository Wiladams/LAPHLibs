
local ffi = require "ffi"
local stream = require "stream"


local FileStream = {}
setmetatable(FileStream, {
	__call = function (self, ...)
		return self:new(...);
	end,
})

local FileStream_mt = {
	__index = FileStream,
}

function FileStream.init(self, handle)
	if not handle then return nil end

	local obj = {
		FileHandle = handle,
		}

	setmetatable(obj, FileStream_mt)

	return obj;
end



function FileStream.new(self, filename, mode)
	if not filename then return nil end

	mode = mode or "wb+"
	local handle = io.open(filename, mode)
	if not handle then return nil end

	return self:init(handle)
end


function FileStream:length()
	local currpos = self.FileHandle:seek()
	local size = self.FileHandle:seek("end")

	self.FileHandle:seek("set",currpos)

	return size;
end

function FileStream:position(pos, origin)
	local currpos = self.FileHandle:seek()
	return currpos;
end

function FileStream:seek(offset, origin)
	offset = offset or 0
	origin = origin or stream.SEEK_SET

	if origin == stream.SEEK_CUR then
		return self.FileHandle:seek("cur", offset)
	elseif origin == stream.SEEK_SET then
		return self.FileHandle:seek("set", offset)
	elseif origin == stream.SEEK_END then
		return self.FileHandle:seek("end", offset)
	end

	return nil
end

function FileStream:readByte()
	local str = self.FileHandle:read(1)
	if not str then return str end

	return string.byte(str);
end

function FileStream:readBytes(buffer, len, offset)
	offset = offset or 0
	local str = self.FileHandle:read(len)
	local maxbytes = math.min(len, #str)
	ffi.copy(buffer+offset, str, maxbytes)

	return maxbytes
end

function FileStream:readString(count)
	local str = self.FileHandle:read(count)

	return str
end



function FileStream:writeByte(value)
	self.FileHandle:write(string.char(value))
	return 1
end

function FileStream:writeBytes(buffer, len, offset)
	offset = offset or 0

	if type(buffer) == "string" then
		self.FileHandle:write(buffer)
		return len
	end

	-- assume we have a pointer to a buffer
	-- convert to string and write it out
	local str = ffi.string(buffer, len)
	self.FileHandle:write(str)

	return len
end

function FileStream:writeString(str, count, offset)
	offset = offset or 0
	count = count or #str
	local strptr = ffi.cast("char *", str);

	return self:writeBytes(strptr, count, offset)
end

return FileStream;
