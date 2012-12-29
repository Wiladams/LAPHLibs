
local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local bnot = bit.bnot

local rshift = bit.rshift
local lshift = bit.lshift


-- Karl Malbrain's compact CRC-32.
-- See "A compact CCITT crc16 and crc32 C implementation that balances processor cache usage against speed":
-- http://www.geocities.ws/malbrain/

--
local s_crc32 = ffi.new("const uint32_t[16]", {
	0x00000000, 0x1db71064, 0x3b6e20c8, 0x26d930ac,
	0x76dc4190, 0x6b6b51f4, 0x4db26158, 0x5005713c,
    0xedb88320, 0xf00f9344, 0xd6d6a3e8, 0xcb61b38c,
	0x9b64c2b0, 0x86d3d2d4, 0xa00ae278, 0xbdbdf21c
	});

local MZ_CRC32_INIT = 0

function mz_crc32(buff, buf_len, crc)
	crc = crc or 0
	local crcu32 = crc;
	local ptr = ffi.cast("const uint8_t *", buff);

	if (ptr == nil) then
		return 0;
	end

	crcu32 = bnot(crcu32);

	while (buf_len>0) do
		local b = ptr[0];
		crcu32 = bxor(rshift(crcu32, 4), s_crc32[bxor(band(crcu32, 0xF), band(b, 0xF))]);
		crcu32 = bxor(rshift(crcu32, 4), s_crc32[bxor(band(crcu32, 0xF), rshift(b, 4))]);

		ptr = ptr + 1
		buf_len = buf_len - 1
	end

	return bnot(crcu32);
end

local function CRC32(src, len)

	if not len then
		if type(src) == "string" then
			len = #src
		elseif type(src) == "cdata" then
			len = ffi.sizeof(src)
		end
	end
	
	if not len then return nil end

	return mz_crc32(src, len)
end


return {
	CRC32 = CRC32,
	mz_crc32 = mz_crc32,
}
