/* tinynx - a pure c89 single-file implementation of the nx format
-------------------------------------------------------------------
this is free and unencumbered software released into the
public domain.

refer to the attached UNLICENSE or http://unlicense.org/

credits to retep998, angelsl and everyone else who partecipated
in writing the nx format specification: http://nxformat.github.io/

LZ4 - Fast LZ compression algorithm
is Copyright (C) 2011-2017, Yann Collet.
-------------------------------------------------------------------
#define NX_IMPLEMENTATION and include this file.
if multiple compilation units need to include/use nx, only define
OPPAI_IMPLEMENTATION in one of them.

see the interface below this comment for detailed documentation

example program (lists children nodes of a given node):

    #define NX_IMPLEMENTATION
    #define NX_NOBITMAP
    #include "nx.c"

    int main(int argc, char* argv[])
    {
        struct nx_file file;
        struct nx_node node, child;

        uint32_t i;
        char buf[0x10000];

        nx_map(&file, argv[1]);
        nx_get(&file, argv[2], &node);

        for (i = 0; i < node.nchildren; ++i)
        {
            nx_node_at(&file, node.first_child_id + i, &child);
            nx_string_at(&file, child.name_id, buf);

            printf("[%s] %s\n", nx_typestr(child.type), buf);
        }

        return 0;
    }

compile and use:

    $ gcc example.c
    $ ./a.out /path/to/Map.nx /
    [none] Back
    [none] Effect.img
    [none] Map
    [none] MapHelper.img
    [none] Obj
    [none] Physics.img
    [none] Tile
    [none] WorldMap

define toggles:
    NX_MONOLITHIC makes every function static to maximise the
        chance of functions getting inlined or optimized out
        when working in a single complication unit.
        this will cause warnings about unused static functions
        from the library if compiling with -Wall, but it's safe
        to ignore them
    NX_NOBITMAP disables bitmap decompression and all lz4 code.
        this speeds up compilation and shrinks code size
    NX_IMPLEMENTATION includes the implementation. not definining
        this only includes the interface/header
    NX_NOSTDINT for platforms that don't have stdint.h (not yet
        implemented)                                             */

#define NX_VERSION_MAJOR 1
#define NX_VERSION_MINOR 2
#define NX_VERSION_PATCH 3

#ifndef NX_NOSTDINT
#include <stdint.h>
#else
#error "TODO: implement non-stdint types"
#endif

#ifdef _WIN32
#include <Windows.h>
#endif

#ifndef NX_MONOLITHIC
#define nxapi
#else
#define nxapi static
#endif

#define NX_ESYNTAX (-1)
#define NX_ETRUNCATED (-2)
#define NX_ENOTIMPLEMENTED (-3)
#define NX_EIO (-4)
#define NX_EFORMAT (-5)
#define NX_EOOM (-6)
#define NX_ENOTFOUND (-7)

/* returns a human readable description of the error */
nxapi char const* nx_errstr(int32_t err);

/* a memory mapped file, used internally to memory map nx files */
struct os_mapping
{
    void* base;
    uint64_t size;

#ifdef _WIN32
    HANDLE hfile;
    HANDLE hmapping;
#else
    int fd;
#endif
};

nxapi int32_t os_mmap(struct os_mapping* m, char const* path);
nxapi void os_munmap(struct os_mapping* m);

struct nx_file
{
    struct os_mapping map;
    uint32_t nnodes;
    uint64_t nodes_offset;
    uint32_t nstrings;
    uint64_t strings_offset;
    uint32_t nbitmaps;
    uint64_t bitmaps_offset;
    uint32_t naudio;
    uint64_t audio_offset;
};

/* memory map .nx file and read header. returns 0 on success
and < 0 on failure */
nxapi int32_t nx_map(struct nx_file* f, char const* path);
nxapi void nx_unmap(struct nx_file* f);

/* copies the string into buf and truncates if it exceeds bufsize.
ensures that buf is correctly zero-terminated.
returns the number of bytes copied (without the null terminator),
or < 0 on failure. */
nxapi int32_t nx_string_at_n(struct nx_file* f, uint32_t id,
    char* buf, uint16_t bufsize);

