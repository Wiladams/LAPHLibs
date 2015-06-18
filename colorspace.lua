--[[
	Representation of various color spaces.

--  References
-- http://paulbourke.net/texture_colour/colourspace/

   This file contains representation of a basic RGBColor space

   It also contains HSL (HSB), and conversions between the two

   Perhaps HSV would be a nice addition?

   Need to add luma conversion
   RGB From Frequency
--
--]]

local ffi = require("ffi");

local MIN = math.min
local MAX = math.max

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


ffi.cdef[[
typedef struct {
	double h, s, l;
} HSLColor, *PHSLColor;
]]
local HSLColor = ffi.typeof("HSLColor")
local HSLColor_p = ffi.typeof("PHSLColor")

local HSLColor_mt = {
	--[[
   		Calculate HSL from RGB
   		Hue is in degrees
   		Lightness is between 0 and 1
   		Saturation is between 0 and 1
	--]]
	__new = function(ct, ...)
		local nelems = select("#", ...)

		-- Default constructor
		if nelems == 0 then
			return ffi.new(ct)
		end

		-- element constructor
		if nelems == 3 then
			return ffi.new(ct, select(1,...), select(2,...), select(3,...));
		end

		-- Should have only 1 argument now
		if nelems ~= 1 then
			return nil
		end

		local c1 = select(1,...)

		-- Copy constructor
		if ffi.istype(HSLColor, c1) then
			return ffi.new(ct, HSLColor)
		end

		-- Must be Copy from RGBColor
		if not ffi.istype(RGBColor, c1) then
			return nil
		end

  		local c2 = ffi.new(ct);

   		local themin = MIN(c1.r,MIN(c1.g,c1.b));
   		local themax = MAX(c1.r,MAX(c1.g,c1.b));
   		local delta = themax - themin;
   		c2.l = (themin + themax) / 2;
   		c2.s = 0;
   			
   		if (c2.l > 0 and c2.l < 1) then
   			partial = (2*c2.l)
   		else
   			partial = (2-2*c2.l)
   		end

   		c2.s = delta / partial

   		c2.h = 0;
   		if (delta > 0) then
      		if (themax == c1.r and themax ~= c1.g) then
       			c2.h = c2.h + (c1.g - c1.b) / delta;
         	end
      		if (themax == c1.g and themax ~= c1.b) then
       			c2.h = c2.h + (2 + (c1.b - c1.r) / delta);
         	end
      		if (themax == c1.b and themax ~= c1.r) then
         		c2.h = c2.h + (4 + (c1.r - c1.g) / delta);
         	end
      			c2.h = c2.h * 60;
   		end
   		return(c2);
	end,

	__tostring = function(self)
		return string.format("%3.2f, %3.2f, %3.2f", self.h, self.s, self.l)
	end,

	__index = {
		--[[
   			Calculate RGB from HSL, reverse of RGB2HSL()
   			Hue is in degrees
   			Lightness is between 0 and 1
   			Saturation is between 0 and 1
		--]]
		ToRGBColor = function(c1)
   			while (c1.h < 0) do
      			c1.h = c1.h + 360;
   			end

   			while (c1.h > 360) do
      			c1.h = c1.h - 360;
   			end

   			local sat = RGBColor();
   			if (c1.h < 120) then
      			sat.r = (120 - c1.h) / 60.0;
      			sat.g = c1.h / 60.0;
      			sat.b = 0;
   			elseif (c1.h < 240) then
      			sat.r = 0;
      			sat.g = (240 - c1.h) / 60.0;
      			sat.b = (c1.h - 120) / 60.0;
   			else 
      			sat.r = (c1.h - 240) / 60.0;
      			sat.g = 0;
      			sat.b = (360 - c1.h) / 60.0;
   			end

   			sat.r = MIN(sat.r,1);
   			sat.g = MIN(sat.g,1);
   			sat.b = MIN(sat.b,1);

   			local ctmp = RGBColor();
   			ctmp.r = 2 * c1.s * sat.r + (1 - c1.s);
   			ctmp.g = 2 * c1.s * sat.g + (1 - c1.s);
   			ctmp.b = 2 * c1.s * sat.b + (1 - c1.s);

   			local c2 = RGBColor();
   			if (c1.l < 0.5) then
      			c2.r = c1.l * ctmp.r;
      			c2.g = c1.l * ctmp.g;
      			c2.b = c1.l * ctmp.b;
   			else 
      			c2.r = (1 - c1.l) * ctmp.r + 2 * c1.l - 1;
      			c2.g = (1 - c1.l) * ctmp.g + 2 * c1.l - 1;
      			c2.b = (1 - c1.l) * ctmp.b + 2 * c1.l - 1;
   			end

   			return c2;
		end,
	}
}
HSLColor = ffi.metatype(HSLColor, HSLColor_mt);	




return {
	RGBColor = RGBColor,
	RGBAColor = RGBAColor,

	HSLColor = HSLColor,

	RGBToRGBColor = RGBToRGBColor,
}