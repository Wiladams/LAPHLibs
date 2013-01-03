local ffi = require ("ffi")

ffi.cdef[[
typedef int v4si __attribute__((vector_size(16)));
]]
v4si = ffi.typeof("v4si")
v4si_mt = {
	__tostring = function(self)
		return string.format("%d, %d, %d, %d", self[0], self[1], self[2], self[3]);
	end,

	__add = function(self, other)
		if type(other) == "number" then
			return v4si(self[0]+other, self[1]+other, self[2]+other, self[3]+other);
		end
			return v4si(self[0]+other[0], self[1]+other[1], self[2]+other[2], self[3]+other[3]);		
	end,

	__sub = function(self, other)
		return v4si(self[0]-other[0], self[1]-other[1], self[2]-other[2], self[3]-other[3]);
	end,
}
v4si = ffi.metatype(v4si, v4si_mt)

a = v4si(10,20,30)
b = v4si(1,1,1,1)
c = v4si(a);
c[2] = 150;

print("a: ", a)
print("b: ", b)
print("c: ", c);

print("a + b: ", a + b)
print("a - b: ", a - b)
print("a + 5: ", a + 5)
