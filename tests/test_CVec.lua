package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

local CVec = require "cvec"
local Vector = require "Vector"

function test_intvec()
	ivec = CVec.NewKind(ffi.typeof("int"));

	local ivec1 = ivec();
	print("Max: ", ivec1:Max());
	print("Size: ", ivec1:Size());
	print("Data: ", ivec1.Data);
	
	ivec1:Push(5);
--[[
	ivec1:Push(10);
	ivec1:Push(13);
	ivec1:Push(22);
	ivec1:Push(27);

	last = ivec1:Size()
	
	for i=0,last-1 do
		print(ivec1:A(i));
	end
--]]
--for  ivec1:Size() > 0 do
--	print(ivec1:Pop());
--end

end

function test_pointvec()
	local point3 = ffi.typeof("struct {float x; float y; float z;}");
	local Point3Vector = CVec.NewKind(point3);
	
	local vertices = Point3Vector();
	
	for i=1,10000 do
		vertices:Push(point3(i,i*2, i*3));
	end
end



function test_vec()
	local ct = ffi.typeof("struct {float x; float y; float z;}");

	local Vector = ffi.typeof("struct { int n; int Capacity; $ *Data; }", ct);
	
print("tp: ", ffi.typeof(Vector));

	local iarray = Vector(0,0,nil);
print("iarray: ", ffi.typeof(iarray), iarray.Data, ffi.typeof(iarray.Data));
print("Size of Element: ", ffi.sizeof(iarray.Data[0]));
print("N: ", iarray.n);
print("Capacity: ", iarray.Capacity);
	--iarray:Push(1);
end



function test_call()
	local factory = {}
	local factory_mt = {
		__call = function(...)
			print("factory __call");
		end,
		
		__index = factory,
		}
	
	factory.new = function(ct)
		local obj = {
			Type = ct,
			}
			
		setmetatable(obj, factory_mt);
		
		return obj;
	end
	
	local fact1 = factory.new("int");
	fact1();
end

function test_factory()

	local ivec = CVec.NewKind("int");
	local indices = ivec();
	
end

--test_factory();
--test_call();
--test_intvec();

--test_pointvec();
--test_vec();

