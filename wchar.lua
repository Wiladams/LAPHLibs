if not wchar_included then
local ffi = require "ffi"

wchar_included = true

wchar_t = ffi.typeof("uint16_t");

end
