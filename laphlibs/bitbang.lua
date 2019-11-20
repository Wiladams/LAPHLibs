local ffi = require "ffi"

local bit = require "bit"
local band, bor = bit.band, bit.bor
local bxor = bit.bxor
local bnot = bit.bnot
local lshift, rshift = bit.lshift, bit.rshift

local uint64 = ffi.typeof("uint64_t")

--[[
	BIT

	Return pow(2,bitnum)
]]

local function BIT(bitnum)
	return 2^bitnum
end

--[[
	Set to '1' all the bits between lowbit and highbit
	inclusive.

	This will work for any number of bits from 32 to 63
	and returns a uint64_t
--]]
local function BITMASK(lowbit, highbit)
	local mask = 0ULL
	for i=lowbit, highbit do
		mask = bor(mask, 2ULL^i)
	end

	return mask 
end

--[[
	Return a bitmask, limited to 32-bit 
]]
local function BITMASK32(lowbit, highbit)
	-- create a mask which matches the desired range
	-- of bits
	local bitcount = highbit-lowbit+1

	local mask = 0xffffffff
	mask = lshift(mask, bitcount)
	mask = bnot(mask)
	mask = lshift(mask, lowbit)

	return mask
end

--[[
	BISTVALUE

	Return the integer value of a range of bits
]]
local function BITSVALUE(src, lowbit, highbit)
	--print("BITSVALUE: ", src, lowbit, highbit)
	lowbit = lowbit or 0
	highbit = highbit or 0

	local val = rshift(band(src, BITMASK(lowbit, highbit)), lowbit)

	--print("val: ", val)

	return val
end

local function getbitsvalue(src, lowbit, bitcount)
	return BITSVALUE(src, lowbit, lowbit+bitcount-1)
end




-- Individual bit manipulations
-- Check to see if a particular bit is set
local function isset(value, bit)
	return band(value, 2^bit) > 0
end

-- set a particular bit in a value
local function setbit(value, bit)
	return bor(value, 2^bit)
end

-- clear a single bit in a value
local function clearbit(value, bit)
	return band(value, bnot(2^bit))
end



local function numbertobinary(value, nbits, bigendian)
	nbits = nbits or 32
	local res={}

	if bigendian then
		for i=nbits-1,0,-1 do
			if isset(value,i) then
				table.insert(res, '1')
			else
				table.insert(res, '0')
			end
		end
	else
		for i=0, nbits-1 do
			if isset(value,i) then
				table.insert(res, '1')
			else
				table.insert(res, '0')
			end
		end
	end

	return table.concat(res)
end



local function binarytonumber(str, bigendian)
	local len = string.len(str)
	local value = 0

	if bigendian then
		for i=0,len-1 do
			if str:sub(len-i,len-i) == '1' then
				value = setbit(value, i)
			end
		end
	else
		for i=0, len-1 do
			if str:sub(i+1,i+1) == '1' then
				value = setbit(value, i)
			end
		end
	end

	return value
end

local function bytestobinary(bytes, length, offset, bigendian)
	offset = offset or 0
	nbits = 8

	local res={}

	if bigendian then
		for offset=length-1, 0,-1 do
			table.insert(res, numbertobinary(bytes[offset],nbits, bigendian))
		end

	else
		for offset=0,length-1 do
			table.insert(res, numbertobinary(bytes[offset],nbits, bigendian))
		end
	end

	return table.concat(res)
end



local function getbitstring(value, lowbit, bitcount)
	return numbertobinary(getbitsvalue(value, lowbit, bitcount))
end

-- Given a bit number, calculate which byte
-- it would be in, and which bit within that
-- byte.
local function getbitbyteoffset(bitnumber)
	local byteoffset = math.floor(bitnumber /8)
	local bitoffset = bitnumber % 8

	return byteoffset, bitoffset
end


local function getbitsfrombytes(bytes, startbit, bitcount)
	if not bytes then return nil end

	local value = 0

	for i=1,bitcount do
		local byteoffset, bitoffset = getbitbyteoffset(startbit+i-1)
		local bitval = isset(bytes[byteoffset], bitoffset)
--print(byteoffset, bitoffset, bitval);
		if bitval then
			value = setbit(value, i-1);
		end
	end

	return value
end

local function setbitstobytes(bytes, startbit, bitcount, value, bigendian)

	local byteoffset=0;
	local bitoffset=0;
	local bitval = false

	if bigendian then
		for i=0,bitcount-1 do
			byteoffset, bitoffset = getbitbyteoffset(startbit+i)
			bitval = isset(value, i)
			if bitval then
				bytes[byteoffset] = setbit(bytes[byteoffset], bitoffset);
			end
		end
	else
		for i=0,bitcount-1 do
			byteoffset, bitoffset = getbitbyteoffset(startbit+i)
			bitval = isset(value, i)
			if bitval then
				bytes[byteoffset] = setbit(bytes[byteoffset], bitoffset);
			end
		end
	end

	return bytes
end



local function extractbits64(src, lowbit, bitcount)
	-- create a mask which matches the desired range
	-- of bits
	local mask = 0xffffffffffffffffULL
	mask = lshift(mask, bitcount)
	mask = bnot(mask)
	mask = lshift(mask, lowbit)

	-- use the mask, and a shift to get the desired
	-- value
	local value = rshift(band(mask, src), lowbit)
	return value;
end

local function setbits32(dst, lowbit, bitcount, value)
	-- make a whole where the value will be
	local mask = 0xffffffff
	mask = lshift(mask, bitcount)
	mask = bnot(mask)

	-- while we're at it, ensure the value fits
	-- within the bitcount
	value = band(mask, value)

	-- shift the whole, and flip it back
	-- to zeros everywhere but the hole
	mask = lshift(mask, lowbit)
	mask = bnot(mask)

	local newvalue = band(dst, mask)


	-- now take the value, and shift it by the lowbit
	value = lshift(value, lowbit)

	-- finally, stick it in the destination
	dst = bor(newvalue, value)

	return dst
end

local function setbits64(dst, lowbit, bitcount, value)
	-- make a whole where the value will be
	local mask = 0xffffffffffffffffULL
	mask = lshift(mask, bitcount)
	mask = bnot(mask)

	-- while we're at it, ensure the value fits
	-- within the bitcount
	value = band(mask, value)

	-- shift the whole, and flip it back
	-- to zeros everywhere but the hole
	mask = lshift(mask, lowbit)
	mask = bnot(mask)

	local newvalue = band(dst, mask)


	-- now take the value, and shift it by the lowbit
	value = lshift(value, lowbit)

	-- finally, stick it in the destination
	dst = bor(newvalue, value)

	return dst
end

local exports = {
	BIT = BIT;
	BITMASK = BITMASK;
	BITMASK32 = BITMASK32;
	BITSVALUE = BITSVALUE;

	isset = isset;
	setbit = setbit;
	clearbit = clearbit;

	numbertobinary = numbertobinary;
	binarytonumber = binarytonumber;
	bytestobinary = bytestobinary;
	getbitsvalue = getbitsvalue;
	getbitstring = getbitstring;
	getbitbyteoffset = getbitbyteoffset;
	getbitsfrombytes = getbitsfrombytes;
	setbitstobytes = setbitstobytes;

	extractbits32 = getbitsvalue;
	extractbits64 = extractbits64;

	setbits32 = setbits32;
	setbits64 = setbits64;
}

return exports
