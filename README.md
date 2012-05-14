LAPHLibs
========

Lua Application Programming Helper Libraries

This is a repository of things I have found to be useful
while programming in LuaJIT.  In particular, there are
a number of functions that are useful when you're programming
using the FFI.

BitBang.lua  - Lowest level bit twiddling.  Builds upon the bitops
allowing the getting/setting of bit values within a larger
array of values.

MD5.lua - Implementation of the MD5 hash algorithm

memutils.lua - contains several routines that have
C equivalents, such as memset, memcpy, memcmp, memchr, memmove.
Also contains a few convenience functions related to dealing
with chunks of memory.

stringzutils.lua - Contains a set of functions that deal with 
null terminated strings.  All the typical security hole opening
functions such as strcpy, strcmp are there, as well as their 
marginally more secure counterparts such as strlcpy, and strlcat.



