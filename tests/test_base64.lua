package.path = package.path..";../?.lua";

local base64 = require("base64")

local cases = {
    -- Some cases from wikipedia article
    -- https://en.wikipedia.org/wiki/Base64
    {[[TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz
IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg
dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu
dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo
ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=]],[[Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.]]};
    {[[YW55IGNhcm5hbCBwbGVhc3VyZS4=]],[[any carnal pleasure.]]};
    {[[YW55IGNhcm5hbCBwbGVhc3VyZQ==]],[[any carnal pleasure]]};
    {[[YW55IGNhcm5hbCBwbGVhc3Vy]],[[any carnal pleasur]]};
    {[[YW55IGNhcm5hbCBwbGVhc3U=]],[[any carnal pleasu]]};
    {[[YW55IGNhcm5hbCBwbGVhcw==]],[[any carnal pleas]]};
    -- shows how same chars are encoded differently depending on 
    -- position within octet stream
    {[[cGxlYXN1cmUu]],[[pleasure.]]};
    {[[bGVhc3VyZS4= ]],[[leasure.]]};
    {[[ZWFzdXJlLg==]],[[easure.]]};
    {[[YXN1cmUu]],[[asure.]]};
    {[[c3VyZS4=]],[[sure.]]};
}

local function test_hello()
    print(base64.encode("Hello, World!"))
end 



local function test_decode(cases)
    for idx, case in ipairs(cases) do 
        local encoded = case[1];
        local expected = case[2];
        local decoded = base64.decode(encoded)

        if decoded == expected then
            print(idx, "PASS")
        else
            print(idx, "FAIL")
        end
    end
end

--test_hello();
test_decode(cases);
