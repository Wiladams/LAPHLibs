
local ffi = require("ffi")
local sizeof = ffi.sizeof

local bit = require("bit")
local lshift, rshift = bit.lshift, bit.rshift
local band, bor = bit.band, bit.bor



-- this was originally copypasted from lz4.c

--[[
    Useful utilities
]]
local function memcpy(dest, src, nbytes)
	ffi.copy(dest, src, nbytes)
end

-- read little endian unsigned short
-- p - const uint8_t *
local function read2(p)
    return tonumber(ffi.cast("uint16_t",bor(p[0], lshift(p[1], 8))));
end

local function  expect(expr,value) 
    --if expr then return value
    return (expr)
end

local function  likely(expr) 
    return expect(expr ~= 0, 1)
end

local function  unlikely(expr) 
    return expect((expr) ~= 0, 0)
end



local ML_BITS  = 4
local ML_MASK  = (lshift(1,ML_BITS)-1)
local RUN_BITS = 8-ML_BITS;
local RUN_MASK = (lshift(1,RUN_BITS)-1)

local MINMATCH = 4;
local LASTLITERALS = 5;
local WILDCOPYLENGTH = 8;
local MFLIMIT = WILDCOPYLENGTH + MINMATCH;


local function LZ4_copy8(dst, src) 
    memcpy(dst, src, 8);
end

-- allocate this here so we don't do it every
-- time write32() is called
local v_a = ffi.new("uint32_t[1]")

local function LZ4_write32(memptr, value)
    v_a[0] = value
    memcpy(memptr, v_a, sizeof(v_a));
end

-- copy from a beginning pointer, until an ending pointer
-- into a destination pointer.
local function  LZ4_wild_copy(dstptr, srcptr, dstend)

    local d = ffi.cast("uint8_t*",dstptr);
    local s = ffi.cast("uint8_t const*",srcptr);
    local e = ffi.cast("uint8_t*",dstend);
    
    repeat
        LZ4_copy8(d, s); 
        d = d+8; 
        s = s+8; 
    until ( d>=e )
end




local dec32table = ffi.new("int32_t[8]",{ 0, 1, 2, 1, 4, 4, 4, 4 });
local dec64table = ffi.new("int32_t[8]",{ 0, 0, 0, -1, 0, 1, 2, 3 });


--    local function LZ4_decompress_safe(char const* src,
--    char* dst, uint32_t src_size, uint32_t output_size)
-- TODO - much of this can be accomplished by leveraging the binstream
local function LZ4_decompress_safe(src, dst, src_size, output_size)

    local ip = ffi.cast("uint8_t const*", src);
    local iend = ip + src_size;

    local op = ffi.cast("uint8_t*", dst);
    local oend = op + output_size;
    local cpy = nil;


    -- special cases
    if (unlikely(output_size == 0)) then
        if ((src_size == 1) and (ip[0] == 0)) then
            return 0
        else
            return -1
        end
    end


    -- main loop: decode sequences
    while (true) do
        local length = 0;
        local match = nil;
        local offset = 0;

        -- get literal length
        local token = ip[0];
        ip = ip + 1;



        length = rshift(token,ML_BITS)
        if (length == RUN_MASK) then

            local s = 0;
--[[
            do {
                s = *ip++;
                length += s;
            }
            while (likely(ip < iend - RUN_MASK) & (s == 255));

            if (unlikely((uintptr_t)op + length < (uintptr_t)op))
                goto _output_error; /* overflow detection */

            if (unlikely((uintptr_t)ip + length < (uintptr_t)ip))
                goto _output_error; /* overflow detection */
--]]
        end


        -- copy literals
        cpy = op+length;

        if (cpy > (oend - MFLIMIT) or
            (ip + length) > iend - (2 + 1 + LASTLITERALS)) then
        
            if ((ip + length ~= iend) or (cpy > oend)) then
                goto _output_error;
                -- error : input must be consumed */
            end

            memcpy(op, ip, length);
            ip = ip + length;
            op = op + length;
            break;
            -- necessarily eof, due to parsing restrictions
        end

        LZ4_wild_copy(op, ip, cpy);
        ip = ip +length; 
        op = cpy;

        -- get offset
        offset = read2(ip); 
        ip = ip + 2;
        match = op - offset;

        if (unlikely(match < (uint8_t const*)dst))
            goto _output_error;
            -- error : offset outside buffers

        LZ4_write32(op, (uint32_t)offset);
        -- costs ~1%; silence an msan warning when offset == 0

        -- get matchlength
        length = band(token, ML_MASK);

        if (length == ML_MASK) then
        
            local s = 0;

            repeat
                s = ip[0];
                ip = ip + 1;
                if (ip > iend - LASTLITERALS) then
                    goto _output_error;
                end

                length = length + s;
            
            until (s ~= 255);

            if (unlikely((uintptr_t)op + length < (uintptr_t)op)) then
                goto _output_error; /* overflow detection */
            end
        end

        length = length + MINMATCH;

        -- copy match within block
        cpy = op + length;

        if (unlikely(offset < 8)) then
            int const dec64 = dec64table[offset];
            op[0] = match[0];
            op[1] = match[1];
            op[2] = match[2];
            op[3] = match[3];
            match += dec32table[offset];
            memcpy(op + 4, match, 4);
            match -= dec64;
        else
            LZ4_copy8(op, match); match+=8;
        end

        op += 8;

        if (unlikely(cpy > oend - 12))
        {
            uint8_t* const o_copy_limit =
                oend - (WILDCOPYLENGTH - 1);

            if (cpy > oend - LASTLITERALS) goto _output_error;
            /* error : last LASTLITERALS bytes must be literals
            (uncompressed) */

            if (op < o_copy_limit)
            {
                LZ4_wild_copy(op, match, o_copy_limit);
                match += o_copy_limit - op;
                op = o_copy_limit;
            }
            while (op < cpy) *op++ = *match++;
        }

        else {
            LZ4_copy8(op, match);
            if (length > 16) LZ4_wild_copy(op + 8, match + 8, cpy);
        }
        op=cpy;   -- correction
--]=]
    end

    -- end of decoding
    --return (int)(((char*)op) - dst);
    -- n of output bytes decoded

    -- overflow error detected
--_output_error:
    --return (int)(-(((char const*)ip) - src)) - 1;
end
