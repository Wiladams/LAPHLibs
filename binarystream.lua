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

local BinaryStream = {}
local BinaryStream_mt = {
	__index = BinaryStream;
}

ffi.cdef[[
typedef union  {
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

--local types_buffer = bstream_types_t();


function BinaryStream.new(stream, bigendian)
	local obj = {
		Stream = stream,
		BigEndian = bigendian,
		NeedSwap = 	bigendian == ffi.abi("le"),
		types_buffer = bstream_types_t();
	}

	setmetatable(obj, BinaryStream_mt);

	return obj
end

function BinaryStream:ReadByte()
	return self.Stream:ReadByte()
end

function BinaryStream:ReadInt16()

	-- Read two bytes
	-- return nil if two bytes not read
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 2, 0) <2)
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

function BinaryStream:ReadUInt16()

	-- Read two bytes
	-- return nil if two bytes not read
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 2, 0) <2)
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

function BinaryStream:ReadInt32()

	-- Read four bytes
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 4, 0) <4)
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

function BinaryStream:ReadUInt32()

	-- Read four bytes
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 4, 0) <4) then
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
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 8, 0) <8)
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

function BinaryStream:ReadUInt64()
	-- Read eight bytes
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 8, 0) <8)
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
function BinaryStream:ReadSingle()
	-- determine if we need to do any swapping
	local needswap = self.BigEndian == ffi.abi("le")

	-- Read four bytes
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 4, 0) <4)
		then return nil
	end

	-- if we don't need to do any swapping, then
	-- we can just return the value right away
	if not needswap then
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

function BinaryStream:ReadDouble()
	-- Read eight bytes
	if (self.Stream:ReadBytes(self.types_buffer.bytes, 8, 0) <8)
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

function BinaryStream:ReadBytes(buffer, size, offset)
	return self.Stream:ReadBytes(buffer, size, offset)
end






function BinaryStream:WriteByte(value)
	return self.Stream:WriteByte(value) == 1;
end

function BinaryStream:WriteBytes(buff, length, offset)
	return self.Stream:WriteBytes(buff, length, offset);
end

function BinaryStream:WriteInt16(value)
	self.types_buffer.Int16 = value

	if not self.NeedSwap then
		return self.Stream:WriteBytes(self.types_buffer.bytes, 2, 0) == 2
	end

	-- Need to swap bytes
	local tmp = self.types_buffer.bytes[0]
	self.types_buffer.bytes[0] = self.types_buffer.bytes[1]
	self.types_buffer.bytes[1] = tmp

	return self.Stream:WriteBytes(self.types_buffer.bytes, 2, 0) == 2
end

function BinaryStream:WriteInt32(value)
	self.types_buffer.Int32 = value

	if not self.NeedSwap then
		return self.Stream:WriteBytes(self.types_buffer.bytes, 4, 0) == 4
	end

	self.types_buffer.Int32 = bswap(self.types_buffer.Int32)

	return self.Stream:WriteBytes(self.types_buffer.bytes, 4, 0) == 4
end

function BinaryStream:WriteInt64(value)
	self.types_buffer.Int64 = value

	if not self.NeedSwap then
		return self.Stream:WriteBytes(self.types_buffer.bytes, 8, 0) == 8
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


	return self.Stream:WriteBytes(self.types_buffer.bytes, 8, 0) == 8
end

function BinaryStream:WriteSingle(value)
	self.types_buffer.Single = value

	if not self.NeedSwap then
		return self.Stream:WriteBytes(self.types_buffer.bytes, 4, 0) == 4
	end

	local tmp = self.types_buffer.bytes[0];
	self.types_buffer.bytes[0] = self.types_buffer.bytes[3];
	self.types_buffer.bytes[3] = tmp;
	tmp = self.types_buffer.bytes[1];
	self.types_buffer.bytes[1] = self.types_buffer.bytes[2];
	self.types_buffer.bytes[2] = tmp;


	return self.Stream:WriteBytes(self.types_buffer.bytes, 4, 0) == 4
end

function BinaryStream:WriteDouble(value)
	self.types_buffer.Double = value

	if not self.NeedSwap then
		return self.Stream:WriteBytes(self.types_buffer.bytes, 8, 0) == 8
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


	return self.Stream:WriteBytes(self.types_buffer.bytes, 8, 0) == 8
end

return BinaryStream;
