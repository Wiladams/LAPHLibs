local ffi = require ("ffi")
local bit = require("bit")
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift
local ror = bit.ror

--	right rotate bits
function rotate (what, bits)
	return bor(rshift(what, bits), lshift(what, (32 - bits)));
end


print(ror(234,2))
print(rotate(234, 2))

io.write(string.format("0x%x\n",bit.ror(0x12345678, 12)))
io.write(string.format("0x%x\n",rotate(0x12345678, 12)))