/* same as nx_string_at_n but doesn't check for buffer length */
nxapi int32_t nx_string_at(struct nx_file* f, uint32_t id,
    char* buf);

#ifndef NX_NOBITMAP
/* decompresses a bitmap and stores it in buf.
returns number of bytes written to buf or < 0 on error */
nxapi int32_t nx_bitmap_at(struct nx_file* f, uint32_t id,
    uint8_t* buf, int32_t bufsize);
#endif

/* returns a pointer to the raw audio data, including the 82-byte
wz header. sets error to < 0 and returns 0 on failure */
nxapi uint8_t const* nx_audio_at(struct nx_file* f, uint32_t id,
    int32_t* error);

struct nx_node
{
    uint32_t id;
    uint32_t name_id;
    uint32_t first_child_id;
    uint16_t nchildren;
    uint16_t type;
    uint8_t const* data;
};

nxapi
int32_t nx_node_at(struct nx_file* f, uint32_t id,
    struct nx_node* node);

/* finds a node by path, where path is a forward-slash separated
series of node names. returns 0 on success and < 0 on failure */
nxapi int32_t nx_get(struct nx_file* f, char const* path,
    struct nx_node* node);

/* same as nx_get but starts from node with id parent_id */
nxapi int32_t nx_get_p(struct nx_file* f, char const* path,
    uint32_t parent_id, struct nx_node* node);

#define NX_NONE 0
#define NX_INT64 1
#define NX_REAL 2
#define NX_STRING 3
#define NX_VECTOR 4
#define NX_BITMAP 5
#define NX_AUDIO 6

/* returns a human readable string for the node type */
nxapi char const* nx_typestr(uint16_t type);

/* ############################################################# */
/* #################### END OF THE HEADER ###################### */
/* ############################################################# */

#ifdef NX_IMPLEMENTATION
#include <stdio.h>
#include <stdlib.h> /* bsearch */
#include <stdarg.h> /* va_list */
#include <string.h> /* mem{cmp,cpy,...} */

#define internalfn static
#define mymin(a, b) ((a) < (b) ? (a) : (b))

internalfn
int info(char const* fmt, ...)
{
    int res;

    va_list va;
    va_start(va, fmt);
    res = vfprintf(stderr, fmt, va);
    va_end(va);

    return res;
}

nxapi
char const* nx_errstr(int32_t err)
{
    switch (err)
    {
        case NX_ESYNTAX: return "syntax error";
        case NX_ETRUNCATED: return "the data is incomplete";
        case NX_ENOTIMPLEMENTED:
            return "this feature is not implemented";
        case NX_EIO: return "i/o error";
        case NX_EFORMAT: return "invalid input format";
        case NX_EOOM: return "out of memory";
        case NX_ENOTFOUND: return "no such file or directory";
    }

    info("W: got unknown error %d\n", err);
    return "unknown error";
}

/* ------------------------------------------------------------- */

/* little endian utils */

internalfn
uint16_t read2(uint8_t const* p) {
    return (uint16_t)(p[0] | p[1] << 8);
}

internalfn
int32_t read2p(uint8_t const* p, uint16_t* pvalue)
{
    *pvalue = read2(p);
    return 2;
}

internalfn
uint32_t read4(uint8_t const* p)
{
    return (uint32_t)(p[0] | p[1] << 8 |
        p[2] << 16 | p[3] << 24);
}

internalfn
int32_t read4p(uint8_t const* p, uint32_t* pvalue)
{
    *pvalue = read4(p);
    return 4;
}

internalfn
uint64_t read8(uint8_t const* p)
{
    return (uint64_t)p[0] | (uint64_t)p[1] << 8 |
        (uint64_t)p[2] << 16 | (uint64_t)p[3] << 24 |
        (uint64_t)p[4] << 32 | (uint64_t)p[5] << 40 |
        (uint64_t)p[6] << 48 | (uint64_t)p[7] << 56;
}

