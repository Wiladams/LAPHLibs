
--[[
//  bit map arena virtual memory allocator
//  using one bit of overhead per block

//  When releasing memory, you must supply the block size. Under
//  modern programming discipline, this should be available since
//  you generally have to check OBJECT SIZE FOR OVERFLOW anyway.

//  A standard malloc and free routine is conditionally supplied
//  that remembers the block sizes if this is a problem. 

//  please report bugs located to the program author,
//  karl_m@acm.org www.geocities.com/malbrain

//  n.b. the semantics of valloc differ slightly from the standard
//  unix V R4 definition:  the memory allocated is aligned to
//  the blocksize of the appropriate templated arena, not
//  necessarily to the virtual memory system page size.
//  Also, valloc requests must be released with vfree.

//  That said, with the default templates given below,
//  valloc requests for 4K or more will align
//  on a page boundary.
--]]

local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;
local bor = bit.bor;
local bnot = bit.bnot;
local bxor = bit.bxor;
local lshift = bit.lshift;
local rshift = bit.rshift;

local limits = require("limits");
--local VirtualMemory = require("VirtualMemory");

--[[
//  each memory arena structure is followed by a bit map
//  allocation table made of unsigned ints where the low
//  order bit represents the lowest block number.
--]]

ffi.cdef[[
typedef struct Arena_ {
    char *mem, *ending;    // beginning and end of arena allocation
    void *next;         // next arena in chain with same template

    unsigned int blksize;   // block size for memory allocation
    unsigned int mapmax;    // map size in ints immediately following
    unsigned int blkmax;    // maximum block allocation in bytes
    unsigned int avail;     // amount of available arena space
    unsigned int scan;      // current scan offset
} Arena;
]]

--[[
//  the Arenas are arrayed with their bit maps into page frames;
//  the first structure in the page frame describes the page
//  new arenas are allocated from the end
]]

ffi.cdef[[
typedef struct Page_ {
    unsigned first;     // offset of lowest arena allocated
    unsigned size;      // size of this page in bytes
    void *prev;         // previous page of arenas in chain
} Page;
]]


local MAP_BITS = (CHAR_BIT * ffi.sizeof("unsigned int"));
local FRAME_SIZE = 8192;

--Page *PageLIFO;
local PageLIFO;

-- allocate and initialize a new page frame for arenas

local vframe = function()

    local xtra = 0;
    local size = FRAME_SIZE;
    local page = nil;


    page = ffi.cast("Page *",VirtualAlloc(nil, size, MEM_COMMIT, PAGE_READWRITE));
    page.first = size;
    page.size = size;
    page.prev = PageLIFO;

    PageLIFO = page;
    
    return page;
end

--[[
//  arena templates for three arena shapes, but feel
//  free to add others to suit your own needs.

//  overlap between blkmax and blksize can reduce
//  the percentage of granularity induced waste,
//  as illustrated in the 16 byte and 128 byte
//  templates below.
--]]

ffi.cdef[[
typedef struct {
    unsigned int blksize;  //  allocation granularity
    unsigned int blkcnt;   //  number of blocks in the arena
    unsigned int blkmax;   //  maximum allocation to support
    Arena *arena;      //  chain of arenas with template
    Arena *scan;       //  current arena being allocated
} Template;
]]

local ArenaDefs = ffi.new("Template[4]", 
    {16, 8192, 511 },       --  16 x 8K  = 512K total
    {128, 4096, 4095 },     --  128 x 4K = 512K total
    {4096, 512, 65535 },    --  4K x 512 =  2MB total
    {0}                     --  64K and above
    );

--  allocate and initialize a new arena
--  marking an initial allocation

