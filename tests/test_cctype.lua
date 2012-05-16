package.path = package.path..";..\\?.lua";

require "cctype"

ffi = require "ffi"

function test_isspace ()

  local c;
  local i=0;
  local str = ffi.cast("char *", "Example sentence to test isspace\n");

	while (str[i] ~= 0) do
		c = str[i];
		if (isspace(c)) then
			c = string.byte('\n');
		end

		io.write(string.char(c));
		i = i + 1;
	end

	return 0;
end

test_isspace();
