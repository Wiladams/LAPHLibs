package.path = package.path..";..\\?.lua";

local ffi = require "ffi"
local luxl = require "luxl"
require "luxl_util"

local cases = require "xml_samples"
require "stringzutils"





function CreateFlatXTable(xlex, currentelement)
	currentelement = currentelement or {}

	local currentattributename = nil;
	local attribute_count =0;

	-- start reading the thing
	local txt=nil;
	for event, offset, size in xlex:Lexemes() do
		txt = GetString(xlex.buf, offset, size);

		if event == EVENT_START and txt ~= "xml" then
			-- does current element already have something
			-- with this name?

			-- if it does, if it's a table, add to it
			-- if it doesn't, then add a table
			currentelement[txt] = CreateFlatXTable(xlex)
		end

		if event == EVENT_ATTR_NAME then
			currentattributename = txt
		end

		if event == EVENT_ATTR_VAL then
			currentelement[currentattributename] = txt
			attribute_count = attribute_count + 1;
			currentattributename = nil
		end

		if event == EVENT_TEXT then
			--if attribute_count < 1 then
			--	return txt
			--end

			currentelement["_Content"] = txt
		end

		if event == EVENT_END then
			return currentelement
		end
	end

	return currentelement
end



function CollectXMLNodes(buff, len, offset)
	offset = offset or 0

	--print(buff, len);

	if buff == nil or len < 1 then return nil end

	local res = {}
	local xlex = luxl.new(buff, len);
	--xlex.EventHandler = EventHandler;

--	return CreateFlatXTable(xlex)
	return CreateXNode(xlex,"DOCUMENT")
end




function printXNode(tbl, indent)
	if not tbl then return end

	indent = indent or '';

	print(indent..tbl.Name)

	-- first print attributes
	if tbl.Attributes then
		for k,v in pairs(tbl.Attributes) do
			print(indent..string.format("[%s = '%s']",k, v));
		end
	end

	-- Next, print the content of the current node
	if tbl.Content then
		print(indent..string.format("<%s>",tbl.Content));
	end

	-- Last, print the elements
	if tbl.Children then
		for i,v in ipairs(tbl.Children) do
			if type(v) == "table" then
				--print(indent..k)
				printXNode(v, indent.."  ")
			else
				print(indent,v)
			end
		end
	end

end

function main()

	local buff = strdup(cases.saml2_xsd);
	--local buff = strdup(cases.x3d_case1);
	--local buff = strdup[[<simple att1="first" att2="second">some text content</simple>]];
	--local buff = strdup(cases.case1);
	--local buff = strdup(cases.case2);
	--local buff = strdup(cases.amf_case1);

	local len = strlen(buff)

	local tbl = CollectXMLNodes(buff, len);

	printXNode(tbl);
	--print(tbl.amf.unit)
	--print(tbl.amf.object.id);
	--print(tbl.amf.object.mesh.vertices.vertex.coordinates.y._Content)
	--print(tbl.amf.object.mesh.vertices.vertex.coordinates.x._Content);
	--print(tbl.amf.object.mesh.vertices.vertex.coordinates.y._Content);
	--print(tbl.amf.object.mesh.vertices.vertex.coordinates.z._Content);
end

main();
