

FILE *Out = stdout;
FILE *In = stdin;

char *Buff[5000];
char Line[80000];

local Arena = require("arena");

local Allocator = {}

Allocator.malloc = function(bytes)
        size_t *ans = valloc (bytes + sizeof(size_t));

        *ans++ = bytes;
        return ans;
end

Allocator.free = function(mem)
  local size = ffi.cast("size_t *", mem);

  if( size = (size_t *)mem ) then
    size = size - 1;
    vfree (size, *size + sizeof(size_t));
  end
end

Allocator.msizeof = function(mem)
  local size = ffi.cast("size_t *", mem);

  if( size = (size_t *)mem ) then
    return *--size;
  end

  return 0;
end

Allocator.calloc = function(size_t ele, size_t num)
    size_t xtra;
    void *ans;

    if( xtra = ele % ffi.sizeof("unsigned int") - 1 ) then
        ele = ele + ffi.sizeof("unsigned int") - xtra;
    end

    ans = Allocator.malloc (ele * num);
    memutils.memset (ans, 0, ele * num);
    
    return ans;
end

Allocator.realloc = function(mem, size)

    local old = ffi.cast("size_t *", mem);
    void *ans;

    if( old ~= 0 ) then
        if( *--old >= size ) then
            return vtrim (old, *old, size), *old = size, mem;
        end
    end

    ans = Allocator.malloc(size);

    if( old )
        memcpy (ans, mem, *old), vfree (old, *old + sizeof(size_t));

    return ans;
end

local blkaddrs = function(arena, idx)

  local mem = arena.mem + idx * MAP_BITS * arena.blksize;
  unsigned *map = (unsigned *)(arena + 1) + idx;
  local bit;

  for( bit = 0; bit < MAP_BITS; bit++ ) do
    if( !(*map >> bit & 1) ) then
      fprintf (stderr, "block %x not freed\n", mem + bit * arena->blksize);
    end
  end
end

main = function(argc, argv)

  local usemalloc = false;
  local check = 0;
  local count = 0;
  local debug = 0;
  local len, idx;

    --  process any program options present

    if( argc > 1 )
      if( argv[1][0] == '-' )
        for( argc--, argv++; *++(*argv); )
          switch( **argv | 0x20 ) {
          case 'm': usemalloc++;    break;
          case 'd': debug++;        break;
          case 'c': check++;        break;
          }

    //  open input and output files if present

    if( argc > 1 )
      if( !(In = fopen (argv[1], "r")) )
        return 1;

    if( argc > 2 )
      if( !(Out = fopen (argv[2], "w")) )
        return 1;

    // scramble the input as the test plan

    while( fgets (Line, sizeof(Line), In) ) {
      if( count < 5000 )
        idx = count++;
      else {
        idx = (unsigned)rand() % count;
        len = strlen(Buff[idx]);

        if( debug )
          fprintf(stderr, "free %.6d %x\n", len + 1, Buff[idx]);

        fwrite (Buff[idx], len, 1, Out);
        usemalloc ? free (Buff[idx]) : vfree (Buff[idx], len + 1);
      }

      len = strlen (Line);
      Buff[idx] = usemalloc ? malloc (len + 1) : valloc (len + 1);

      if( debug )
        fprintf(stderr, "req  %.6d %x\n", len + 1, Buff[idx]);

      memcpy (Buff[idx], Line, len + 1);
    }

    while( count-- ) {
        len = strlen (Buff[count]);
        fwrite (Buff[count], len, 1, Out);
        usemalloc ? free (Buff[count]) : vfree (Buff[count], len + 1);

        if ( debug )
          fprintf(stderr, "free %.6d %x\n", len + 1, Buff[count]);
    }

    fclose (Out);
    fclose (In);

    //  ensure all bits were reset in all arenas

    if( check ) {
    unsigned entry, idx;
    Arena *arena;
    Page *page;

      if( page = PageLIFO ) do
        for( entry = page->first; entry < page->size; entry += sizeof(Arena) + arena->mapmax * sizeof(unsigned) )
          for( arena = (Arena *)((char *)page + entry), idx = 0; idx < arena->mapmax; idx++ )
            if( ((unsigned *)(arena + 1))[idx] != ~0U )
                blkaddrs(arena, idx);
      while( page = page->prev );
    }
end

