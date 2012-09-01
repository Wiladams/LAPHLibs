package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

local CVec = require "CVec"

ivec = CVec.NewKind(ffi.typeof("int"));

local ivec1 = ivec();
ivec1:Push(5);
ivec1:Push(10);
ivec1:Push(13);
ivec1:Push(22);
ivec1:Push(27);

last = ivec1:Size()
for i=0,last-1 do
	print(ivec1:A(i));
end

--for  ivec1:Size() > 0 do
--	print(ivec1:Pop());
--end

print("Max: ", ivec1:Max());
print("Size: ", ivec1:Size());

--[[

print(kv_roundup32(1));
print(kv_roundup32(2));
print(kv_roundup32(3));
print(kv_roundup32(5));
print(kv_roundup32(7));
print(kv_roundup32(9));
print(kv_roundup32(13));
print(kv_roundup32(15));
print(kv_roundup32(17));
print(kv_roundup32(23));
print(kv_roundup32(33));
--]]
