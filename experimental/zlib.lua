--[[
    Implementation of RFC 1950

    Basic ZLib coder/decoder

    based on consuming an octet stream
--]]

local bitbang = require("laphlibs.bitbang")
local BITSVALUE= bitbang.BITSVALUE


--[[
    +---+---+
    |CMF|FLG|
    +---+---+
--]]


--[[
    CMF
    bits 0 to 3     CM      Compression Method
    bits 4 to 7     CINFO   Compression info
]]
local CM = {
    [8] = "deflate";    -- Window size 32K
    [15] = "reserved";
}

--[[
    FLG
    bits 0 to 4     FCHECK  (check bits for CMF and FLG)
    bit  5          FDICT   (preset dictionary)
    bits 6 to 7     FLEVEL  (compression level)
]]

local function readHeader(bs, res)
    res = res or {}
    
    local cmf = bs:readOctet();
    local flg = bs:readOctet()


    res.CMF = {
        CM = tonumber(BITSVALUE(cmf, 0, 3));
        CINFO = tonumber(BITSVALUE(cmf, 4, 7));
    }
    
    res.FLG = {
        FCHECK = tonumber(BITSVALUE(flg, 0, 4));
        FDICT = BITSVALUE(flg, 5, 5) == 1;
        FLEVEL = tonumber(BITSVALUE(flg, 6, 7));
    }

    return res
end

local function decode(bs, res)
    res = res or {}
    res.Header = readHeader(bs, res)

    return res
end

return {
    decode = decode;
    encode = encode;
}