--void *
local varena = function(bytes, tmpl)
    if bytes < 1 then return nil end

    local xtra, blks, bits, blkmax, blksize, mapmax, mapbytes;
    local map;
    local arena;
    local page;


    --  build the arena from a table template,
    --  or make a huge arena with two blocks
    --  of one half the total request each
    blksize = tmpl.blksize
    if(blksize > 0  ) then
        blkmax = tmpl.blkmax;
        blks = tmpl.blkcnt;
    else
        xtra = band(bytes, 0xfff);
        if( xtra > 0 )  then -- round for 4K virtual memory
            bytes = bytes + 4096 - xtra;
        end

        --assert (~bytes & 1);
        blksize = bytes / 2;
        blkmax = bytes - 1;
        blks = 2;
    end

    --  block count for the initial allocation

    assert (blksize > 0);

    bits = (bytes + blksize - 1);
    bits = bits / blksize;

    --  round mapmax up to unsigned size multiple
    --  unless doing a huge block without map bits

    assert (MAP_BITS > 2);

    mapmax = blks / MAP_BITS ;
    if( mapmax > 0) then
      if( band(blks, (MAP_BITS - 1)) > 0 ) then
        mapmax = mapmax + 1;
      end
    end

    mapbytes = mapmax * ffi.sizeof("unsigned int");


    --  allocate new page on overflow of current frame
    --  or on startup
    page = PageLIFO;
    if( page ~= nil ) then
      if( page.first < mapbytes + ffi.sizeof("Page") + ffi.sizeof("Arena") ) then
        page = vframe();
      end
    else
        page = vframe();
    end

    --  allocate the arena in the frame

    page.first = page.first - mapbytes;
    map = ffi.cast("unsigned int *",(ffi.cast("char *",page) + page.first));

    page.first = page.first - ffi.sizeof("Arena");
    arena = ffi.cast("Arena *",(ffi.cast("char *",page) + page.first));

    assert (page.first >= ffi.sizeof("Page"));

    --  initialize and insert arena into template chain

    memutils.memset (arena, 0, ffi.sizeof("Arena"));
    arena.avail = blks * blksize;
    arena.blksize = blksize;
    arena.mapmax = mapmax;
    arena.blkmax = blkmax;

    arena.next = tmpl.arena;
    tmpl.arena = arena;

    if( arena.next == nil ) then
        tmpl.scan = arena;
    end

    --  allocate the arena's memory block

    arena.mem = VirtualMemory.VirtualAlloc(nil, arena.avail, MEM_COMMIT, PAGE_READWRITE);

    arena.ending = arena.mem + arena.avail;
    arena.avail = arena.avail - bits * blksize;

    if( mapbytes * CHAR_BIT < bits ) then
        return arena.mem;
    end

    --  clear the initial allocation of bits in the map

    while( bits >= MAP_BITS ) do
        map[0] = 0;
        map = map + 1; 
        bits = bits - MAP_BITS;
        mapmax = mapmax - 1;
    end

    --  and mark the rest of the map as available
    if (mapmax > 0) then
        map[0] = lshift(bnot(0), bits);
        map = map + 1;
        mapmax = mapmax - 1;
    else
        return arena.mem;
    end

    while( mapmax > 0 ) do
        map[0] = bnot(0);
        map = map + 1;
        mapmax = mapmax - 1;
    end

    return arena.mem;
end



--  mark a partial sub-byte map allocation of 7 or fewer blocks
--  of non rightmost blocks

local vmarkbyte = function(arena, val, blks, bit)

    local map = ffi.cast("unsigned int *",(arena + 1)) + arena.scan;
    local mask = rshift(UCHAR_MAX, (CHAR_BIT - blks));
    local block;

    --assert ((blks >0) and (blks < CHAR_BIT));
    --assert (val);

    --  find the available run of ones in the byte
    --  ignoring the rightmost bit, and assuming
    --  the map byte is non zero

    repeat
        val = rshift(val,1);
        bit = bit + 1; 
        --assert (bit < MAP_BITS);
    until ( bxor(band(val, mask), mask) == 0)

    --  clear the allocation bits

    arena.avail = arena.avail - blks * arena.blksize;

    map[0] = bxor(map[0], lshift(mask, bit));
    --assert(!(*map & (unsigned)mask << bit));

    block = arena.scan * MAP_BITS + bit;
    return arena.mem + block * arena.blksize;
end

--[==[
--  allocate consecutive run of blocks from the map
--  blks must be at least one

--void *
local vmarkmap (arena, run, blks, bit)

    local map = ffi.cast("unsigned *",(arena + 1)) + arena.scan
    local mask;
    local mem = arena.mem;
 
    local block = arena.scan * MAP_BITS + bit - run;
    arena.avail = arena.avail - blks * arena.blksize;
    mem = mem + block * arena.blksize;

    --  clear initial bits of hightest map allocation
    blks = blks + bit - run;
    assert (blks > 0);

    mask = rshift(bnot(0), MAP_BITS) - blks;

    if( run < bit ) then
      bit = bit - run;
      *map ^= mask ^= (lshift(1, bit) - 1);
      --assert (!(*map & mask));
      return mem;
    end

    map[0] = bxor(map[0], mask);
    map = map - 1;

    --assert (!(map[1] & mask));
    run = run - bit;

    --  clear preceeding run bits from map

    while( run >= MAP_BITS ) do
        --assert (*map == bnot(0)) 
        map[0] = 0;
        map = map - 1;
        run = run - MAP_BITS;
    end

    --assert ((map[0] | bnot(0) >> run) == bnot(0));
    map[0] = band(map[0], rshift(bnot(0), run));
    
    return mem;
end
--]==]

