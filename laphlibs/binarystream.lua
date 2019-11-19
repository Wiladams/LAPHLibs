--[[
	References:

	http://en.wikipedia.org/wiki/Endianness
	http://local.wasp.uwa.edu.au/~pbourke/dataformats/endian/

	The BinaryStream object wraps a basic stream and implements
	a series of readers and writers of base types.  There are a
	couple of benefits to having this class.

	1) It can work with any stream.  The stream just has to
	implement ReadByte(), ReadBytes(buffer, count, offset) and
	WriteByte(value), WriteBytes(buffer, count, offset).  With
	these basic functions available, any of the base types
	can be read and written.

	2) It can deal with endianness (LSB, and MSB).  The stream
	can be configured to assume the base stream is LSB or MSB
	and will perform all the conversions automatically.
--]]


local ffi = require "ffi"
local bit = require "bit"
local bswap = bit.bswap



ffi.cdef[[
typedef union  bstream_types_t {
		uint8_t		Byte;
		int16_t 	Int16;
		uint16_t	UInt16;
		int32_t		Int32;
		uint32_t	UInt32;
		int64_t		Int64;
		uint64_t	UInt64;
		float 		Single;
		double 		Double;
		uint8_t bytes[8];
} bstream_types_t
]]
local bstream_types_t = ffi.typeof("bstream_types_t")


--[[
	stream - a stream that we will wrap
	
	bigendian - tells us what format the data within the 
	  wrapped stream is in.
--]]
local BinaryStream = {}
setmetatable(BinaryStream, {
	__call = function (self, ...)
		return self:new(...);
	end,
})

local BinaryStream_mt = {
	__index = BinaryStream;
}


function BinaryStream.init(self, stream, bigendian)
	local obj = {
		Stream = stream,
		BigEndian = bigendian,
		NeedSwap = 	bigendian == ffi.abi("le"),
		types_buffer = bstream_types_t();
	}

	setmetatable(obj, BinaryStream_mt);

	return obj
end

function BinaryStream.new(self, stream, bigendian)
	return self:init(stream, bigendian);
end

function BinaryStream:readByte()
	return self.Stream:readByte()
end

function BinaryStream:readInt16()

	-- Read two bytes
	-- return nil if two bytes not read
	if (self.Stream:readBytes(self.types_buffer.bytes, 2, 0) <2)
		then return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the Int16 right away
	if not self.NeedSwap then
		return self.types_buffer.Int16;
	end

	local tmp = self.types_buffer.bytes[0]
	self.types_buffer.bytes[0] = self.types_buffer.bytes[1]
	self.types_buffer.bytes[1] = tmp

	return self.self.types_buffer.Int16;
end

function BinaryStream:readUInt16()

	-- Read two bytes
	-- return nil if two bytes not read
	if (self.Stream:readBytes(self.types_buffer.bytes, 2, 0) <2)
		then return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the Int16 right away
	if not self.NeedSwap then
		return self.types_buffer.UInt16;
	end

	local tmp = self.types_buffer.bytes[0]
	self.types_buffer.bytes[0] = self.types_buffer.bytes[1]
	self.types_buffer.bytes[1] = tmp

	return self.types_buffer.UInt16;
end

function BinaryStream:readInt32()

	-- Read four bytes
	if (self.Stream:readBytes(self.types_buffer.bytes, 4, 0) <4)
		then return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the Int32 right away
	if not self.NeedSwap then
		return self.types_buffer.Int32;
	end

	return bit.bswap(self.types_buffer.Int32);

--[[
	-- The very longhand way
	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = tmp;
	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = tmp;


	-- then return an int32
	return self.types_buffer.Int32;
--]]
end

function BinaryStream:readUInt32()

	-- Read four bytes
	if (self.Stream:readBytes(self.types_buffer.bytes, 4, 0) <4) then
		return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the value right away
	if not self.NeedSwap then
		return self.types_buffer.UInt32;
	end

	return bit.bswap(self.types_buffer.UInt32);
--[[
	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = tmp;
	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = tmp;

	-- then return an int32
	return self.types_buffer.UInt32;
--]]
end

function BinaryStream:ReadInt64()
	-- Read eight bytes
	if (self.Stream:readBytes(self.types_buffer.bytes, 8, 0) <8)
		then return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the value right away
	if not self.NeedSwap then
		return tonumber(self.types_buffer.Int64);
	end

	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[7];
	self.types_buffer.bytes[7] = tmp;

	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[6];
	self.types_buffer.bytes[6] = tmp;

	tmp = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = self.types_buffer.bytes[5];
	self.types_buffer.bytes[5] = tmp;

	tmp = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = self.types_buffer.bytes[4];
	self.types_buffer.bytes[4] = tmp;


	-- then bit convert to an int64
	return tonumber(self.types_buffer.Int64);
end

