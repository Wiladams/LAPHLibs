local ffi = require "ffi"
local C = ffi.C

local bit = require "bit"
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift

local memutils = require "laphlibs.memutils"
local maths = require("maths")



local Vector = {}
local Vector_mt = {
	__index = Vector,
}
			
function Vector.new(elemtype, capacity)

	capacity = capacity or 0

	local obj = {
		ElementType = ffi.typeof(elemtype),
		n = 0,
		Capacity = capacity,
		Data = nil,
	}
	setmetatable(obj, Vector_mt);
	
	return obj
end

function Vector:Free()
	if self.Data ~= nil then
		ffi.C.free(self.Data);
	end
end

-- Maximumm number of elements
function Vector.Max(self)
	return self.Capacity;
end

-- Current number of elements in vector
function Vector.Size(self)
	return self.n;
end

function Vector.Realloc(self, nelems)
	if nelems == 0 then
		if self.Data ~= nil then
			ffi.C.free(self.Data)
			self.Data = nil
		end
		return nil
	end
	
	local newdata = ffi.C.malloc(ffi.sizeof(self.ElementType)* nelems);

	-- copy existing over to new one
	local maxCopy = math.min(nelems, self.n);
	ffi.copy(newdata, ffi.cast("const uint8_t *",self.Data), ffi.sizeof(self.ElementType) * maxCopy);
	local typeptr = ffi.typeof("$ *", self.ElementType);
	--print("Type PTR: ", typeptr);
	
	-- free old data
	ffi.C.free(self.Data);
	
	self.Data = ffi.cast(typeptr,newdata);	
end

-- access an element
-- perform bounds checking and resizing
function Vector.a(v, i) 
	if v.Capacity <= i then						
		v.Capacity = i + 1; 
		v.n = i + 1;
		v.Capacity = maths.roundup(v.Capacity) 
		self:Realloc(v.Capacity) 
	else
		if v.n <= i then 
			v.n = i			
		end
	end
			
	return v.Data[i]
end	  

-- Access without bounds checking
function Vector.Elements(self)
	local index = -1;
	
	local clojure = function()
		index = index + 1;
		if index < self.n then
			return self.Data[index];
		end
		return nil
	end
	
	return clojure
end

function Vector.A(self, i)
	return self.Data[i];
end

function Vector.Resize(self, s) 
	self.Capacity = s; 
	self:Realloc(self.Data, self.Capacity)
end
		
function Vector.Copy(self, v0)
	-- If we're too small, then increase
	-- size to match
	if (self.Capacity < v0.n) then
		self:Resize(v0.n);
	end
			
	self.n = v0.n;									
	ffi.copy(self.Data, v0.Data, ffi.sizeof(self.Data[0]) * v0.n);		
end
		
-- pop, without bounds checking
function Vector.Pop(self)
	self.n = self.n-1;
	return self.Data[self.n]
end

function Vector.Push(v, x) 
	if (v.n == v.Capacity) then	
		if v.Capacity > 0 then
			v.Capacity = lshift(v.Capacity, 1)
		else
			v.Capacity = 2;
		end
		v:Realloc(v.Capacity);
	end															
			
	v.Data[v.n] = x;
	v.n = v.n + 1;
end
		
function Vector.Pushp(v) 
	if (v.n == v.Capacity) then
		if v.Capacity > 0 then
			v.Capacity = lshift(v.Capacity, 1)
		else
			v.Capacity = 2
		end
		v:Realloc(v.Capacity)	
	end
				
	v.n = v.n + 1
	return v.Data + v.n-1
end

return Vector;