--  scan tables built for contents of map bytes

--  new run value: consecutive left side bits
--  (zero high order bit means no run to left)
--  (table also removes low order bit)

local ArenaRun = ffi.new("unsigned char[64]", {
1, 1, 1, 1, 1, 1, 1, 1, -- 0x80 - 0x8f
1, 1, 1, 1, 1, 1, 1, 1, -- 0x90 - 0x9f
1, 1, 1, 1, 1, 1, 1, 1, -- 0xA0 - 0xAf
1, 1, 1, 1, 1, 1, 1, 1, -- 0xB0 - 0xBf
2, 2, 2, 2, 2, 2, 2, 2, -- 0xC0 - 0xCf
2, 2, 2, 2, 2, 2, 2, 2, -- 0xD0 - 0xDf
3, 3, 3, 3, 3, 3, 3, 3, -- 0xE0 - 0xEf
4, 4, 4, 4, 5, 5, 6, 7, -- 0xF0 - 0xFf
});

-- available bits to continue existing run of consecutive blocks
--    (entries w/high order bit set are folded onto these values)
--    (low order bit is removed, and 0xFF is also removed)

local ArenaGlom = ffi.new("unsigned char[64]", {
1, 2, 1, 3, 1, 2, 1, 4, -- 0x00 - 0x0f
1, 2, 1, 3, 1, 2, 1, 5, -- 0x10 - 0x1f
1, 2, 1, 3, 1, 2, 1, 4, -- 0x20 - 0x2f
1, 2, 1, 3, 1, 2, 1, 6, -- 0x30 - 0x3f
1, 2, 1, 3, 1, 2, 1, 4, -- 0x40 - 0x4f
1, 2, 1, 3, 1, 2, 1, 5, -- 0x50 - 0x5f
1, 2, 1, 3, 1, 2, 1, 4, -- 0x60 - 0x6f
1, 2, 1, 3, 1, 2, 1, 7, -- 0x70 - 0x7f
});

-- available bits remaining after first zero
-- (without redundant low order bit)

local ArenaAfter = ffi.new("unsigned char[128]",{
0, 1, 1, 2, 1, 1, 2, 3, -- 0x00 - 0x0f
1, 1, 1, 2, 2, 2, 3, 4, -- 0x10 - 0x1f
1, 1, 1, 2, 1, 1, 2, 3, -- 0x20 - 0x2f
2, 2, 2, 2, 3, 3, 4, 5, -- 0x30 - 0x3f
1, 1, 1, 2, 1, 1, 2, 3, -- 0x40 - 0x4f
1, 1, 1, 2, 2, 2, 3, 4, -- 0x50 - 0x5f
2, 2, 2, 2, 2, 2, 2, 3, -- 0x60 - 0x6f
3, 3, 3, 3, 4, 4, 5, 6, -- 0x70 - 0x7f
1, 1, 1, 2, 1, 1, 2, 3, -- 0x80 - 0x8f
1, 1, 1, 2, 2, 2, 3, 4, -- 0x90 - 0x9f
1, 1, 1, 2, 1, 1, 2, 3, -- 0xA0 - 0xAf
2, 2, 2, 2, 3, 3, 4, 5, -- 0xB0 - 0xBf
2, 2, 2, 2, 2, 2, 2, 3, -- 0xC0 - 0xCf
2, 2, 2, 2, 2, 2, 3, 4, -- 0xD0 - 0xDf
3, 3, 3, 3, 3, 3, 3, 3, -- 0xE0 - 0xEf
4, 4, 4, 4, 5, 5, 6, 7, -- 0xF0 - 0xFf
});

--  scan an existing arena for available space
--  processing the map in byte size pieces
--  of int sized chunks using the tables

