package.path = package.path..";..\\?.lua";

local ffi = require "ffi"
local mutils = require "memutils"
require "stringzutils"

local str1 = strdup("william")
local str2 = strdup("will")

function printString(str)
	print(ffi.string(str));
end

function test_strcmp()
	printString(str1);
	printString(str2);

	print("0 : ", strcmp(str1, str1))
	print("1 : ", strcmp(str1, str2))
	print("-1 : ", strcmp(str2, str1))
end



function test_array_size()
	local arr = ffi.new("char[255]")
	print(ffi.sizeof(arr))

	local str = strdup("William")
	print("str: ", ffi.sizeof(str))

	local typestr = tostring(ffi.typeof(str))
	--print("match: ", typestr, string.match(typestr, "ctype<%w [%d+]>"))
	print("match: ", string.match(typestr, "ctype<(%w+)%s+%[(%d+)%]>"))

	local arr2 = ffi.new("int[256][10]")
	typestr = tostring(ffi.typeof(arr2))
	print("match: ", string.match(typestr, "ctype<(%w+)%s+%[(%d+)%]>"))

	print("Array Size: ", ARRAY_SIZE(arr2));
--print("ARRAY_SIZE: ", ARRAY_SIZE(str1));
end

function test_strchr()
	local str = strdup("William");

	local chr1 = strchr(str, string.byte('l'))
	local chrnon = strchr(str, string.byte('c'))

	print(charnon);
	print(ffi.string(chr1))
end

function test_strstr()
	local str = strdup("William");
	local tar = strdup("ll");
	local tar2 = strdup("cars");

	local pos = strstr(str, tar)
	print(ffi.string(pos));

	pos = strstr(str, tar2)
	print(pos);

end

function test_bin2str()
	local p = strdup("William A Adams");
	local to = ffi.new("char[256]");
	local len = strlen(p);

	bin2str(to, p, len)
	local str = ffi.string(to)

	print("str: ", str);
end

test_strcmp();

test_array_size();

test_strchr();

test_strstr();

test_bin2str();
