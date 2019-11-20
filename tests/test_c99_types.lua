package.path = package.path..";../?.lua";

local ffi = require ("ffi")
local S = ffi.sizeof

local c99 = require ("laphlibs.c99_types")


local function printVector(v, n)
	for i=1,n do
		io.write(v[i-1])
		if i<n then
			io.write(', ')
		else
			io.write('\n')
		end
	end
end


local function test_double()
	print("==== test_double ====")
	local d0 = ffi.new("double[20]")
	print("D0 type: ", ffi.typeof(d0))

	local d1 = c99.doublev(20)

	print(S(d1))
	print(type(d1[0]))
end

local function test_float()
	print("==== test_float ====")
	local f1 = c99.floatv(20)
	print("f1 size: ", S(f1))
	print("f1 type: ", S(f1))

	-- Allocate anew based on the first array
	f2 = ffi.typeof(f1)(40)
	print(S(f2))
end

local function float2(x,y)
	return c99.floatv(2,x,y)
end

local function float3(x,y,z)
	return c99.floatv(3, x, y, z)
end

local function float4(x,y,z,w) 
	return c99.floatv(4, x, y, z, w)
end

local float5 = c99.floatv(5)


local function test_vector()
	print("==== test_vector ====")
	
	local v2 = float2(10,20)
	printVector(v2, 2)

	local v3 = float3(1,2,3)
	printVector(v3,3);

	local v4 = float4(10,20,30,1)
	printVector(v4, 4);


	print("typeof(float5): ", ffi.typeof(float5))
	local v5 = c99.floatv(5,{1,2,3,4,5})
	printVector(v5, 5);
end

local function test_point()
	print("==== test_point ====")

ffi.cdef[[
	typedef struct {
		float x,y,z,w;
	} Point3H, *PPoint3H;
]]
	local Point3H = ffi.typeof("Point3H");
	local PPoint3H = ffi.typeof("PPoint3H")
	print(type(Point3H), ffi.typeof(Point3H))

	local Point3D_mt = {
		__len = function(self) return 3 end,

		__tostring = function(self) return string.format("%3.4f, %3.4f, %3.4f", self.x, self.y, self.z) end,

		__index = {
			AsArray = function(self)
			return ffi.cast("float *", self)
		end,
	}
	}

	local Point3H = ffi.metatype(Point3H, Point3D_mt)

	print("Point3H Meta: ", Point3H)
	local p1 = ffi.cast(PPoint3H, v4)
	print("P1 Len: ", #p1)

	print("P1 Value: ", p1)

	printVector(p1:AsArray(), 4)
end

test_double()
test_float()
test_vector()
test_point()
