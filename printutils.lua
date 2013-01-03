
local ffi = require "ffi"

require "cctype"


local function bytestohex(data, datalen)
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
		if isprint(data[i]) then
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
