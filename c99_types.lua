local ffi = require "ffi"

local array_tv = function(ct)
	return ffi.typeof("$[?]", ct)
end

local pointer_t = function(ct)
	return ffi.typeof("$ * ", ct)
end



local int8_t = ffi.typeof("int8_t");
local int8_tv = array_tv(int8_t);

local uint8_t = ffi.typeof("uint8_t");
local uint8_tv = array_tv(uint8_t);

local int16_t = ffi.typeof("int16_t");
local int16_tv = array_tv(int16_t);

local uint16_t = ffi.typeof("uint16_t");
local uint16_tv = array_tv(uint16_t);

local int32_t = ffi.typeof("int32_t");
local int32_tv = array_tv(int32_t);

local uint32_t = ffi.typeof("uint32_t");
local uint32_tv = array_tv(uint32_t);

local int64_t = ffi.typeof("int64_t");
local int64_tv = array_tv(int64_t);

local uint64_t = ffi.typeof("uint64_t");
local uint64_tv = array_tv(uint64_t);

local float = ffi.typeof("float");
local floatv = array_tv(float);

local double = ffi.typeof("double");
local doublev = array_tv(double);




local wchar_t = ffi.typeof("uint16_t");
local wchar_tv = array_tv(wchar_t);

local c99_types = {
	array_tv = array_tv,
	pointer_t = pointer_t,

	int8_t = int8_t,
	int8_tv = int8_tv,

	uint8_t = uint8_t,
	uint8_tv = uint8_tv,

	int16_t = int16_t,
	int16_tv = int16_tv,
	
	uint16_t = uint16_t,
	uint16_tv = uint16_tv,

	int32_t = int32_t,
	int32_tv = int32_tv,
	
	uint32_t = uint32_t,
	uint32_tv = uint32_tv,

	int64_t = int64_t,
	int64_tv = int64_tv,
	
	uint64_t = uint64_t,
	uint64_tv = uint64_tv,

	float = float,
	floatv = floatv,
	
	double = double,
	doublev= doublev,

	wchar_t = wchar_t,
	wchart_tv = wchar_tv,
}

return c99_types;
