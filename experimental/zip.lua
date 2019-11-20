--[[
    .zip file format codec

    RFCs 1950 (zlib compressed data format), 1951 (deflate compression), 1952 (gzip file format)
]]
local function decode(bs, res)
    res = res or {}

    res.Magic = bs:readBytes(4)
    res.ExtractionVersion = bs:readBytes(2)
    res.BitFlag = bs:readBytes(2)
    res.CompressionMethod = bs:readBytes(2)
    res.FileLastModified = bs:readBytes(2)
    res.FileLastModifiedDate = bs:readBytes(2)
    res.CRC32 = bs:readBytes(4)
    res.CompressedSize = bs:readBytes(4)
    res.UncompressedSize = bs:readBytes(4)
    res.FilenameLength = bs:readBytes(2)
    res.ExtraFieldLength = bs:readBytes(2)
    res.FileName = bs:readString(res.FilenameLength)
    res.ExtraField = bs:readBytes(res.ExtraFieldLength)

    return res
end
