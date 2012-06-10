
local ffi = require "ffi"
local stream = require "stream"


local FileStream = {}
local FileStream_mt = {
	__index = FileStream,
}

function FileStream.new(handle)
	if not handle then return nil end

	local obj = {
		FileHandle = handle,
		}

	setmetatable(obj, FileStream_mt)

	return obj;
end



function FileStream.Open(filename, mode)
	if not filename then return nil end

	mode = mode or "wb+"
	local handle = io.open(filename, mode)
	if not handle then return nil end

	return FileStream.new(handle)
end



function FileStream:Seek(offset, origin)
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

function FileStream:ReadByte()
	local str = self.FileHandle:read(1)
	if not str then return str end

	return string.byte(str);
end

function FileStream:ReadBytes(buffer, len, offset)
	offset = offset or 0
	local str = self.FileHandle:read(len)
	local maxbytes = math.min(len, #str)
	ffi.copy(buffer+offset, str, maxbytes)

	return maxbytes
end

function FileStream:ReadString(count)
	local str = self.FileHandle:read(count)

	return str
end



function FileStream:WriteByte(value)
	self.FileHandle:write(string.char(value))
	return 1
end

function FileStream:WriteBytes(buffer, len, offset)
	offset = offset or 0
	local str = ffi.string(buffer+offset, len)
	self.FileHandle:write(str)

	return len
end

function FileStream:WriteString(str, count, offset)
	offset = offset or 0
	count = count or #str
	local strptr = ffi.cast("char *", str);

	return self:WriteBytes(strptr, count, offset)
end

return FileStream;
