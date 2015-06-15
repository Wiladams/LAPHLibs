--[[
	This code was inspired by the code here:

	http://lists.uclibc.org/pipermail/uclibc/2000-December/020921.html

	Which carried the following copyright

/*
 * Copyright (C) 2000 Manuel Novoa III
 *
 * Notes:
 *
 * The primary objective of this implementation was minimal size.
 *
 */
--]]



local ffi = require "ffi"

require "limits"
require "cctype"


--[[
/*
 * This is the main work function which handles both strtol (uflag = 0) and
 * strtoul (uflag = 1).
 */
--]]

local function _strto_l(str, endptr, base, uflag)

    local number = 0;
    local cutoff;
    local pos = str;
    local fail_char = str;
    local digit, cutoff_digit;
    local negative;

	-- skip leading whitespace
    while (isspace(pos[0])) do
		pos = pos + 1;
    end

    -- handle optional sign
    negative = false;


    if pos[0] ==  string.byte('-') or pos[0] == string.byte('+') then
		if pos[0] == string.byte('-') then
			negative = true;
		end

		-- fall through to increment pos
		pos = pos + 1
    end

    if ((base == 16) and (pos[0] == string.byte('0'))) then
		-- handle option prefix
		pos = pos + 1;
		fail_char = pos;

		if ((pos[0] == string.byte('x')) or (pos[0] == string.byte('X'))) then
			pos = pos + 1;
		end
    end

	-- dynamic base
    if (base == 0) then
		-- default is 10
		base = 10;

		if (pos[0] == string.byte('0')) then

			pos = pos + 1;
			base = base - 2;		-- now base is 8 (or 16)
			fail_char = pos;

			if ((pos[0] == string.byte('x')) or (pos[0] == string.byte('X'))) then
				base = base + 8;	-- base is 16
				pos = pos + 1;
			end
		end
    end

    if ((base < 2) or (base > 36)) then
		return math.huge;
	 -- illegal base
		--goto DONE;
    end

    cutoff = ULONG_MAX / base;
    cutoff_digit = ULONG_MAX - cutoff * base;

    while (true) do

		digit = 40;
		if ((pos[0] >= string.byte('0')) and (pos[0] <= string.byte('9'))) then
			digit = (pos[0] - string.byte('0'));
		elseif (pos[0] >= string.byte('a')) then
			digit = (pos[0] - string.byte('a') + 10);
		elseif (pos[0] >= string.byte('A')) then
			digit = (pos[0] - string.byte('A') + 10);
		else
			break;
		end

		if (digit >= base) then
			break;
		end

		pos = pos + 1;
		fail_char = pos;

		-- adjust number, with overflow check
		if ((number > cutoff) or
		   ((number == cutoff) and
		   (digit > cutoff_digit))) then

			number = ULONG_MAX;
			if (uflag) then
				negative = false; -- since unsigned returns ULONG_MAX
			end
		else
			number = number * base + digit;
		end

    end

	if (endptr ~= nil) then
		endptr[0] = fail_char;
    end


    if (negative) then
		if (not uflag and (number > (ffi.cast("uint32_t",(-(1+LONG_MIN)))+1))) then
			return LONG_MIN;
		end

		return -number;
    else
		if (not uflag and (number > LONG_MAX)) then
			return LONG_MAX;
		end

		return number;
    end
end

local function strtoul(str, endptr, base)
	endptr = endptr or nil
	base = base or 10

    return _strto_l(str, endptr, base, true);
end

local function strtol(str, endptr, base)
	endptr = endptr or nil
	base = base or 10

    return _strto_l(str, endptr, base, false);
end

local function atoi(str)
	return _strto_l(str, nil, 10, false);
end

local exports = {
	strtoul = strtoul;
	strtol = strtol;
	atoi = atoi;
}

return exports
