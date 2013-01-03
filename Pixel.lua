

local ffi = require ("ffi")
local c99 = require ("c99_types")



local Lum_t = function(ct)
	return ffi.typeof("struct { $ Lum;}", ct)
end

local Lum_mt = {
	__len = function(self) return 1 end,

	__tostring = function(self)
		return string.format("%d", self.Lum);
	end,

}

local LumAlpha_t = function(ct)
	return ffi.typeof("struct { $ Lum, Alpha;}", ct)
end

local LumAlpha_mt = {
	__len = function(self) return 2 end,
	
	__tostring = function(self)
		return string.format("%d, %d, %d", self.Lum, self.Alpha);
	end,

}



local RGB_t = function(ct)
	return ffi.typeof("struct { $ Red, Green, Blue;}", ct)
end

local RGB_mt = {
	__len = function(self) return 3 end,

	__tostring = function(self)
		return string.format("%d, %d, %d", self.Red, self.Green, self.Blue);
	end,

	
}



local RGBA_t = function(ct)
	return ffi.typeof("struct { $ Red, Green, Blue, Alpha;}", ct)
end

local RGBA_mt = {
	__len = function(self) return 4 end,

	__tostring = function(self)
		return string.format("%d, %d, %d, %d", self.Red, self.Green, self.Blue, self.Alpha);
	end,
}



local BGR_t = function(ct)
	return ffi.typeof("struct { $ Blue, Green, Red;}", ct)
end

local BGR_mt = {
	__len = function(self) return 3 end,

	__tostring = function(self)
		return string.format("%d, %d, %d, %d", self.Blue, self.Green, self.Red);
	end,
}


local BGRA_t = function(ct)
	return ffi.typeof("struct { $ Blue, Green, Red;}", ct)
end

local BGRA_mt = {
	__len = function(self) 
		return 4 
	end,

	__tostring = function(self)
		return string.format("%d, %d, %d, %d", self.Blue, self.Green, self.Red, self.Alpha);
	end,
}



local Lumb = ffi.metatype(Lum_t(c99.uint8_t), Lum_mt);
local LumAlphab = ffi.metatype(LumAlpha_t(c99.uint8_t), LumAlpha_mt);
	
local RGBb = ffi.metatype(RGB_t(c99.uint8_t), RGB_mt);
local RGBAb = ffi.metatype(RGBA_t(c99.uint8_t), RGBA_mt);

local BGRb = ffi.metatype(BGR_t(c99.uint8_t), BGR_mt);
local BGRAb = ffi.metatype(BGRA_t(c99.uint8_t), BGRA_mt);



return {
	Lum = Lumb,
	Lum_v = c99.array_tv(Lumb),
	Lum_p = c99.pointer_t(Lumb),

	LumA = LumAlphab,
	LumA_v = c99.array_tv(LumAlphab),
	LumA_p = c99.pointer_t(LumAlphab),

	RGB = RGBb,
	RGB_v = c99.array_tv(RGBb),
	RGB_p = c99.pointer_t(RGBb),

	RGBA = RGBAb,
	RGBA_v = c99.array_tv(RGBAb),
	RGBA_p = c99.pointer_t(RGBAb),

	BGR = BGRb,
	BGR_v = c99.array_tv(BGRb),
	BGR_p = c99.pointer_t(BGRb),

	BGRA = BGRAb,
	BGRA_v = c99.array_tv(BGRAb),
	BGRA_p = c99.pointer_t(BGRAb),
}

