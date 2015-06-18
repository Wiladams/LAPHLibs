package.path = package.path..";../?.lua";

local MemoryStream = require "memorystream"
local Stream = require "stream"

function printStreamState(stream)
	print(stream:length())
	print(stream:position())
end

function test_ReadStream()
	local rstream = MemoryStream(1024)
	printStreamState(rstream);

	rstream:seek(0, Stream.SEEK_END)
	printStreamState(rstream);
end


function test_WriteReadStream()
	print("==== test_WriteReadStream ====")
	local stream = MemoryStream(15)
	local str = "William A ";
	print("-- Space Remaining: ", stream:remaining())
	print(string.format("Writing: '%s' [%d]", str, #str));
	local written = stream:writeString(str)
	print("-- Bytes Written: ", written);

	print("-- Space Remaining: ", stream:remaining())
	print(string.format("Writing: '%s' [%d]", str, #str));
	written = stream:writeString(str)
	print("-- Bytes Written: ", written);

	stream:seek(0);

	print("-- Chars in Stream")
	local c=stream:readByte()
	while (c and c ~= 0) do
		print(string.char(c))
		c=stream:readByte()
	end

	print("-- seek(1), readString(6)")
	stream:seek(1)
	io.write("'",stream:readString(6),"'\n")
end


function test_ReadWrite()
	print("==== test_ReadWrite ====")
	local mstream1 = MemoryStream(8192)
	local mstream2 = MemoryStream(8192)

	-- write something into first memory stream
	local tst_string = "Hello There"

	mstream1:writeString(tst_string)
	mstream1:copyTo(mstream2);

	mstream2:seek(0)

	local str = mstream2:readString(#tst_string)

	print(str)

	mstream2:writeString("String One,");
	mstream2:writeString("String Two,");
	mstream2:writeString("String Three");

	print(mstream2:toString())
end

function test_ReadOnly()
	print("==== test_ReadOnly ====")
	
local str = [[
This is the first line
And the second and third combined
Followed by the fourth

Fifth
And finally the sixth.
]]

	local mstream = MemoryStream(str, #str)

	repeat
		local line, err = mstream:readLine()
		print(string.format("LINE:'%s'", tostring(line)), err);
	until err == "eof"
end


function test_ReadLine()
	local mstream = MemoryStream:create(1024)

	mstream:WriteString("This is the first line\r\n")
	mstream:WriteString("And the second")
	mstream:WriteString(" and third combined\r\n")
	mstream:WriteString("Followed by the fourth")
	mstream:WriteString("\r\n");
	mstream:WriteString("Fifth\n");
	mstream:WriteString("And finally the sixth.");

	mstream:Seek(0)

	repeat
		local line, err = mstream:readLine()
		print(string.format("LINE:'%s'", tostring(line)), err);
	until err == "eof"
end

function test_Byte_Iterator()
	local mstream = MemoryStream:create();

	mstream:WriteString("This is the first line\r\n")
	mstream:WriteString("And the second")
	mstream:WriteString(" and third combined\r\n")
	mstream:WriteString("Followed by the fourth")
	mstream:WriteString("\r\n");
	mstream:WriteString("Fifth\n");
	mstream:WriteString("And finally the sixth.");

	for abyte in mstream:bytes() do
		io.write(string.char(abyte))
	end

	-- Iterate the first 4 bytes
	for abyte in mstream:bytes(4) do
		io.write(string.char(abyte))
	end
end

--test_ReadLine();
--test_Byte_Iterator();
test_ReadOnly();
test_ReadWrite();



test_ReadStream();

test_WriteReadStream();
