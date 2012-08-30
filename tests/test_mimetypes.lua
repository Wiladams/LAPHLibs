package.path = package.path..";..\\?.lua";


local mimetypes = require "mimetypes"
local strutils = require "stringutils"
local mime = require "mime"

function createMime()
for _,row in ipairs(mime.types) do
	--print(row[1], row[2], row[3]);
	if row[3] ~= nil then
		local exts = strutils.tsplit(row[3], ' ');
		for _,ext in ipairs(exts) do
			print(string.format("['%s'] = '%s/%s',", ext, row[1], row[2]));
		end
	end
end
end

function printType(path)
	print(path, "==> ", mime.GetType(path));
end

function test_mime()
	printType("file.html");
	printType("filename.gif");
	printType("filename.webm");
	printType("unknown");
end

test_mime();

