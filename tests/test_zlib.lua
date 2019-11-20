package.path = package.path..";../?.lua";

local zlib = require("laphlibs.zlib")
local octetstream = require("laphlibs.octetstream")

function decodeFile(filename)
    local f = io.open(filename, "r")
    if not f then
        error("decodeFile, error: ", f, filename)
        --return nil, "file not opened: "..filename
    end

    local bytes = f:read("*a")
    f:close()
    local bs = octetstream(bytes)

    local res = zlib.decode(bs)

    print("CMF")
    print(res.CMF.CM)
    print(res.CMF.CINFO)

    print()

    print("FLG")
    print(res.FLG.FCHECK)
    print(res.FLG.FDICT)
    print(res.FLG.FLEVEL)
end

decodeFile("test_zlib.zip")