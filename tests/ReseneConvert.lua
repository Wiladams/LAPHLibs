--[[
Resene RGB Values List

Copyright Resene Paints Ltd 2001

Columnar data

Colour name(1)            r-27 g-32 b-37
===========               ===  ===  ===


--]]


ConvertReseneFile = function(filename)
	parseline = function(line)
		-- get name, strip whitespace
		-- make lowercase
		local name = line:sub(1,26)
		name = string.gsub(name, "%s",'')
		name = name:lower();

		-- get the numeric strings, convert to numbers
		local r = tonumber(line:sub(27,29))
		local g = tonumber(line:sub(32,34))
		local b = tonumber(line:sub(37,39))

		return name, r, g, b
	end

	io.write("local ReseneColors = {\n");
	for line in io.lines(filename) do
		local name, red,green,blue = parseline(line)
		--print(name, red, green,blue)
		io.write(string.format("%s = {%d, %d, %d},\n",name, red, green, blue))
	end
	io.write("}\n");
end

ConvertReseneFile("ReseneRGB.txt")