internalfn
int32_t read8p(uint8_t const* p, uint64_t* pvalue)
{
    *pvalue = read8(p);
    return 8;
}

internalfn
double read_double(uint8_t const* p)
{
    uint64_t v = read8(p);
    double* pd = (double*)&v;
    return *pd;
}

internalfn
int32_t read_double_p(uint8_t const* p, double* pvalue)
{
    *pvalue = read_double(p);
    return 8;
}

/* ------------------------------------------------------------- */

#ifndef NX_NOBITMAP
/* this is all copypasted from lz4.c */

#define likely(expr) expect((expr) != 0, 1)
#define unlikely(expr) expect((expr) != 0, 0)

#if (defined(__GNUC__) && (__GNUC__ >= 3)) || \
    (defined(__INTEL_COMPILER) && (__INTEL_COMPILER >= 800)) || \
    defined(__clang__)
#  define expect(expr,value) (__builtin_expect ((expr),(value)))
#else
#  define expect(expr,value) (expr)
#endif

#define ML_BITS  4
#define ML_MASK  ((1U<<ML_BITS)-1)
#define RUN_BITS (8-ML_BITS)
#define RUN_MASK ((1U<<RUN_BITS)-1)

#define MINMATCH 4
#define LASTLITERALS 5
#define WILDCOPYLENGTH 8
#define MFLIMIT (WILDCOPYLENGTH + MINMATCH)

internalfn
void LZ4_copy8(void* dst, void const* src) {
    memcpy(dst, src, 8);
}

internalfn
void LZ4_write32(void* memptr, uint32_t value) {
    memcpy(memptr, &value, sizeof(value));
}

internalfn
void LZ4_wild_copy(void* dstptr, void const* srcptr, void* dstend)
{
    uint8_t* d = (uint8_t*)dstptr;
    uint8_t const* s = (uint8_t const*)srcptr;
    uint8_t* const e = (uint8_t*)dstend;

    do { LZ4_copy8(d, s); d += 8; s += 8; } while (d < e);
}

internalfn
int LZ4_decompress_safe(char const* src,
    char* dst, uint32_t src_size, uint32_t output_size)
{
    uint8_t const* ip = (uint8_t const*) src;
    uint8_t const* const iend = ip + src_size;

    uint8_t* op = (uint8_t*) dst;
    uint8_t* const oend = op + output_size;
    uint8_t* cpy;

    unsigned const dec32table[] = { 0, 1, 2, 1, 4, 4, 4, 4 };
    int const dec64table[] = { 0, 0, 0, -1, 0, 1, 2, 3 };

    /* special cases */
    if (unlikely(output_size == 0))
        return ((src_size == 1) && (*ip == 0)) ? 0 : -1;

    /* main loop: decode sequences */
    while (1)
    {
        size_t length;
        uint8_t const* match;
        size_t offset;

        /* get literal length */
        unsigned const token = *ip++;

        if ((length = (token>>ML_BITS)) == RUN_MASK)
        {
            unsigned s;

            do {
                s = *ip++;
                length += s;
            }
            while (likely(ip < iend - RUN_MASK) & (s == 255));

            if (unlikely((uintptr_t)op + length < (uintptr_t)op))
                goto _output_error; /* overflow detection */

            if (unlikely((uintptr_t)ip + length < (uintptr_t)ip))
                goto _output_error; /* overflow detection */
        }

        /* copy literals */
        cpy = op+length;

        if (cpy > (oend - MFLIMIT) ||
            (ip + length) > iend - (2 + 1 + LASTLITERALS))
        {
            if ((ip + length != iend) || (cpy > oend))
                goto _output_error;
                /* error : input must be consumed */

            memcpy(op, ip, length);
            ip += length;
            op += length;
            break;
            /* necessarily eof, due to parsing restrictions */
        }

        LZ4_wild_copy(op, ip, cpy);
        ip += length; op = cpy;

        /* get offset */
        offset = read2(ip); ip += 2;
        match = op - offset;

        if (unlikely(match < (uint8_t const*)dst))
            goto _output_error;
            /* error : offset outside buffers */

        LZ4_write32(op, (uint32_t)offset);
        /* costs ~1%; silence an msan warning when offset == 0 */

        /* get matchlength */
        length = token & ML_MASK;

        if (length == ML_MASK)
        {
            unsigned s;

            do
            {
                s = *ip++;
                if (ip > iend - LASTLITERALS) goto _output_error;
                length += s;
            }
            while (s == 255);

            if (unlikely((uintptr_t)op + length < (uintptr_t)op))
                goto _output_error; /* overflow detection */
        }

        length += MINMATCH;

        /* copy match within block */
        cpy = op + length;

        if (unlikely(offset < 8))
        {
            int const dec64 = dec64table[offset];
            op[0] = match[0];
            op[1] = match[1];
            op[2] = match[2];
            op[3] = match[3];
            match += dec32table[offset];
            memcpy(op + 4, match, 4);
            match -= dec64;
        } else {
            LZ4_copy8(op, match); match+=8;
        }

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
        op=cpy;   /* correction */
    }

    /* end of decoding */
    return (int)(((char*)op) - dst);
    /* n of output bytes decoded */

    /* overflow error detected */
_output_error:
    return (int)(-(((char const*)ip) - src)) - 1;
}
#endif

