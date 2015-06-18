package.path = package.path..";../?.lua";

local utf8 = require "utf"

local function test_decode()
	print("==== test_decode ====")

	local utf8string = "Here is the string to be tested";

	for codepoint, err in utf8.utf8_iterator(utf8string) do
		io.write(string.char(codepoint))
	end
	io.write('\n');
end

local function test_utf8len()
	print("==== test_utf8len ====")

	local utf8string = "Here is the string to be tested";
	local len = utf8.utf8_strlen(utf8string);
	print("Length: ", #utf8string, len);
	
end

local function test_utf16()
	print("==== test_utf16 ====")

	local codepoint = 0x12ffff

	print(string.format("Codepoint BEGIN: 0x%X", codepoint))

	local w1, w2 = utf8.codepoint_to_utf16(codepoint)
	print(string.format("W1, W2: 0x%X, 0x%X", w1, w2))

	local codepoint2 = utf8.utf16_to_codepoint(w1, w2)
	print(string.format("Codepoint END: 0x%X", codepoint2))
end


test_decode();
test_utf8len();
test_utf16();