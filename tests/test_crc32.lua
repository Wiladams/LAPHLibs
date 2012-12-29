package.path = package.path..";../?.lua";

crc = require "CRC32"


local str1 = "Test vector from febooti.com";
local str2 = "123456789"

--print("CRC: ", string.format("%08x",crc.CRC32(str1)));

assert(string.format("%08x",crc.CRC32("")) == "00000000", "FAILED")
assert(string.format("%08x",crc.CRC32(str1)) == "0c877f61", "FAILED")