#ifdef _WIN32
/* windows ----------------------------------------------------- */
internalfn
void printgle(char const* msg)
{
    char const* buf = 0;
    uint32_t nchars = FormatMessageA(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        0, GetLastError(),
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (char*)&buf, 0, 0);

    if (!nchars) {
        buf = "(could not format error message)";
    }

    fprintf(stderr, "%s: %s\n", msg, buf);

    if (nchars) {
        LocalFree(buf);
    }
}

internalfn
int32_t os_mmap(struct os_mapping* m, char const* path)
{
    LARGE_INTEGER li;

    m->hfile = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ,
        0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

    if (m->hfile == INVALID_HANDLE_VALUE) {
        printgle("CreateFileA");
        return NX_EIO;
    }

    if (!GetFileSizeEx(m->hfile, &li)) {
        printgle("GetFileSizeEx");
        return NX_EIO;
    }

    m->hmapping =
        CreateFileMappingA(m->hfile, 0, PAGE_READONLY, 0, 0, 0);
    if (!m->hmapping) {
        printgle("CreateFileMapping");
        return NX_EIO;
    }

    m->base = MapViewOfFile(m->hmapping, FILE_MAP_READ, 0, 0, 0);
    if (!m->base) {
        printgle("MapViewOfFile");
        return NX_EIO;
    }

    m->size = (int64_t)li.HighPart << 32 |
        (int64_t)li.LowPart;

    return 0;
}

internalfn
void os_munmap(struct os_mapping* m)
{
    UnmapViewOfFile(m->base);
    CloseHandle(m->hmapping);
    CloseHandle(m->hfile);
    m->base = 0;
    m->hmapping = 0;
    m->hfile = INVALID_HANDLE_VALUE;
}
#else
/* linux/others ------------------------------------------------ */
#include <unistd.h> /* close */
#include <fcntl.h> /* open */
#include <sys/mman.h> /* mmap */
#include <sys/stat.h> /* stat */

nxapi
int32_t os_mmap(struct os_mapping* m, char const* path)
{
    struct stat st;

    m->fd = open(path, O_RDONLY);
    if (m->fd < 0) {
        perror("open");
        return NX_EIO;
    }

    if (stat(path, &st) < 0) {
        perror("stat");
        return NX_EIO;
    }

    m->base = mmap(0, (size_t)st.st_size, PROT_READ, MAP_SHARED,
        m->fd, 0);

    if (m->base == (void*)-1) {
        perror("mmap");
        return NX_EIO;
    }

    m->size = (uint64_t)st.st_size;

    return 0;
}

