
package.path = package.path..";../?.lua"

local RGBColor = require ("RGBColor")

RGBC = RGBColor.RGBToRGBColor

snow = RGBC(255,255,0);
bisque = RGBC(255,228,196);

print("snow: ", snow)
print("bisque", bisque)