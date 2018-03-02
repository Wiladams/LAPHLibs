--[[
	Given an integer value that represents a bunch of individual
	flags of some state, we want to get the string value which 
	is used as a key to represent the integer flag value in a table.

	The enumbits() function returns an iterator, which will push
	out the names of the individual bits, as they are found in a 
	table.

	for _, name in enumbits(0x04000001, tbleOfValues, b2) do
		print(name)
	end
--]]
local pow = math.pow
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor

local function getValueName(value, tbl)
	for k,v in pairs(tbl) do
		if v == value then
			return k;
		end
	end

	return nil;
end

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