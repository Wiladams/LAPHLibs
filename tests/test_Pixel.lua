package.path = package.path..";../?.lua"

local ffi = require ("ffi")
local c99 = require ("c99_types")
local PX = require("pixel")

local function testRGB()
local RGB = PX.RGB
local RGB_v = PX.RGB_v


-- Create a basic RGB Pixel
p1 = RGB(23, 24, 34)	-- element constructor
p2 = RGB(p1)			-- Using a copy constructor
p2.Green = 55
print("P1: ", p1)
print("P2: ", p2)

-- Create an array of RGB Pixels
local p1arr = RGB_v(100)
print(ffi.sizeof(p1arr))

-- Copy value of pixel into array
print("BEFORE: ", p1arr[3])
p1arr[3] = p1;
print(" AFTER: ", p1arr[3])
end

-- Create a large array of Pixels
local fb = RGB_v(320*240)

testRGB();

