package.path = package.path..";../?.lua";

local utf8 = require "utf"

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

function test_utf16()
local codepoint = 0x12ffff

print(string.format("Codepoint BEGIN: 0x%X", codepoint))

local w1, w2 = codepoint_to_utf16(codepoint)
print(string.format("W1, W2: 0x%X, 0x%X", w1, w2))

local codpoint2 = utf16_to_codepoint(w1, w2)
print(string.format("Codepoint END: 0x%X", codepoint))
end


test_decode();
test_utf8len();
