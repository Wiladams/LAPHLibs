local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local rshift = bit.rshift
local lshift = bit.lshift


local randbox = ffi.new("uint32_t[16]", {
	0x49848f1b, 0xe6255dba, 0x36da5bdc, 0x47bf94e9,
	0x8cbcce22, 0x559fc06a, 0xd268f536, 0xe10af79a,
	0xc1af4d69, 0x1d2917b5, 0xec4c304d, 0x9ee5016c,
	0x69232f74, 0xfead7bb3, 0xe9089ab6, 0xf012f6ae,
    });

function hash_fun_default(key, len)
	len = len or #key
    local str = ffi.cast("uint8_t *", key);
    local acc = 0;
	local offset = 0

    while (offset < len) do
		acc = bxor(acc,randbox[band((str[offset] + acc), 0xf)]);
		acc = bor(lshift(acc, 1), rshift(acc, 31));
		acc = band(acc, 0xffffffff);
		acc = bxor(acc,randbox[band((rshift(str[offset], 4) + acc), 0xf)]);
		offset = offset + 1;
		acc = bor(lshift(acc, 2), rshift(acc, 30));
		acc = band(acc, 0xffffffff);
    end

    return acc;
end

return {
	KazHash = hash_fun_default,
}