local vscan = function(arena, bytes)

    local chunk
    local map = ffi.cast("unsigned int *",(arena + 1));
    local run = 0
    local blks
    local bit;
    local nxt;

    blks = bytes + arena.blksize - 1;
    assert (arena.blksize > 0);

    blks = blks / arena.blksize;
    if( blks ~= 0 ) then
        repeat
            chunk = map[arena.scan] 
            if( chunk ~= 0) then
                for bit = 0, MAP_BITS-1, CHAR_BIT do
                    nxt = rshift(chunk, bit);
                    if (nxt ~= 0) then   -- next byte of chunk
                        if( nxt < UCHAR_MAX ) then     -- less than 8 blocks available ???
                            if( band(bnot(nxt), 1) or run + ArenaGlom[band((nxt/2), 0x3f)] < blks ) then
                                if( ArenaAfter[nxt/2] < blks ) then -- bits available in byte
                                    if( band(nxt, 0x80) ~= 0 ) then      -- establish new run
                                        run = ArenaRun[band((nxt/2), 0x3f)];
                                    else
                                        run = 0;  --  no run possible without the leading bit
                                    end
                                else          -- request of fewer than 8 blocks will fit
                                    return vmarkbyte (arena, nxt, blks, bit);
                                end
                            else    -- 8 blocks or a run spanning two or more map bytes
                                return vmarkmap (arena, run, blks, bit);
                            end
                        elseif( run + CHAR_BIT < blks ) then
                            run = run + CHAR_BIT;-- 8 more blocks still not enough
                        else             -- or, run now fits
                            return vmarkmap (arena, run, blks, bit);
                        end
                    else
                        run = 0;        -- byte is all zero bits
                    end
                end
            else
                run = 0;        -- chunk is all zero bits
            end
            arena.scan = arena.scan + 1;
        until ( arena.scan >= arena.mapmax )
    end

    arena.scan = 0;    -- next time start scan from the beginning
    return nil;
end

--  allocate a new block of size bytes
--void *
local valloc = function(bytes)

    local tmpl = ArenaDefs;
    local blkmax; 
    local doit = 2;
    local start, first;
    local mem;

    --  round request up to smallest Template blocksize

    assert (tmpl.blksize > 0);

    if( bytes < tmpl.blksize ) then
        bytes = tmpl.blksize;
    end

    --  find a suitable template, or default to the
    --  huge-block template at the end of the table
    blkmax = tmpl.blkmax
    while( blkmax > 0 ) do
        if( bytes > blkmax ) then
            tmpl = tmpl + 1;
        else
            break;
        end
        blkmax = tmpl.blkmax
    end

    --  scan existing arenas built under the template
    --  for available space, going through each arena
    --  once before giving up and building a new arena,
    --  but do the current allocating arena twice
--[==[
    local first = tmpl.arena
    if( first ~= nil ) then
        start = tmpl.scan
        if( start ~= nil ) then
            repeat
                if( tmpl.scan == start and !doit-- ) then
                    break;
                elseif ( bytes < tmpl.scan.blksize ) then
                    continue;
                elseif ( bytes > tmpl.scan.avail ) then
                    continue;
                elseif ( tmpl.scan.mapmax )  then -- scan blocks with maps
                    mem = vscan(tmpl.scan, bytes)
                    if(mem ~= nil  )then
                        return mem;
                    end
                else
                    continue;
                end
                else  -- huge arena, allocate by clearing available space
                    tmpl.scan.avail = 0
                    return tmpl.scan.mem;
                end
            until( tmpl.scan = tmpl.scan.next ? tmpl.scan.next : first );
        end
    end
--]==]

    --  build a new arena and allocate space there

    return varena (bytes, tmpl);
end


--  starting with block number, set the
--  map bits to make blocks available

local vsetmap = function(arena, block, blks)

    local mask = 0; 
    local map = ffi.cast("unsigned int *",(arena + 1)) + block / MAP_BITS;
    local max = arena.mapmax * MAP_BITS;

    assert (blks <= max - block);
    assert (block <= max);
    assert (blks > 0);

    if( block > max ) then         -- ensure sanity of starting block no.
        block = max;
    end

    if( blks > max - block ) then -- ditto for the block count
        blks = max - block;
    end

    arena.avail = arena.avail + blks * arena.blksize;

    --  set block available bits in lowest map entry of the run
    --  (these are high order bits)

    if( blks < MAP_BITS ) then    -- less than full int of bits?
        mask = rshift(bnot(0), (MAP_BITS - blks));
    else
        mask = bnot(0);
    end

    block = band(block, (MAP_BITS - 1));

    --assert (!(*map & mask << block));
    map[0] = bor(map[0],lshift(mask, block));
    map = map + 1;

    --  calculate number of blks remaining

    if( blks > MAP_BITS - block ) then
        blks = blks - MAP_BITS - block;
    else
        return nil;
    end

    --  set all block available bits for intermediate map blocks

    while( blks > MAP_BITS ) do
      assert (map[0] == 0);
      map[0] = bnot(0);
      map = map + 1;

      blks = blks - MAP_BITS;
    end

    --  set block available bits in highest map block
    --  (these are low order bits)

    --assert (!(*map & ~0U >> (MAP_BITS - blks)));
    map[0] = bor(map[0],rshift(bnot(0), (MAP_BITS - blks)));

