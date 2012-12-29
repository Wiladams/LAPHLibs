--[[
	References:

	http://pic.dhe.ibm.com/infocenter/aix/v6r1/index.jsp?topic=%2Fcom.ibm.aix.basetechref%2Fdoc%2Fbasetrf1%2Fctype.htm
	http://www.cplusplus.com/reference/clibrary/cctype/
--]]

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor


function tolower(c)
	return band(0xff,bor(c, 0x20))
end

function toupper(c)
	if (islower(c)) then
		return band(c, 0x5f)
	end

	return c
end

local t_a = string.byte('a')
local t_f = string.byte('f')
local t_z = string.byte('z')
local t_A = string.byte('A')
local t_F = string.byte('F')
local t_Z = string.byte('Z')
local t_0 = string.byte('0')
local t_9 = string.byte('9')

function isalnum(c)
	return (isalpha(c) or isdigit(c))
end

function isalpha(c)
	return (c >= t_a and c <= t_z) or
		(c >= t_A and c <= t_Z)
end

function isascii(c)
	return (c >= 0) and (c <= 0x7f)
end

function isbyte(n)
	return band(n,0xff) == n
end

function iscntrl(c)
	return (c >= 0 and c < 0x20) or (c == 0x7f)
end

function isdigit(c)
	return c >= t_0 and c <= t_9
end

function isgraph(c)
	return c > 0x20 and c < 0x7f
end

function islower(c)
	return c>=t_a and c<=t_z;
end

function isprint(c)
	return c >= 0x20 and c < 0x7f
end

function ispunct(c)
	return isgraph(c) and not isalnum(c)
--[[
	return (c>=0x21 and c<=0x2f) or
		(c>=0x3a and c<=0x40) or
		(c>=0x5b and c<=0x60) or
		(c>=0x7b and c<=0x7e)
--]]
end

-- ' ' 0x0a, '\t' 0x09, '\n' 0x0a, '\v' 0x0b, '\f' 0x0c, '\r' 0x0d
function isspace(c)
	return c == 0x20 or (c >= 0x09 and c<=0x0d)
end

function isupper(c)
	return c >= t_A and c <= t_Z;
end

function isxdigit(c)
	if isdigit(c) then return true end

	return (c >= t_a and c <= t_f) or
		(c >= t_A and c <= t_F)
end

return {
	isalnum = isalnum,
	isalpha = isalpha,
	isascii = isascii,
	isbyte	= isbyte,
	iscntrl = iscntrl,
	isdigit = isdigit,
	isgraph = isgraph,
	islower = islower,
	isprint = isprint,
	ispunct = ispunct,
	isspace = isspace,
	isupper = isupper,
	isxdigit = isxdigit,

	tolower = tolower,
	toupper = toupper,
}







