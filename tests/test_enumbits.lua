--test_enumbits.lua
package.path = package.path..";../?.lua"
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor

local enumbits = require("enumbits")

local tbl = {
	LOWEST = lshift(1,0);
	MEDIUM = lshift(1,14);
	HIGHEST = lshift(1,31);
}



local function printBits(bitsValue)
	for _, name in enumbits(bitsValue, tbl) do
		print(name)
	end
end

printBits(lshift(1,0))
printBits(lshift(1,1))
printBits(lshift(1,31))