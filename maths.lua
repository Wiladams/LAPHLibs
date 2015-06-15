local floor = math.floor;
local ceil = math.ceil;

-- because it's not in the standard math library

local function math.round(n)
	if n >= 0 then
		return floor(n+0.5)
	end

	return ceil(n-0.5)
end


