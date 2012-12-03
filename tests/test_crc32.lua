package.path = package.path..";../?.lua";

crc = require "CRC32"


local str1 = "Test vector from febooti.com";
local str2 = "123456789"

--print(string.format("0x%08x",crc.CRC32(str1)));
--print(string.format("0x%08x",crc.CRC32(str2)));

assert(crc.CRC32(str1) == crc.CRC32(str1, crc.CRC32l))
assert(crc.CRC32(str2) == crc.CRC32(str2, crc.CRC32l))
