package.path = package.path..";../?.lua";

local FileStream = require "FileStream"

local tst_filename = "data/tmp_filestream.bin";

function cleanupTests()
	os.remove(tst_filename);
end


function test_ReadStream()
	local rstream = FileStream.Open(tst_filename)
	--printStreamState(rstream);

	rstream:Seek(0, SEEK_END)
	--printStreamState(rstream);
end


function test_WriteReadStream()
	local stream = FileStream.Open(tst_filename)

	if not stream then
		print("Could not open stream");
		print("FAILED");
		return;
	end

	local written = stream:WriteString("William A ")
	print("Written: ", written);
	written = stream:WriteString("William A ")
	print("Written: ", written);

	stream:Seek(0);

	local c=stream:ReadByte()
	while (c and c ~= 0) do
		print(string.char(c))
		c=stream:ReadByte()
	end

	stream:Seek(1)
	io.write("'",stream:ReadString(6),"'\n")

	print("Length: ", stream:Seek(0, stream.SEEK_END));
end

cleanupTests();
--test_ReadStream();

test_WriteReadStream();
