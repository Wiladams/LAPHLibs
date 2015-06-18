local bit = require("bit")
local band, rshift = bit.band, bit.rshift

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

    while (band(value, 1) == 0) do
		value = rshift(value, 1);
    end

    return value == 1;
end

local exports = {
	is_power_of_two = is_power_of_two;
	round = round;
}

return exports;
