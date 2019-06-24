local bit = require("bit")
local band, bor = bit.band, bit.bor 
local rshift, lshift = bit.rshift, bit.lshift

local limits = require("limits")

local floor = math.floor;
local ceil = math.ceil;
local max = math.max;
local min = math.min;


local exports = {
    HALF_PI = math.pi / 2;
    PI = math.pi;
    QUARTER_PI = math.pi/4;
    TWO_PI = math.pi * 2;
    TAU = math.pi * 2;
}

function exports.constrain(x, low, high)
    return min(max(x, low), high)
end

function exports.lerp(low, high, x)
    return low + x*(high-low)
end

function exports.map(x, olow, ohigh, rlow, rhigh, withinBounds)
    rlow = rlow or olow
    rhigh = rhigh or ohigh
    local value = rlow + (x-olow)*((rhigh-rlow)/(ohigh-olow))

    if withinBounds then
        value = exports.constrain(value, rlow, rhigh)
    end

    return value;
end

-- because it's not in the standard math library
function exports.round(n)
	if n >= 0 then
		return floor(n+0.5)
	end

	return ceil(n-0.5)
end


-- determine whether the specified
-- value is a power of two
function exports.is_power_of_two(value)
	if value == 0 then
		return false;
	end

	return band(value, (value-1)) == 0;
end

-- round up to the nearest
-- power of 2
function exports.roundup32(x) 
	x = x - 1; 
	x = bor(x,rshift(x,1)); 
	x = bor(x,rshift(x,2)); 
	x = bor(x,rshift(x,4)); 
	x = bor(x,rshift(x,8)); 
	x = bor(x,rshift(x,16)); 
	x = x + 1;
	
	return x
end

--[[
    Find the minimum number of bytes required to represent
    a given positive integer.  Numbers range from one byte 
    up to 8 bytes.
]]

function exports.min_bytes_needed(value)
    local bytes;
    
    if (value <= limits.UINT32_MAX) then
        if (value < 16777216) then
            if (value <= limits.UINT16_MAX) then
                if (value <= limits.UINT8_MAX) then 
                    bytes = 1;
                else 
                    bytes = 2;
                end
            else 
                bytes = 3;
            end
        else 
            bytes = 4;
        end
    
    elseif (value <= limits.UINT64_MAX) then 
        if (value < 72057594000000000ULL) then 
            if (value < 281474976710656ULL) then
                if (value < 1099511627776ULL) then
                    bytes = 5;
                else 
                    bytes = 6;
                end
            else 
                bytes = 7;
            end
        else 
            bytes = 8;
        end
    end

    return bytes;
end

function exports.clamp(x, low, high)
    return math.min(math.max(x, low), high)
end

function exports.lerp(x, olow, ohigh, rlow, rhigh)
    return rlow + (x-olow)*((rhigh-rlow)/(ohigh-olow))
end

return exports;