nxapi
void os_munmap(struct os_mapping* m)
{
    munmap(m->base, (size_t)m->size);
    close(m->fd);
    m->base = 0;
    m->size = 0;
    m->fd = -1;
}
#endif

/* ------------------------------------------------------------- */

const uint8_t nx_magic[4] = { 0x50, 0x4B, 0x47, 0x34 }; /* PKG4 */

#define NX_HEADER_SIZE ((uint64_t)52)
#define NX_NODE_SIZE ((uint64_t)20)

nxapi
int32_t nx_map(struct nx_file* f, char const* path)
{
    int32_t res;
    uint8_t const* p;

    res = os_mmap(&f->map, path);
    if (res < 0) {
        return res;
    }

    if (f->map.size < NX_HEADER_SIZE) {
        info("file is smaller than the nx header\n");
        return NX_ETRUNCATED;
    }

    p = (uint8_t const*)f->map.base;

    if (memcmp(p, nx_magic, 4)) {
        info("magic string not found (found '%4s' instead)\n", p);
        return NX_EFORMAT;
    }

    p += 4;

    p += read4p(p, &f->nnodes);
    p += read8p(p, &f->nodes_offset);
    p += read4p(p, &f->nstrings);
    p += read8p(p, &f->strings_offset);
    p += read4p(p, &f->nbitmaps);
    p += read8p(p, &f->bitmaps_offset);
    p += read4p(p, &f->naudio);
    p += read8p(p, &f->audio_offset);

    if (f->nodes_offset + f->nnodes * NX_NODE_SIZE > f->map.size ||
        f->strings_offset + f->nstrings * 8 > f->map.size ||
        f->bitmaps_offset + f->nbitmaps * 8 > f->map.size ||
        f->audio_offset + f->naudio * 8 > f->map.size)
    {
        info("out of bounds offsets in the header\n");
        return NX_ETRUNCATED;
    }

    return 0;
}

nxapi
void nx_unmap(struct nx_file* f) {
    os_munmap(&f->map);
}

nxapi
char const* nx_typestr(uint16_t type)
{
    switch (type)
    {
    case NX_NONE: return "none";
    case NX_INT64: return "int64";
    case NX_REAL: return "real";
    case NX_STRING: return "string";
    case NX_VECTOR: return "vector";
    case NX_BITMAP: return "bitmap";
    case NX_AUDIO: return "audio";
    }

    return "unknown";
}

nxapi
int32_t nx_node_at(struct nx_file* f, uint32_t id,
    struct nx_node* node)
{
    uint8_t const* p;

    if (id >= f->nnodes) {
        info("out of bounds node id %u\n", id);
        return NX_ETRUNCATED;
    }

    p = (uint8_t const*)f->map.base;
    p += f->nodes_offset + id * NX_NODE_SIZE;

    node->id = id;
    p += read4p(p, &node->name_id);
    p += read4p(p, &node->first_child_id);
    p += read2p(p, &node->nchildren);
    p += read2p(p, &node->type);
    node->data = p;

    return 0;
}

nxapi
int32_t nx_string_at_n(struct nx_file* f, uint32_t id, char* buf,
    uint16_t bufsize)
{
    uint8_t const* p;
    uint16_t len;

    if (id >= f->nstrings) {
        info("out of bounds string id %u\n", id);
        return NX_ETRUNCATED;
    }

    p = (uint8_t const*)f->map.base;
    p += f->strings_offset + id * 8;
    p = (uint8_t const*)f->map.base + read8(p);

    p += read2p(p, &len);
    len = mymin((uint16_t)(bufsize - 1), len);
    memcpy(buf, p, len);
    buf[len] = 0;

    return len;
}

nxapi
int32_t nx_string_at(struct nx_file* f, uint32_t id, char* buf)
{
    uint8_t const* p;
    uint16_t len;

    if (id >= f->nstrings) {
        info("out of bounds string id %u\n", id);
        return NX_ETRUNCATED;
    }

    p = (uint8_t const*)f->map.base;
    p += f->strings_offset + id * 8;
    p = (uint8_t const*)f->map.base + read8(p);

    p += read2p(p, &len);
    memcpy(buf, p, len);
    buf[len] = 0;

    return len;
}

