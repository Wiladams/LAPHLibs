if not stdint_included then
stdint_included = true

local ffi = require "ffi"

int8_t = ffi.typeof("int8_t")
int16_t = ffi.typeof("int16_t")
int32_t = ffi.typeof("int32_t")
int64_t = ffi.typeof("int64_t")

uint8_t = ffi.typeof("int8_t")
uint16_t = ffi.typeof("int16_t")
uint32_t = ffi.typeof("int32_t")
uint64_t = ffi.typeof("int64_t")

end
