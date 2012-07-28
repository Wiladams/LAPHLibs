package.path = package.path..";..\\?.lua";

local MemoryStream = require "MemoryStream"
local Stream = require "Stream"

function printStreamState(stream)
	print(stream:GetLength())
	print(stream:GetPosition())
end

function test_ReadStream()
	local rstream = MemoryStream.new(1024)
	printStreamState(rstream);

	rstream:Seek(0, Stream.SEEK_END)
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


function test_ReadWrite()
	local mstream1 = MemoryStream.new()
	local mstream2 = MemoryStream.new()

-- write something into first memory stream
local tst_string = "Hello There"

mstream1:WriteString(tst_string)
mstream1:CopyTo(mstream2);

mstream2:Seek(0)

local str = mstream2:ReadString(#tst_string)

print(str)

mstream2:WriteString("String One,");
mstream2:WriteString("String Two,");
mstream2:WriteString("String Three");

print(mstream2:ToString())
end

function test_ReadOnly()
local str = [[
This is the first line
And the second and third combined
Followed by the fourth

Fifth
And finally the sixth.
]]

	local mstream = MemoryStream.Open(str, #str, #str)

	repeat
		local line, err = mstream:ReadLine()
		print(string.format("LINE:'%s'", tostring(line)), err);
	until err == "eof"
end


function test_ReadLine()
	local mstream = MemoryStream.new(1024)

	mstream:WriteString("This is the first line\r\n")
	mstream:WriteString("And the second")
	mstream:WriteString(" and third combined\r\n")
	mstream:WriteString("Followed by the fourth")
	mstream:WriteString("\r\n");
	mstream:WriteString("Fifth\n");
	mstream:WriteString("And finally the sixth.");

	mstream:Seek(0)

	repeat
		local line, err = mstream:ReadLine()
		print(string.format("LINE:'%s'", tostring(line)), err);
	until err == "eof"
end

function test_Byte_Iterator()
	local mstream = MemoryStream.new();

	mstream:WriteString("This is the first line\r\n")
	mstream:WriteString("And the second")
	mstream:WriteString(" and third combined\r\n")
	mstream:WriteString("Followed by the fourth")
	mstream:WriteString("\r\n");
	mstream:WriteString("Fifth\n");
	mstream:WriteString("And finally the sixth.");

	for abyte in mstream:Bytes() do
		io.write(string.char(abyte))
	end

	-- Iterate the first 4 bytes
	for abyte in mstream:Bytes(4) do
		io.write(string.char(abyte))
	end
end

--test_ReadLine();
--test_Byte_Iterator();
test_ReadOnly();



test_ReadStream();

--test_WriteReadStream();
