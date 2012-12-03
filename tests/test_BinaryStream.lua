package.path = package.path..";../?.lua";

local BinaryStream = require "BinaryStream"
local MemoryStream = require "MemoryStream"

function test_ByteValues()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream);

	bstream:WriteByte(1)

	bstream.Stream:Seek(0)

	print("Read single byte: ", bstream:ReadByte())
end


function test_IntValues()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream);

	bstream:WriteInt16(16)
	bstream:WriteInt16(24)
	bstream:WriteInt16(-24);
	bstream:WriteInt32(32)
	bstream:WriteInt32(40)
	bstream:WriteInt32(-40)

	-- rewind the stream
	mstream:Seek(0)

	-- Verify values
	assert(bstream:ReadInt16() == 16);
	assert(bstream:ReadInt16() == 24);
	assert(bstream:ReadInt16() == -24);
	assert(bstream:ReadInt32() == 32);
	assert(bstream:ReadInt32() == 40);
	assert(bstream:ReadInt32() == -40);

	print("PASS");
end

function test_FloatValues()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream);

	bstream:WriteSingle(16.5)
	bstream:WriteSingle(24.709)
	bstream:WriteSingle(-24.75);
	bstream:WriteDouble(32)
	bstream:WriteDouble(4.0007)
	bstream:WriteDouble(-400.654)

	-- rewind the stream
	mstream:Seek(0)

	-- Verify values
	print(bstream:ReadSingle());
	print(bstream:ReadSingle());
	print(bstream:ReadSingle());
	print(bstream:ReadDouble());
	print(bstream:ReadDouble());
	print(bstream:ReadDouble());

	print("PASS");
end

test_IntValues();
test_FloatValues();
