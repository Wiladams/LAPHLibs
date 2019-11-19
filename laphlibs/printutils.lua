
local ffi = require "ffi"

local ctype = require "cctype"


local function bytestohex(data, datalen)
	datalen = datalen or #data
	data = ffi.cast("const uint8_t *", data)
	
	local aline = {}
	for i=0, datalen-1 do
		table.insert(aline, string.format("%02x", data[i]));
		if i%16 == 15 then
			table.insert(aline,'\n');
		else
			table.insert(aline, ":");
		end
	end

	return table.concat(aline)
end

local function bytestohexstring(data, datalen)
	local aline = {}
	for i=0, datalen-1 do
		if ctype.isprint(data[i]) then
			table.insert(aline, string.char(data[i]));
		else
			--table.insert(aline, string.format("%02x", data[i]));
			table.insert(aline, '.');
		end
		if i%16 == 15 then
			table.insert(aline,'\n');
		else
			--table.insert(aline, ":");
		end
	end

	return table.concat(aline)
end

local function blobtohex(blob)
	return bytestohex(blob.Data, blob.Length);
end


return {
	bytestohex = bytestohex;
	bytestohexstring = bytestohexstring;
	blobtohex = blobtohex;
}
