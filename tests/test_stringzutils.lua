package.path = package.path..";..\\?.lua";

local ffi = require "ffi"
local mutils = require "memutils"
local strutils = require "stringzutils"


function test_strdup()
	local hello1 = strdup("hello1")
	print(hello1)
end

test_strdup();
