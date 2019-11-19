package.path = package.path..";../?.lua";

local adler32 = require "adler32"


local str1 = "Test vector from febooti.com";
local str2 = "123456789"

--print("CRC: ", string.format("%08x",crc.CRC32(str1)));

print(string.format("%08x",tonumber(adler32(""))))
print(string.format("%08x",tonumber(adler32(str1))))
