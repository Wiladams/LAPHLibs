package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

require "strtoul"

function main()
	local str1 = ffi.cast("char *", "12345")
	local str2 = ffi.cast("char *", "-5000")

	local v = strtol(str1, nil, 10);
	print(v);

	v = strtol(str2, nil, 10);
	print(v);

end

main()
