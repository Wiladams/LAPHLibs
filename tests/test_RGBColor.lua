
package.path = package.path..";../?.lua"

require ("maths")
local round = math.round

local ColorSpace = require ("ColorSpace")

RGBToColor = ColorSpace.RGBToRGBColor

testrgb = function()
	snow = RGBToColor(255,255,0);
	bisque = RGBToColor(255,228,196);

	print("snow: ", snow)
	print("bisque", bisque)
end

testHSL = function()
	local snow = RGBToColor(255,255,0);
	local h1 = HSLColor();
	local h2 = HSLColor(20, 0.3, 0.8)
	local h3 = HSLColor(snow)
	local h4 = HSLColor(46, 1.0, 0.59)
	local r4 = h4:ToRGBColor();

	print("H1: ", h1)
	print("H2: ", h2)
	print("H3: ", h3)
	print("H4: ", h4)

	print("H4 -> RGB: ", round(r4.r*255), round(r4.g*255), round(r4.b*255))
end

testrgb();
--testHSL();

