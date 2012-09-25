local bit = require "bit"
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift
local ffi = require "ffi"
local C = ffi.C

--[=[
ffi.cdef[[
void * malloc ( size_t size );
void free ( void * ptr );
void * realloc ( void * ptr, size_t size );
]]
--]=]

-- given a pointer
-- tell what kind of element it points to
local function pointerinfo(ptr)
	local typestr = tostring(ffi.typeof(ptr))
print("PointerInfo: ", typestr);
	local elemtype = string.match(typestr, "ctype<(%w+)%s+")

	return elemtype
end

-- reallocate a chunk of memory
local function Realloc(ptr, size)
	local ptrtype = pointerinfo(ptr);
print("Realloc: ", ptrtype);
	local newPtr = ffi.C.realloc(ptr, ffi.sizeof(ptrtype) * size)
	return newPtr;
end


-- round up to the nearest
-- power of 2
local function kv_roundup32(x)
	x = x - 1;
	x = bor(x,rshift(x,1));
	x = bor(x,rshift(x,2));
	x = bor(x,rshift(x,4));
	x = bor(x,rshift(x,8));
	x = bor(x,rshift(x,16));
	x = x + 1;

	return x
end

local kvec_mt = {
	__new = function(ct, capacity)
		capacity = capacity or 1
		local obj = ffi.new(ct, 0, capacity, capacity)

		print("__new typeof Data: ", ffi.typeof(obj.Data[0]));

		return obj;
	end,

	__gc = function(self)
		--self.Data = nil;
	end,

	__index = {
		-- Maximumm number of elements
		Max = function(self)
			return self.Capacity;
		end,

		-- Current number of elements in vector
		Size = function(self)
			return self.n;
		end,

		Realloc = function(self, nelems)
			if nelems == 0 then
				self.Data = nil
				return nil
			end

			print("Realloc: ", ffi.typeof(self.Data));

			local newdata = ffi.new(self.Data[0], nelems);

			-- copy existing over to new one
			local maxCopy = math.min(nelems, self.n);
			ffi.copy(ffi.cast("uint8_t *", newdata), ffi.cast("const uint8_t *",self.Data), ffi.sizeof(self.Data[0]) * maxCopy);
			self.Data = newdata;
		end,

		-- access an element
		-- perform bounds checking and resizing
		a = function(v, i)
			if v.Capacity <= i then
				v.Capacity = i + 1;
				v.n = i + 1;
				v.Capacity = kv_roundup32(v.Capacity)
				v:Realloc(v.Capacity)
			else
				if v.n <= i then
					v.n = i
				end
			end

			return v.Data[i]
		end,

		-- Access without bounds checking
		A = function(self, i)
			return self.Data[i];
		end,


		Resize = function(self, size)
			self.Capacity = size;
			self:Realloc(self.Data, self.Capacity)
		end,

		Copy = function(self, v0)
			-- If we're too small, then increase
			-- size to match
			if (self.Capacity < v0.n) then
				self:Resize(v0.n);
			end

			self.n = v0.n;
			ffi.copy(ffi.cast("uint8_t *", v1.Data), ffi.cast("const uint8_t *", v0.Data), ffi.sizeof(self.Data[0]) * v0.n);
		end,

		-- pop, without bounds checking
		Pop = function(self)
			self.n = self.n-1;
			return self.Data[self.n]
		end,

		Push = function(self, x)
			if (self.n == self.Capacity) then
				if self.Capacity > 0 then
					self.Capacity = lshift(self.Capacity, 1)
				else
					self.Capacity = 2;
				end
				self:Realloc(self.Capacity);
			end

			self.Data[self.n] = x;
			self.n = self.n + 1;
		end,

		Pushp = function(self)
			if (self.n == self.Capacity) then
				if self.Capacity > 0 then
					self.Capacity = lshift(self.Capacity, 1)
				else
					self.Capacity = 2
				end
				self:Realloc(self.Capacity)
			end

			self.n = self.n + 1
			return self.Data + self.n-1
		end,
	},
}



local function MakeVectorFactory(ct)
	if type(ct) == "string" then
		ct = ffi.typeof(ct);
	end

	local tp = ffi.typeof("struct { int n; int Capacity; $ Data[?]; }", ct);
	tp = ffi.metatype(tp, kvec_mt);

	return tp;
end


return {
	--NewKind = VectorFactory.new,
	NewKind = MakeVectorFactory,
}
