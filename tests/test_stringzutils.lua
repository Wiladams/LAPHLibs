package.path = package.path..";..\\?.lua";

local ffi = require "ffi"
local mutils = require "memutils"
local strutils = require "stringzutils"


function test_strdup()
	local input1 = "hello1"
	local hello1 = strutils.strdup(input1)
	print(hello1)
end

test_strdup();
