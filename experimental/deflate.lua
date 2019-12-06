--[[
    zlib implementation of deflate

    https://github.com/madler/zlib/blob/master/deflate.h
]]
local ffi = require("ffi")

local zutil = require("zutil")

local ex = {
    LENGTH_CODES = 29;
    LITERALS = 256;
    D_CODES = 30;
    BL_CODES = 19;
    MAX_BITS = 15;
    Buf_size = 16;
    INIT_STATE = 42;
    GZIP_STATE = 57;
    EXTRA_STATE = 69;
    NAME_STATE = 73;
    COMMENT_STATE = 91;
    HCRC_STATE = 103;
    BUSY_STATE = 113;
    FINISH_STATE = 666;     -- stream complete
}


ex.L_CODES = ex.LITERALS+1+ex.LENGTH_CODES;
ex.HEAP_SIZE = 2*ex.L_CODES+1;

ffi.cdef[[
typedef struct ct_data_s {
    union {
        ush freq;   // frequency count for huffman
        ush code;   // bit string
    } fc;

    union {
        ush dad;    // father node in huffman tree
        ush len;    // length of bit string
    } dl;
} ct_data;
]]


ffi.cdef[[
    typedef struct static_tree_desc_s static_tree_desc;

typedef struct tree_desc_s {
    ct_data *dyn_tree;
    int max_code;
    const static_tree_desc *stat_desc;
}
]]

ffi.cdef[[
typedef ush Pos;
typedef Pos Posf;
typedef unsigned IPos;
]]




return ex