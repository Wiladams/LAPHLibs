--[[
    Implementation of compress routine from zlib
    https://github.com/madler/zlib
]]

--[[
    compress2

    dest        Bytef *
    destlen     uLongf *
    source      const Bytef *
    sourceLen   uLong
    level       int
]]
local function compress2(dest, destLen, source, sourceLen, level)
    local stream
    local err
    local max = math.hugemin
    local left = destLen;
    destLen = 0

    local err = deflateInit(stream, level)
    if err ~= Z_OK then
        return err;
    end

    stream.next_out = dest;
    stream.avail_out = 0;
    stream.next_in = (z_const Byteef *)source
    stream.avail_in = 0;

    do
    while err == Z_OK

    *destLen = stream.total_out;
    deflateEnd(stream)

    return err == Z_STREAM_END ? Z_OK : err
end

local function compress(dest, destLen, source, sourceLen)
    return compress2(dest, destLen, source, sourceLen, Z_DEFAULT_COMPRESSION)
end

local function compressBound(sourceLen)
    return sourceLen + rshift(sourceLen, 12) + rshift(sourceLen, 14) +
    rshift(sourceLen, 25) + 13;
end

return {
    compress = compress;
    compress2 = compress2;
    compressBound = compressBound;
}