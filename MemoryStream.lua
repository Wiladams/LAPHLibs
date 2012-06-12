
local ffi = require "ffi"
local stream = require "stream"


local MemoryStream = {}
local MemoryStream_mt = {
	__index = MemoryStream;
}

function MemoryStream.new(size, buff)
	offset = offset or 0
	buff = buff or ffi.new("uint8_t[?]", size)

	local obj = {Length = size, Buffer = buff, Offset = offset, Position = 0}
	setmetatable(obj, MemoryStream_mt)

	return obj
end

function MemoryStream:GetLength()
	return self.Length
end

function MemoryStream:GetPosition()
	return self.Position
end

--[[
	Reading interface
--]]

function MemoryStream:ReadByte()
	local pos = self.Position
	if pos < self.Length then
		self.Position = pos + 1
		return ffi.cast("const uint8_t *", self.Buffer)[pos];
	end

	return nil
end

function MemoryStream:ReadBytes(buff, count, offset)
	offset = offset or 0

	local pos = self.Position
	local remaining = self.Length - pos
	local src = ffi.cast("const uint8_t *", self.Buffer)+pos
	local dst = ffi.cast("uint8_t *", buff)+offset

	local maxbytes = math.min(count, remaining)
	if maxbytes < 1 then return 0 end

	ffi.copy(dst, src, maxbytes)

	self.Position = pos + maxbytes

	return maxbytes
end

function MemoryStream:ReadString(count)
	local pos = self.Position
	local remaining = self.Length - pos

	local maxbytes = math.min(count, remaining)
	if maxbytes < 1 then return nil end


	local src = ffi.cast("const uint8_t *", self.Buffer)+pos

	return ffi.string(src, maxbytes)
end


--[[
	Writing interface
--]]

function MemoryStream:WriteByte(byte)
	local pos = self.Position
	if pos < self.Length-1 then
		(ffi.cast("uint8_t *", self.Buffer)+pos)[0] = byte

		self.Position = pos + 1
		return 1
	end

	return 0
end

function MemoryStream:WriteBytes(buff, count, offset)
	offset = offset or 0
	local pos = self.Position
	local size = self.Length
	local remaining = size - pos
	local maxbytes = math.min(remaining, count)

	if maxbytes <= 0 then return 0 end

	local dst = ffi.cast("uint8_t *", self.Buffer)+pos
	local src = ffi.cast("const uint8_t *", buff)+offset

	ffi.copy(dst, src, maxbytes);


	self.Position = pos + maxbytes;

	return maxbytes;
end

function MemoryStream:WriteString(str, count, offset)
	offset = offset or 0
	count = count or #str

	return self:WriteBytes(str, count, offset)
end

function MemoryStream:Seek(pos, origin)
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

return MemoryStream;
