package.path = package.path..";../?.lua";

local BinaryStream = require "binarystream"
local MemoryStream = require "memorystream"

function test_bitbytes()
	print("==== test_bitbytes ====")
	local value = 3.7;
	local bt = ffi.new("bstream_types_t");

	bt.Single = 3.7;
	print("float 3.7: ", bytestobinary(bt.b, 4, 0))

	bt.Int = 3;
	print("int 3: ", bytestobinary(bt.b, 4, 0))

	bt.Short = -10;
	print("Short -10: ", bytestobinary(bt.b, 2, 0))

	bt.Short = bit.arshift(-10,2);
	print("arshift Short -10, 2: ", bytestobinary(bt.b, 2, 0))

	bt.Short = bit.rshift(-10,2);
	print("rshift Short -10, 2: ", bytestobinary(bt.b, 2, 0))

	bt.Short = 10;
	print("Short 10: ", bytestobinary(bt.b, 2, 0))

	bt.Short = rshift(10,1);
	print("rshift Short 10,1: ", bytestobinary(bt.b, 2, 0))

	bt.Short = bit.arshift(10,2);
	print("arshift Short 10,2: ", bytestobinary(bt.b, 2, 0))

end


function test_ByteValues()
	local mstream = MemoryStream(1024);
	local bstream = BinaryStream.new(mstream);

	bstream:writeByte(1)

	bstream.Stream:seek(0)

	print("Read single byte: ", bstream:readByte())
end


function test_IntValues()
	local mstream = MemoryStream(1024);
	local bstream = BinaryStream(mstream);

	bstream:writeInt16(16)
	bstream:writeInt16(24)
	bstream:writeInt16(-24);
	bstream:writeInt32(32)
	bstream:writeInt32(40)
	bstream:writeInt32(-40)

	-- rewind the stream
	mstream:seek(0)

	-- Verify values
	assert(bstream:readInt16() == 16);
	assert(bstream:readInt16() == 24);
	assert(bstream:readInt16() == -24);
	assert(bstream:readInt32() == 32);
	assert(bstream:readInt32() == 40);
	assert(bstream:readInt32() == -40);

	print("PASS");
end

function test_FloatValues()
	print("==== test_FloatValues ====")
	local mstream = MemoryStream(1024);
	local bstream = BinaryStream(mstream);

	bstream:writeSingle(16.5)
	bstream:writeSingle(24.709)
	bstream:writeSingle(-24.75);
	bstream:writeDouble(32)
	bstream:writeDouble(4.0007)
	bstream:writeDouble(-400.654)

	-- rewind the stream
	mstream:seek(0)

	-- Verify values
	print("16.5", bstream:readSingle());
	print("24.709", bstream:readSingle());
	print("-24.75", bstream:readSingle());
	print("32", bstream:readDouble());
	print("4.0007", bstream:readDouble());
	print("-400.654", bstream:readDouble());

	print("PASS");
end

test_IntValues();
test_FloatValues();
