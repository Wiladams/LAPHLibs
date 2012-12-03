package.path = package.path..";../?.lua";

local ffi = require "ffi"

require "MD5"

s0='message digest'
s1='abcdefghijklmnopqrstuvwxyz'
s2='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
s3='1234567890123456789012345678901234567890'
 ..'1234567890123456789012345678901234567890'

s4='Test vector from febooti.com'
s5 = 'The quick brown fox jumps over the lazy dog'
s6 = 'The quick brown fox jumps over the lazy dog.'

 -- Test the simple digest form
 -- http://tools.ietf.org/html/rfc1321

assert(md5('')		=='d41d8cd98f00b204e9800998ecf8427e')
assert(md5('a')		=='0cc175b9c0f1b6a831c399e269772661')
assert(md5('abc')	=='900150983cd24fb0d6963f7d28e17f72')
assert(md5(s0)		=='f96b697d7cb7938d525a2f31aaf161d0')
assert(md5(s1)		=='c3fcd3d76192e4007dfb496cca67e13b')
assert(md5(s2)		=='d174ab98d277d9f5a5611c2c9f419d9f')
assert(md5(s3)		=='57edf4a22be3c955ac49da2e2107b67a')
assert(md5(s4)		=='500ab6613c6db7fbd30c62f5ff573d0f')

-- http://en.wikipedia.org/wiki/MD5
assert(md5(s5)		=='9e107d9d372bb6826bd81d3542a419d6')
assert(md5(s6)		=='e4d909c290d0fb1ca068ffaddf22cbd0')

print("PASSED");

s7 = "abcabcabcabcabca"
print(md5(s7));
