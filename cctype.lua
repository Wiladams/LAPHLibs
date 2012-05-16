local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor


function tolower(c)
	return band(0xff,bor(c, 0x20))
end

local t_a = string.byte('a')
local t_z = string.byte('z')
local t_0 = string.byte('0')
local t_9 = string.byte('9')

function isalpha(c)
	return (tolower(c) >= t_a and tolower(c) <= t_z)
end

function isdigit(c)
	return c >= t_0 and c <= t_9
end

function islanum(c)
	return (isalpha(c) or isdigit(c))
end

-- ' ' 0x0a, '\t' 0x09, '\n' 0x0a, '\v' 0x0b, '\f' 0x0c, '\r' 0x0d
function isspace(c)
	return c == 0x20 or c == 0x09 or
	  c == 0x0a or c == 0x0b or c == 0x0c or c == 0x0d
end

function isxdigit(c)
	return (isdigit(c) or (tolower(c) >= string.byte('a') and tolower(c) <= string.byte('f')))
end


