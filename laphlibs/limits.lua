
-- Posix definitions

local exports = {

	INT8_MIN = -128;
	INT8_MAX = 127;
	UINT8_MAX = 0xff;

	INT16_MIN = -32768;
	INT16_MAX = 32767;
	UINT16_MAX = 0xffff;

	INT32_MIN = -2147483647 - 1;
	INT32_MAX = 2147483647;
	UINT32_MAX = 0xffffffff;


	UINT64_MAX = 9223372036854775807LL;
	UINT64_MIN = -9223372036854775807LL - 1;
	UINT64_MAX = 0xffffffffffffffffULL;

}

-- Windows specific
exports.CHAR_BIT = 8;	-- number of bits in a char
exports.PATH_MAX = 512;

-- LONG and INT tend to match the natural
-- lengths of the platform so the following
-- is not necessarily correct
exports.LONG_MIN = 0x80000000;
exports.LONG_MAX = 0x7FFFFFFF;
exports.ULONG_MAX = 0xFFFFFFFF;

exports.ULLONG_MAX = exports.UINT64_MAX
exports.UINT_MAX = exports.UINT32_MAX;
exports.USHRT_MAX = exports.UINT16_MAX;
exports.UCHAR_MAX = exports.UINT8_MAX;

return exports
