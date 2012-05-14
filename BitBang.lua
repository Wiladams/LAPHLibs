local ffi = require "ffi"

local bit = require "bit"
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local bnot = bit.bnot
local rshift = bit.rshift

ffi.cdef[[
typedef union  {
		uint8_t		Byte;
		int16_t 	Short;
		uint16_t	UShort;
		int32_t		Int32;
		uint32_t	UInt32;
		int64_t		Int64;
		uint64_t	UInt64;
		float 		f;
		double 		d;
		uint8_t bytes[8];
} bittypes_t
]]
bittypes = ffi.typeof("bittypes_t")

function isset(value, bit)
	return band(value, 2^bit) > 0
end

function setbit(value, bit)
	return bor(value, 2^bit)
end

function clearbit(value, bit)
	return band(value, bnot(2^bit))
end

function numbertobinary(value, nbits, bigendian)
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



function binarytonumber(str, bigendian)
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

function bytestobinary(bytes, length, offset, bigendian)
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

function getbitsvalue(src, lowbit, bitcount)
	lowbit = lowbit or 0
	bitcount = bitcount or 32

	local value = 0
	for i=0,bitcount-1 do
		value = bor(value, band(src, 2^(lowbit+i)))
	end

	return rshift(value,lowbit)
end

function getbitstring(value, lowbit, bitcount)
	return numbertobinary(getbitsvalue(value, lowbit, bitcount))
end

-- Given a bit number, calculate which byte
-- it would be in, and which bit within that
-- byte.
function getbitbyteoffset(bitnumber)
	local byteoffset = math.floor(bitnumber /8)
	local bitoffset = bitnumber % 8

	return byteoffset, bitoffset
end


function getbitsfrombytes(bytes, startbit, bitcount)
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

function setbitstobytes(bytes, startbit, bitcount, value, bigendian)

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