function BinaryStream:readUInt64()
	-- Read eight bytes
	if (self.Stream:readBytes(self.types_buffer.bytes, 8, 0) <8)
		then return nil
	end

		-- if we don't need to do any swapping, then
	-- we can just return the value right away
	if not self.NeedSwap then
		return tonumber(self.types_buffer.UInt64);
	end

	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[7];
	self.types_buffer.bytes[7] = tmp;

	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[6];
	self.types_buffer.bytes[6] = tmp;

	tmp = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = self.types_buffer.bytes[5];
	self.types_buffer.bytes[5] = tmp;

	tmp = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = self.types_buffer.bytes[4];
	self.types_buffer.bytes[4] = tmp;

	-- then bit convert to an int64
	return self.types_buffer.UInt64;
end

--[[
	Assuming IEEE format for 4-byte floats
--]]
function BinaryStream:readSingle()
	-- Read four bytes
	if (self.Stream:readBytes(self.types_buffer.bytes, 4, 0) <4)
		then return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the value right away
	if not self.NeedSwap then
		return self.types_buffer.Single;
	end

	-- could do this, but then an integer would
	-- be returned, so we'll just swap the bytes
	-- in memory, and let the system do the coercion
	--return bit.bswap(self.types_buffer.UInt32);

	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = tmp;
	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = tmp;

	-- then return the swapped value
	return self.types_buffer.Single;
end

function BinaryStream:readDouble()
	-- Read eight bytes
	if (self.Stream:readBytes(self.types_buffer.bytes, 8, 0) <8)
		then return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the value right away
	if not self.NeedSwap then
		return tonumber(self.types_buffer.Double);
	end

	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[7];
	self.types_buffer.bytes[7] = tmp;

	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[6];
	self.types_buffer.bytes[6] = tmp;

	tmp = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = self.types_buffer.bytes[5];
	self.types_buffer.bytes[5] = tmp;

	tmp = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = self.types_buffer.bytes[4];
	self.types_buffer.bytes[4] = tmp;

	-- then bit convert to a Double
	return tonumber(self.types_buffer.Double);
end

function BinaryStream:readBytes(buffer, size, offset)
	return self.Stream:readBytes(buffer, size, offset)
end






function BinaryStream:writeByte(value)
	return self.Stream:writeByte(value) == 1;
end

function BinaryStream:writeBytes(buff, length, offset)
	return self.Stream:writeBytes(buff, length, offset);
end

function BinaryStream:writeInt16(value)
	self.types_buffer.Int16 = value

	if not self.NeedSwap then
		return self.Stream:writeBytes(self.types_buffer.bytes, 2, 0) == 2
	end

	-- Need to swap bytes
	local tmp = self.types_buffer.bytes[0]
	self.types_buffer.bytes[0] = self.types_buffer.bytes[1]
	self.types_buffer.bytes[1] = tmp

	return self.Stream:writeBytes(self.types_buffer.bytes, 2, 0) == 2
end

function BinaryStream:writeInt32(value)
	self.types_buffer.Int32 = value

	if not self.NeedSwap then
		return self.Stream:writeBytes(self.types_buffer.bytes, 4, 0) == 4
	end

	self.types_buffer.Int32 = bswap(self.types_buffer.Int32)

	return self.Stream:writeBytes(self.types_buffer.bytes, 4, 0) == 4
end

function BinaryStream:writeInt64(value)
	self.types_buffer.Int64 = value

	if not self.NeedSwap then
		return self.Stream:writeBytes(self.types_buffer.bytes, 8, 0) == 8
	end


	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[7];
	self.types_buffer.bytes[7] = tmp;

	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[6];
	self.types_buffer.bytes[6] = tmp;

	tmp = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = self.types_buffer.bytes[5];
	self.types_buffer.bytes[5] = tmp;

	tmp = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = self.types_buffer.bytes[4];
	self.types_buffer.bytes[4] = tmp;


	return self.Stream:writeBytes(self.types_buffer.bytes, 8, 0) == 8
end

function BinaryStream:writeSingle(value)
	self.types_buffer.Single = value

	if not self.NeedSwap then
		return self.Stream:writeBytes(self.types_buffer.bytes, 4, 0) == 4
	end

	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = tmp;
	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = tmp;


	return self.Stream:writeBytes(self.types_buffer.bytes, 4, 0) == 4
end

function BinaryStream:writeDouble(value)
	self.types_buffer.Double = value

	if not self.NeedSwap then
		return self.Stream:writeBytes(self.types_buffer.bytes, 8, 0) == 8
	end

	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[7];
	self.types_buffer.bytes[7] = tmp;

	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[6];
	self.types_buffer.bytes[6] = tmp;

	tmp = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = self.types_buffer.bytes[5];
	self.types_buffer.bytes[5] = tmp;

	tmp = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = self.types_buffer.bytes[4];
	self.types_buffer.bytes[4] = tmp;


	return self.Stream:writeBytes(self.types_buffer.bytes, 8, 0) == 8
end

return BinaryStream;
