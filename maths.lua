local bit = require("bit")
local band, bor = bit.band, bit.bor 
local rshift, lshift = bit.rshift, bit.lshift

local floor = math.floor;
local ceil = math.ceil;

-- because it's not in the standard math library
local function round(n)
	if n >= 0 then
		return floor(n+0.5)
	end

	return ceil(n-0.5)
end

local function is_power_of_two(value)
	if value == 0 then
		return false;
	end

	return band(value, (value-1)) == 0;
end

-- round up to the nearest
-- power of 2
local function roundup32(x) 
	x = x - 1; 
	x = bor(x,rshift(x,1)); 
	x = bor(x,rshift(x,2)); 
	x = bor(x,rshift(x,4)); 
	x = bor(x,rshift(x,8)); 
	x = bor(x,rshift(x,16)); 
	x = x + 1;
	
	return x
end

local exports = {
	is_power_of_two = is_power_of_two;
	round = round;
	roundup = roundup32;
}

return exports;
