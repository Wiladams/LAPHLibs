LAPHLibs
========

Lua Application Programming Helper Libraries (LAPHLibs)

This is a repository of things I have found to be useful
while programming using LuaJIT.  As it seems to get some usage, I touch the files every once in a while when I find bugs, or better ways of doing things.

As the purpose of most of these routines are to offer some amount of function typically found in standard C libraries, there is at least usage of bit operations, memory manipulation, and the like.  For most of these cases, the LuaJIT ffi and "bit" modules are used.  So, this code is not necessarily meant for usage with vanilla Lua.

In cases where 'C' functions are being supported, it's important to note the memory allocation strategy.  For the most part, the 'C' semantics are utilized.  That is, in the case of 'strdup', for example, memory for the new string is allocated using malloc, and not ffi.new.  This means that whichever code was responsible for calling strdup in the first place will need to call 'free()' when they want to free up the string.  Such functions are primarily meant for interop with C library routines that accept a "char *", and will then take over ownership of that memory.  In most cases when the function is not going to hold onto the pointer ("const char *"), this string function should not be used.



The original sets of routines came directly out of the earliest projects where I was learning to use the LuaJIT ffi mechanism.  As such, they were kind of rough, and a hodge podge of styles and usefulness.  Over time, various of the routines have been surpassed by better implementations in various projects, or by functions being implemented in the LuaJIT compiler itself.  They remain in the library as useful
history and training.


Current: Works against LUAJIT git HEAD as of 15 Jun 2015


ascii.lua
=========
This file contains a table of the ASCII character set, with numeric values and descriptions.  There are routines to create constant values from the table.

bencode.lua
===========
Implementation of the bencode format, which is used to encode/decode torrent files.

BinaryStream.lua
================
A 'class' that can deal with reading and writing of binary values from/to a stream.  You can configure the stream to deal with a big or little endian source.

BitBang.lua
===========
Lowest level bit twiddling.  Builds upon the bitops
allowing the getting/setting of bit values within a larger
array of values.

c99_types.lua
=============
Helper support for types typically found in stdint.h

cctype.lua
==========
Implementation of the isxxx() character classification functions typically found in the libc libraries.  These routines operate on numbers, and return boolean values.

CRC32.lua
=========
Implementation of a CRC32 routine

httpheaders.lua
===============
A simple Lua table containing HTTP headers.  The table contains information as to whether the header is used for requests, responses, or both.  This simple table can be used directly, or turned into another form, depending on your requirements.

limits.lua
==========
Values for various limits on numeric values

LUXL.lua
========
Implementation of very low level XML lexer/parser.  This is not a conformant validating XML parser, but it's enough to get the job done on typical .xml configuration files, and many data streams.

This implementation does no memory allocations.  It returns pointers and sizes as a result of the lexing activities.

math_matrix
===========
Implementation of matrix operations.  With this single file, you can create reasonably sized matrices (and single dimension vectors) and give them a specific base type (int, double, float, etc).  Very convenient routines such as dot, cross, determinant, inverse, multiply, etc.  Some convenient types such as mat3, mat4 already defined.

MD5.lua
=======
Implementation of the MD5 hash algorithm

MemoryStream.lua
================
Implementation of a streaming interface over a chunk of memory

memutils.lua 
============
contains several routines that have
C equivalents, such as memset, memcpy, memcmp, memchr, memmove.  Also contains a few convenience functions related to dealing
with chunks of memory.

mime.lua
========
Contains a table and function that maps between a file extension and the appropriate mime type.

mimetypes.lua
=============
A simple Lua table which contains mime type information.

stringzutils.lua
================ 
Contains a set of functions that deal with 
null terminated strings.  All the typical security hole opening
functions such as strcpy, strcmp are there, as well as their 
marginally more secure counterparts such as strlcpy, and strlcat.

strtoul.lua
===========
Turns a string value into a number value.  Operates on a pointer to a string value, so it does not require the source to be a Lua String.

