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