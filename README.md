LAPHLibs
========

Lua Application Programming Helper Libraries

This is a repository of things I have found to be useful
while programming in LuaJIT.  

In most cases, the routines use features that are very specific to the LuaJIT variant of Lua.  In particular, the LuaJIT FFI feature is heavily used.  This gives many of the routines a fairly familiar 'C' look and feel, but they take on some of the better characteristics of Lua, namely memory management.


This set of functions is constantly evolving as LuaJIT itself improves, as well as my own knowledge of how best to use it.

Current: Works against LUAJIT git HEAD as of 25/09/2012


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