end

--  release memory blocks into an arena

local vfree = function(mem, bytes)

    local block, entry, blks;
    local arena;
    local page;

    --  round request up to smallest Template blocksize

    assert (ArenaDefs.blksize > 0);

    if( bytes < ArenaDefs.blksize ) then
        bytes = ArenaDefs.blksize;
    end

    --  locate the correct arena
    --  by scanning all existing
    --  arena memory ranges

    assert (PageLIFO);

    page = PageLIFO

    if( page ~= nil ) then
        entry = page.first;
    else
        return;
    end

--[==[

    while( true )
      if( entry < page.size ) then
        arena = (Arena *)((char *)page + entry)
        if( arena ~= nil and  ffi.cast("char *",mem) < arena.mem ) then
            entry = entry + ffi.sizeof("Arena") + ffi.sizeof("unsigned int") * arena->mapmax;
        elseif( (char *)mem < arena.endding ) then
            break;
        else
            entry = entry + ffi.sizeof("Arena") + ffi.sizeof("unsigned int") * arena.mapmax;
        end
      elseif( assert(page->prev), page = page.prev ) then
          entry = page.first;
      else
          return;
      end
    end
--]==]
    --  huge blocks have no map, so we just mark
    --  the entire arena available and return

    if(arena.mapmax ~= 0) then
        arena.avail = arena.blkmax + 1;
        return;
    end

    --  calculate the number of blocks in the request

    assert (arena.blksize > 0);

    blks = bytes + arena.blksize - 1;
    blks = blks / arena.blksize;

    --  calculate the starting block number
    --  and set the available bits

    block = (ffi.cast("char *",mem) - ffi.cast("char *",arena.mem)) / arena.blksize;
    vsetmap (arena, block, blks);
end

--[==[
--  trim memory block to smaller new size
--  blks is oldsize, bytes is newsize

local vtrim = function(mem, blks, bytes)

Arena *arena;
Page *page;

    assert (blks >= bytes);

    --  round sizes up to smallest Template blocksize

    assert (ArenaDefs.blksize > 0);

    if( blks < ArenaDefs.blksize ) then
      blks = ArenaDefs.blksize;
    end

    if( bytes < ArenaDefs.blksize ) then
      bytes = ArenaDefs.blksize;
    end

    --  locate the correct arena by scanning
    --  all existing arena memory ranges

    assert (PageLIFO);
    
    local entry;

    if( page = PageLIFO ) then
      entry = page.first;
    else
      return;
    end

    while( true ) do
     if( entry < page.size ) then
      if( arena = (Arena *)((char *)page + entry), (char *)mem < arena.mem ) then
        entry = entry + sizeof(Arena) + sizeof(unsigned) * arena.mapmax;
      elseif( (char *)mem < arena.end )
        break;
      else
        entry = entry + sizeof(Arena) + sizeof(unsigned) * arena.mapmax;
      end
     elseif( assert (page.prev), page = page->prev )
        entry = page.first;
     else
        return;
     end
    end

    --  huge blocks have no map; do nothing to resize these.

    if( arena.mapmax == 0) then
        return false;
    end

    --  calculate the number of blocks in the new size

    assert (arena.blksize > 0);

    bytes = bytes + arena.blksize - 1;
    bytes = bytes / arena.blksize;

    --  calculate the number of blocks in the original block, the
    --  starting block number, and the change in block counts

    local block = (ffi.cast("char *",mem) - ffi.cast("char *",arena.mem)) / arena.blksize;
    blks = blks + arena.blksize - 1;
    blks = blks / arena.blksize;

    --  free extra blocks

    if( blks > bytes ) then
      vsetmap (arena, block + bytes, blks - bytes);
    end
end
--]==]

return {
    valloc = valloc,
    varena = varena,
    vfree = vfree,
    vmarkbyte = vmarkbyte,
    vmarkmap = vmarkmap,
    vscan = vscan,
    vsetmap = vsetmap,
    vtrim = vtrim,
}
