package.path = package.path..";..\\?.lua";

local utf8 = require "utf8"

function test_decode()
	local utf8string = "Here is the string to be tested";

	for codepoint, err in utf8.Iterator(utf8string) do
		io.write(string.char(codepoint))
	end
	io.write('\n');
end

function test_utf8len()
	local utf8string = "Here is the string to be tested";
	print("Length: ", utf8.StringLength(utf8string));
end

test_decode();
test_utf8len();
