package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

luxl = require "luxl"

cases = require "xml_samples"
require "luxl_util"
require "stringzutils"

function read_entire_file(filename)
	local fh = io.open(filename, "r")
	if not fh then return nil end

	local buffer = fh:read("*all");
	local len = #buffer;
	fh:close();

	return buffer, len
end

function new_from_file(filename)
	local p = nil;

	if(filename) then
		local buf, len = read_entire_file(filename);
		if(buf ~= nil and len > 0) then
			p = pico_new(buf, len, 0);
		end
	end

	return p;
end



function test_xml()
	--local buf = strdup(case1);
	--local buf = strdup(cases.amf_case1);
	--local buf = strdup(cases.saml2_xsd);
	--local buf = strdup(cases.schema_case1);
	local buf = strdup(cases.x3d_case1);

	local len = strlen(buf)


	local xlex = luxl.new(buf, len);
	--xlex.MsgHandler = MsgHandler;

	for event, offset, size in xlex:Lexemes() do
		--print("Event: ", pico_event_str(event), offset, size);
		local txt = GetString(buf, offset, size);
		print(string.format("[%s] '%s'", luxl_event_str(event), txt));
	end
end

test_xml();
