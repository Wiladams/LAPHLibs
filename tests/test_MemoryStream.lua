package.path = package.path..";..\\?.lua";

MemoryStream = require "MemoryStream"
local stream = require "stream"

function printStreamState(stream)
	print(stream:GetLength())
	print(stream:GetPosition())
end

function test_ReadStream()
	local rstream = MemoryStream.new(1024)
	printStreamState(rstream);

	rstream:Seek(0, stream.SEEK_END)
	printStreamState(rstream);
end


function test_WriteReadStream()
	local stream = MemoryStream.new(15)

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
end

test_ReadStream();

--test_WriteReadStream();
