local bit = require "bit"
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift
local ffi = require "ffi"
local C = ffi.C

ffi.cdef[[
void * malloc ( size_t size );
void free ( void * ptr );
void * realloc ( void * ptr, size_t size );
]]

-- given a pointer
-- tell what kind of element it points to
local function pointerinfo(ptr)
	local typestr = tostring(ffi.typeof(ptr))
	local elemtype = string.match(typestr, "ctype<(%w+)%s+")
	
	return elemtype
end

-- reallocate a chunk of memory
local function Realloc(ptr, size)
	local ptrtype = pointerinfo(ptr);
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
	__new = function(ct, max)
		return ffi.new(ct, 0,0,nil)
	end,
	
	__gc = function(self)
		ffi.C.free(self.Data);
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

		-- access an element
		-- perform bounds checking and resizing
		a = function(v, i) 
			if v.Capacity <= i then						
				v.Capacity = i + 1; 
				v.n = i + 1;
				v.Capacity = kv_roundup32(v.Capacity) 
				v.Data = Realloc(v.Data, v.Capacity) 
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
		
		
		Resize = function(self, s) 
			self.Capacity = s; 
			self.Data = Realloc(self.Data, self.Capacity)
		end,
		
		Copy = function(v1, v0)
			-- If we're too small, then increase
			-- size to match
			if (v1.Capacity < v0.n) then
				v1:Resize(v0.n);
			end
			
			v1.n = v0.n;									
			ffi.copy(v1.Data, v0.Data, ffi.sizeof(self.Data[0]) * v0.n);		
		end,
		
		-- pop, without bounds checking
		Pop = function(self)
			self.n = self.n-1;
			return self.Data[self.n]
		end,

		Push = function(v, x) 
			if (v.n == v.Capacity) then	
				if v.Capacity > 0 then
					v.Capacity = lshift(v.Capacity, 1)
				else
					v.Capacity = 2;
				end
				v.Data = Realloc(v.Data, v.Capacity);	
			end															
			
			v.Data[v.n] = x;
			v.n = v.n + 1;
		end,
		
		Pushp = function(v) 
			if (v.n == v.Capacity) then
				if v.Capacity > 0 then
					v.Capacity = lshift(v.Capacity, 1)
				else
					v.Capacity = 2
				end
				v.Data = Realloc(v.Data, v.Capacity)	
			end
				
			v.n = v.n + 1
			return v.Data + v.n-1
		end,
		
	},
}


local function makevec(ct)
	local tp = ffi.typeof("struct { int n, Capacity; $ *Data; }", ct);

	return ffi.metatype(tp, kvec_mt)
end


return {
	NewKind = makevec,
}
