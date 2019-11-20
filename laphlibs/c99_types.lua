local ffi = require "ffi"
local T = ffi.typeof

-- Creating an array type
local array_tv = function(ct)
	return ffi.typeof("$[?]", ct)
end

-- Creating a pointer type
local pointer_t = function(ct)
	return ffi.typeof("$ * ", ct)
end


--[[
	The types
	int8_t	A plain type
	int8_tv		An Array of type int8_t
	int8_tp		A pointer to an int8_t type
]]
local int8_t = T("int8_t");
local int8_tv = array_tv(int8_t);
local int8_tp = pointer_t(int8_t);

local uint8_t = T("uint8_t");
local uint8_tv = array_tv(uint8_t);
local uint8_tp = pointer_t(uint8_t);

local int16_t = T("int16_t");
local int16_tv = array_tv(int16_t);
local int16_tp = pointer_t(int16_t);

local uint16_t = T("uint16_t");
local uint16_tv = array_tv(uint16_t);
local uint16_tp = pointer_t(uint16_t);

local int32_t = T("int32_t");
local int32_tv = array_tv(int32_t);
local int32_tp = pointer_t(int32_t);

local uint32_t = T("uint32_t");
local uint32_tv = array_tv(uint32_t);
local uint32_tp = pointer_t(uint32_t);

local int64_t = T("int64_t");
local int64_tv = array_tv(int64_t);
local int64_tp = pointer_t(int64_t);

local uint64_t = T("uint64_t");
local uint64_tv = array_tv(uint64_t);
local uint64_tp = pointer_t(uint64_t);

local float = T("float");
local floatv = array_tv(float);
local floatp = pointer_t(float);

local double = T("double");
local doublev = array_tv(double);
local doublep = pointer_t(double);



local wchar_t = T("uint16_t");
local wchar_tv = array_tv(wchar_t);
local wchar_tp = pointer_t(wchar_t);

local exports = {
	array_tv = array_tv,
	pointer_t = pointer_t,

	int8_t = int8_t,
	int8_tv = int8_tv,
	int8_tp = int8_tp,

	uint8_t = uint8_t,
	uint8_tv = uint8_tv,
	uint8_tp = uint8_tp,

	int16_t = int16_t,
	int16_tv = int16_tv,
	int16_tp = int16_tp,

	uint16_t = uint16_t,
	uint16_tv = uint16_tv,
	uint16_tp = uint16_tp,

	int32_t = int32_t,
	int32_tv = int32_tv,
	int32_tp = int32_tp,

	uint32_t = uint32_t,
	uint32_tv = uint32_tv,
	uint32_tp = uint32_tp,

	int64_t = int64_t,
	int64_tv = int64_tv,
	int64_tp = int64_tp,

	uint64_t = uint64_t,
	uint64_tv = uint64_tv,
	uint64_tp = uint64_tp,

	float = float,
	floatv = floatv,
	floatp = floatp,

	double = double,
	doublev= doublev,
	doublep = doublep,

	wchar_t = wchar_t,
	wchart_tv = wchar_tv,
	wchar_tp = wchar_tp,
}

return exports;
