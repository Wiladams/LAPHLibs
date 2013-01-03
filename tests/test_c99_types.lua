package.path = package.path..";../?.lua";

local ffi = require ("ffi")

c99 = require ("c99_types")

d0 = ffi.new("double[20]")
print("D0 type: ", ffi.typeof(d0))

d1 = c99.doublev(20)

print(ffi.sizeof(d1))
print(type(d1[0]))


f1 = c99.floatv(20)
print("f1 size: ", ffi.sizeof(f1))
print("f1 type: ", ffi.typeof(f1))

-- Allocate anew based on the first array
f2 = ffi.typeof(f1)(40)
print(ffi.sizeof(f2))


local float2 = function(x,y)
	return c99.floatv(2,x,y)
end

local float3 = function(x,y,z)
	--return floatv(3, x, y, z, w)
	--return ffi.typeof("$[?]", float)(3,x,y,z);
	return ffi.new("float[3]", x,y,z);
end

local float4 = function(x,y,z,w) 
	return c99.floatv(4, x, y, z, w)
end

local float5 = c99.floatv(5)

function printVector(v, n)
for i=1,n do
	io.write(v[i-1])
	if i<n then
		io.write(', ')
	else
		io.write('\n')
	end
end
end

v2 = float2(10,20)
printVector(v2, 2)

v3 = float3(1,2,3)
printVector(v3,3);

v4 = float4(10,20,30,1)

printVector(v4, 4);


print(ffi.typeof(float5))
--v5 = float5(5,1,2,3,4,5)
--printVector(v5, 5);


ffi.cdef[[
typedef struct {
	float x,y,z,w;
} Point3H, *PPoint3H;
]]
Point3H = ffi.typeof("Point3H");
PPoint3H = ffi.typeof("PPoint3H")
print(ffi.typeof(Point3H))


local Point3D_mt = {
	__len = function(self) return 3 end,

	__tostring = function(self) return string.format("%3.4f, %3.4f, %3.4f", self.x, self.y, self.z) end,

	__index = {
		AsArray = function(self)
			return ffi.cast("float *", self)
		end,
	}
}
Point3H = ffi.metatype(Point3H, Point3D_mt)

print("Point3H Meta: ", Point3H)
local p1 = ffi.cast(PPoint3H, v4)
print("P1 Len: ", #p1)

print("P1 Value: ", p1)

printVector(p1:AsArray(), 4)
