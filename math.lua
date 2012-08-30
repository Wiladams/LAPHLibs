-- because it's not in the standard math library
function math.round(n)
	if n >= 0 then
		return math.floor(n+0.5)
	end

	return math.ceil(n-0.5)
end


