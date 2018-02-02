
local pow = math.pow
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor


--[[
Function: getValueName()
Description: Given a table such as this

	local testtbl = {
		LOWEST 	= 0x0001;
		MEDIUM 	= 0x0002;
		HIGHEST = 0x0004;
		MIGHTY 	= 0x0008;
		SLUGGO 	= 0x0010;
		MUGGO 	= 0x0020;
		BUGGO 	= 0x0040;
		PUGGO 	= 0x0080;
	}

	You can call getValueName like this:

	local name = getValueName(0x0008, testbl)

	and 'name' will contain "MIGHTY"

	This assumes that the table represents a discrete value/name
	pair.  It will not work in the case where the value represents
	a compound value, that's what the 'enumbits()' function is for.

	Note: This is a common enough operation that it really belongs in 
	a table utils module.  So, at some point, if that module is created,
	this function should move there.
--]]

local function getValueName(value, tbl)
	for k,v in pairs(tbl) do
		if v == value then
			return k;
		end
	end

	return nil;
end

--[[
	Function: enumbits
	Parameters: 
		bistValue - this is an integer value representing the bit flags
		tbl - the table the contains the name/value pairs that define the meaning of the bit flags
		bitsSize - how many bits are in the numeric values, default is 32
		
	Description: Given an integer value that represents a bunch of individual
	flags of some state, we want to get the string value which 
	is used as a key to represent the integer flag value in a table.

	The enumbits() function returns an iterator, which will push
	out the names of the individual bits, as they are found in a 
	table.

	for _, name in enumbits(0x04000001, tbleOfValues, b2) do
		print(name)
	end
--]]

local function enumbits(bitsValue, tbl, bitsSize)
	local function name_gen(params, state)

		if state >= params.bitsSize then return nil; end

		while(true) do
			local mask = pow(2,state)
			local maskedValue = band(mask, params.bitsValue)
--print(string.format("(%2d) MASK [%x] - %#x", state, mask, maskedValue))			
			if maskedValue ~= 0 then
				return state + 1, getValueName(maskedValue, params.tbl) or "UNKNOWN"
			end

			state = state + 1;
			if state >= params.bitsSize then return nil; end
		end

		return nil;
	end

	return name_gen, {bitsValue = bitsValue, tbl = tbl, bitsSize = bitsSize or 32}, 0
end

return enumbits