#ifndef NX_NOBITMAP
nxapi
int32_t nx_bitmap_at(struct nx_file* f, uint32_t id, uint8_t* buf,
    int32_t bufsize)
{
    uint8_t const* p;
    uint32_t compressed_len;
    int32_t result;

    if (id >= f->nbitmaps) {
        info("out of bounds bitmap id %u\n", id);
        return NX_ETRUNCATED;
    }

    p = (uint8_t const*)f->map.base;
    p += f->bitmaps_offset + id * 8;
    p = (uint8_t const*)f->map.base + read8(p);

    p += read4p(p, &compressed_len);
    result = LZ4_decompress_safe((char const*)p, (char*)buf,
        compressed_len, (uint32_t)bufsize);
    if (result < 0) {
        info("LZ4_decompress_safe failed with %d\n", result);
        return NX_EFORMAT;
    }

    return result;
}
#endif

nxapi
uint8_t const* nx_audio_at(struct nx_file* f, uint32_t id,
    int32_t* error)
{
    uint8_t const* p;

    if (id >= f->naudio) {
        info("out of bounds audio id %u\n", id);
        *error = NX_ETRUNCATED;
        return 0;
    }

    p = (uint8_t const*)f->map.base;
    p += f->audio_offset + id * 8;
    p = (uint8_t const*)f->map.base + read8(p);
    *error = 0;

    return p;
}

/* TODO: make the bsearch less hacky, especially the const cast */

/* wrapper struct and compare function to perform bsearch on
nodes by name */
struct nx_bsearch
{
    int32_t err;
    struct nx_file* file;
    struct nx_node* node;
    char const* element;
    uint16_t element_len;
    char buf[0x10000];
};

internalfn
int nx_bsearch_cmp(void const* pkey, void const* pelem)
{
    int res;
    struct nx_bsearch* key = (struct nx_bsearch*)pkey;
    uint32_t id = (uint32_t)(uintptr_t)pelem;
    uint16_t child_len;

    key->err = nx_node_at(key->file, id, key->node);
    if (key->err < 0) {
        info("nx_node_at failed inside bsearch\n");
        return 0;
    }

    /* TODO: don't copy string */
    key->err = nx_string_at(key->file, key->node->name_id,
        key->buf);
    if (key->err < 0) {
        info("nx_string_at failed inside bsearch\n");
        return 0;
    }

    child_len = (uint16_t)strlen(key->buf);

    res = strncmp(key->element, key->buf, child_len);
    if (!res) {
        return (int)key->element_len - (int)child_len;
    }

    return res;
}

nxapi
int32_t nx_get(struct nx_file* f, char const* path,
    struct nx_node* node)
{
    return nx_get_p(f, path, 0, node);
}

nxapi
int32_t nx_get_p(struct nx_file* f, char const* path,
    uint32_t parent_id, struct nx_node* node)
{
    int32_t res;
    struct nx_bsearch search;

    res = nx_node_at(f, parent_id, node);
    if (res < 0) {
        return res;
    }

    for (; *path == '/'; ++path);

    search.file = f;
    search.node = node;

    while (*path)
    {
        uint32_t i;

        search.element = path;
        for (; *path && *path != '/'; ++path);
        search.element_len = (uint16_t)(path - search.element);
        for (; *path == '/'; ++path);

        if (!search.element_len) {
            break;
        }

        search.err = 0;

        /* node 0 is always the root so we're good to go */
        i = (uint32_t)(uintptr_t)
                bsearch(
                    &search,
                    (void*)(uintptr_t)node->first_child_id,
                    node->nchildren, 1, nx_bsearch_cmp
                );

        if (search.err < 0) {
            return search.err;
        }

        if (!i) {
            return NX_ENOTFOUND;
        }

        res = nx_node_at(f, i, node);
        if (res < 0) {
            return res;
        }
    }

    return 0;
}
#endif /* NX_IMPLEMENTATION */
