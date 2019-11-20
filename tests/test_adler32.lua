package.path = package.path..";../?.lua";

local adler32 = require "laphlibs.adler32"

local tvecs = {
    -- Some test vectors from here: http://wiki.hping.org/124
    {"Mark Adler", 0x13070394}, 
    {"\x00\x01\x02\x03", 0x000e0007},
    {"\x00\x01\x02\x03\x04\x05\x06\x07", 0x005c001d},
    {"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f", 0x02b80079},
    {"\x41\x41\x41\x41", 0x028e0105},
    {"\x42\x42\x42\x42\x42\x42\x42\x42", 0x09500211},
    {"\x43\x43\x43\x43\x43\x43\x43\x43\x43\x43\x43\x43\x43\x43\x43\x43", 0x23a80431},
}

for _, vec in ipairs(tvecs) do
    local val = tonumber(adler32(vec[1]))
    print(string.format("%08x  %08x", vec[2], val))
    assert(vec[2] == val)
end
print("PASSED")


