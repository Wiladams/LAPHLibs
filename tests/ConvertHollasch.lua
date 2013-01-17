--[[
	Whites
	antique_white     250   235   215   0.9804   0.9216   0.8431

--]]
ConvertHollaschFile = function(filename)
	parseline = function(line)
		-- get name, strip whitespace
		-- make lowercase
		local name = line:sub(1,18)
		name = string.gsub(name, "%s",'')
		name = name:lower();

		-- get the numeric strings, convert to numbers
		local r = tonumber(line:sub(19,21))
		local g = tonumber(line:sub(25,27))
		local b = tonumber(line:sub(31,33))

		return name, r, g, b
	end

	io.write("local ReseneColors = {\n");
	for line in io.lines(filename) do
		local name, red,green,blue = parseline(line)
		--print(name, red, green,blue)
		if name ~= "" then
			if red and green and blue then
				io.write(string.format("%s = {%d, %d, %d},\n",name, red, green, blue))
			end
		end
	end
	io.write("}\n");
end

ConvertHollaschFile("HollaschColors.txt")

--print(tonumber(nil))