package.path = package.path..";..\\?.lua";

local ctype = require "cctype"

ffi = require "ffi"

function test_toupper()
	print("==== test_toupper ====")
	print('a', string.char(ctype.toupper(string.byte('a'))))
end

function test_isspace ()
	print("==== test_isspace ====")
  local c;
  local i=0;
  local str = ffi.cast("char *", "Example \vsentence\t to test isspace\n");

	while (str[i] ~= 0) do
		c = str[i];
		if (ctype.isspace(c)) then
			c = string.byte('\n');
		end

		io.write(string.char(c));
		i = i + 1;
	end

	return 0;
end

function test_isalpha()
	print("==== test_isalpha ====")
	assert(ctype.isalpha(string.byte('a')))
	assert(ctype.isalpha(string.byte('z')))
	assert(ctype.isalpha(string.byte('A')))
	assert(ctype.isalpha(string.byte('Z')))
	assert(not ctype.isalpha(string.byte('!')))
	assert(not ctype.isalpha(string.byte('=')))
	assert(not ctype.isalpha(string.byte('{')))

end

test_isalpha();
test_isspace();
test_toupper();

print("PASS")
