local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift

--[[
	binary functions

	ARRAY_SIZE
	NewStruct
	isbyte
	bzero
	bcopy
	bcmp
--]]

function ARRAY_SIZE(array)
	local typestr = tostring(ffi.typeof(array))

	--local elemtype, nelem = string.match(typestr, "ctype<(%w+)%s+%[(%d+)%]>")
	local nelem = string.match(typestr, "(%d+)")

	return tonumber(nelem)
end


function NewStruct(structname)
	if not cast then return nil end

	local size = ffi.sizeof(structname)
	return ffi.cast(structname,ffi.new("uint8_t["..size.."]"));
end


function isbyte(n)
	return band(n,0xff) == n
end

function bzero(dest, nbytes)
	ffi.fill(dest, nbytes)
	return dest
end

function bcopy(src, dest, nbytes)
	ffi.copy(dest, src, nbytes)
end

function bcmp(ptr1, ptr2, nbytes)
	for i=0,nbytes do
		if ptr1[i] ~= ptr2[i] then return -1 end
	end

	return 0
end

--[[
	Memory functions

	memchr(const void *buf, int val, size_t maxCount);
	memcmp(const void *buf1, const void *buf2, size_t size);
	memcpy_s(void *dst, int dstSize, const void *src, size_t maxCount)
	memset(void * dst, int val, size_t size)
--]]

function memset(dest, c, len)
	ffi.fill(dest, len, c)
	return dest
end

function memcpy(dest, src, nbytes)
	ffi.copy(dest, src, nbytes)
end

function memcmp(ptr1, ptr2, nbytes)
	local p1 = ffi.cast("uint8_t *", ptr1)
	local p2 = ffi.cast("uint8_t *", ptr2)

	for i=0,nbytes do
		if p1[i] ~= p2[i] then return -1 end
	end

	return 0
end

function memchr(ptr, value, num)
	ptr = ffi.cast("uint8_t *", ptr)
	for i=0,num-1 do
		if ptr[i] == value then return ptr+i end
	end

	return nil
end

function memmove(dst, src, num)
	local srcptr = ffi.cast("uint8_t*", src)

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









