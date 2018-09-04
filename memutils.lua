--[[
	memmutils

	A set of functions that are typically found in old C libraries.
	The typical 'C' versions aren't typically utilized because of issues
	of safety, typically running off the end of an array and such.

	these versions do not offer much safety either.  They exist purely to make
	it easier to port code that is coming from 'C', and they are almost
	a drop in replacement for the classics.
--]]

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift


--[[
	You should be able to get at these (malloc, free, realloc)
	simply by using: ffi.C.malloc, etc 
	from anywhere, as they should already be compiled in, 
	and accessible, to your lua runtime
]]
ffi.cdef[[
void * malloc ( size_t size );
void free ( void * ptr );
void * realloc ( void * ptr, size_t size );
]]


--[[
	These various routines provide no safety, just like
	their 'C' counterparts from which they are derived.

	There is a temptation to provide some amount of safety
	by checking null values, and ranges and whatnot, but 
	if you do that, you'll silently swallow problems.
	Better to let the call fail, then you can figure out
	the source of the failure more easily.
]]
local function bzero(dest, nbytes)
	ffi.fill(dest, nbytes)
	return dest
end

local function bcopy(src, dest, nbytes)
	ffi.copy(dest, src, nbytes)
end

local function bcmp(ptr1, ptr2, nbytes)
	for i=0,nbytes do
		if ptr1[i] ~= ptr2[i] then return -1 end
	end

	return 0
end

local function memset(dest, c, len)
	ffi.fill(dest, len, c)
	return dest
end

local function memcpy(dest, src, nbytes)
	ffi.copy(dest, src, nbytes)
end

local function memcmp(ptr1, ptr2, nbytes)
	local p1 = ffi.cast("const uint8_t *", ptr1)
	local p2 = ffi.cast("const uint8_t *", ptr2)

	for i=0,nbytes do
		if p1[i] ~= p2[i] then return -1 end
	end

	return 0
end

local function memchr(ptr, value, num)
	local p = ffi.cast("const uint8_t *", ptr)
	for i=0,num-1 do
		if p[i] == value then return p+i end
	end

	return nil
end

--[[
	memmove

	Do a copy of memory from one location to another.
	The specific benefit of memmove is it can handle
	overlapping source and destination.
]]
local function memmove(dst, src, num)
	local srcptr = ffi.cast("const uint8_t*", src)

	-- If equal, just return
	if dst == srcptr then return dst end


	if srcptr < dst then
		-- copy from end
		for i=num-1,0, -1 do
			dst[i] = srcptr[i];
		end
	else
		-- copy from beginning
		for i=0,num-1 do
			dst[i] = srcptr[i];
		end
	end
	return dst
end

local function memreverse(buff, bufflen)
	local i = 0;
	local tmp

	while (i < (bufflen)/2) do
		tmp = buff[i];
		buff[i] = buff[bufflen-i-1];
		buff[bufflen-i-1] = tmp;

		i = i + 1;
	end
	return buff
end

--[[
	getreverse

	return a copy of the 'src' data, in reverse order

	src - something that can be cast as const uint8_t *
	len - the length of 'src'
]]
local function getreverse(src, len)
	if not len then
		if type(src) == "string" then
			len = #src
		else
			return nil, "unknown length"
		end
	end

	local srcptr = ffi.cast("const uint8_t *", src);
	local dst = ffi.new("uint8_t[?]", len)

	for i = 0, len-1 do
		dst[i] = srcptr[len-1-i];
	end

	return dst, len
end

return {
	bcmp = bcmp,
	bcopy = bcopy,
	bzero = bzero,


	memset = memset,
	memcpy = memcpy,
	memcmp = memcmp,

	memchr = memchr,
	memmove = memmove,

	memreverse = memreverse,
	getreverse = getreverse,
}
