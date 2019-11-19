--[[
    From RFC 1950

    Adler32 calculation
]]

local ffi = require("ffi")
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor

local BASE = 65521      -- largest prime smaller than 65536

--[[
    Update a running Adler-32 checksum with the bytes
    buf[0..len-1] and return the updated checksum.  
    The Adler-32 checksum should be initialized to 1.

    Usage:
      local adler = 1
      while (read_buffer(buffer, length) ~= EOF) do
        adler = update_adler32(adler, buffer, length)
      end
      if (adler ~= original_adler) then error() end

--]]

local function update_adler32(adler, buf, len)
    local s1 = ffi.cast("unsigned long", band(adler, 0xffff))
    local s2 = ffi.cast("unsigned long", band(rshift(adler, 16), 0xffff))
    local n

    for n=0, len-1 do
        s1 = (s1 + buf[n])  % BASE
        s2 = (s2 + s1)      % BASE
    end

    return lshift(s2, 16)+s1;
end

local function adler32(buf, len)
    local adler = 1
    len = len or #buf

    return update_adler32(1, ffi.cast("const char *", buf), len)
end

return adler32