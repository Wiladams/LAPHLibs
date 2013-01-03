--[[
	Representation of various color spaces.

--  References
-- http://paulbourke.net/texture_colour/colourspace/
--
--]]

local ffi = require("ffi");

ffi.cdef[[
typedef struct {
	double r,g,b;
} RGBColor;

typedef struct {
	double r,g,b,a;
} RGBAColor;


]]

local RGBColor = ffi.typeof("RGBColor");
local RGBColor_mt = {
	__tostring = function(self)
		return string.format("%3.4f, %3.4f, %3.4f", self.r, self.g, self.b)
	end,

}
local RGBColor = ffi.metatype(RGBColor, RGBColor_mt)


local RGBAColor = ffi.typeof("RGBAColor");

-- Turn a standard byte valued rgb color into a RGBColor object
-- Basically, scale to the range 0..1
local RGBToRGBColor = function(r,g,b) return RGBColor(r/255, g/255, b/255) end


return {
	RGBColor = RGBColor,
	RGBAColor = RGBAColor,


	RGBToRGBColor = RGBToRGBColor,
}