--[[
	References:

	http://pic.dhe.ibm.com/infocenter/aix/v6r1/index.jsp?topic=%2Fcom.ibm.aix.basetechref%2Fdoc%2Fbasetrf1%2Fctype.htm

--]]

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor


function tolower(c)
	return band(0xff,bor(c, 0x20))
end

local t_a = string.byte('a')
local t_f = string.byte('f')
local t_z = string.byte('z')
local t_A = string.byte('A')
local t_Z = string.byte('Z')
local t_0 = string.byte('0')
local t_9 = string.byte('9')

function isalnum(c)
	return (isalpha(c) or isdigit(c))
end

function isalpha(c)
	local lowered = tolower(c)
	return (lowered >= t_a and lowered <= t_z)

	--return (bor(c, 32) - t_a) < 26
end

function isascii(c)
	return (c >= 0) and (c <= 0x7f)
end

function iscntrl(c)
	return (c >= 0 and c < 0x20) or (c == 0x7f)
end

function isdigit(c)
	return c >= t_0 and c <= t_9
end

function isgraph(c)
	return (c-0x21) < 0x5e;
end

function islower(c)
	return c>=t_a and c<=t_z;
end

function isprint(c)
	return c >= 0x20 and c <= 0x7f
end

-- ' ' 0x0a, '\t' 0x09, '\n' 0x0a, '\v' 0x0b, '\f' 0x0c, '\r' 0x0d
function isspace(c)
	return c == 0x20 or c == 0x09 or
	  c == 0x0a or c == 0x0b or c == 0x0c or c == 0x0d
end

function isupper(c)
	return c >= t_A and c <= t_Z;
end

function isxdigit(c)
	if isdigit(c) then return true end

	local lowered = tolower(c);
	if lowered >= t_a and lowered <= t_f then
		return true
	end

	return false
end








