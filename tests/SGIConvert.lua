
--[[
	Get raw data from here:
	http://paulbourke.net/texture_colour/colourspace/sgi.html

	Strip off the first couple of lines that look like this:

SGI X colours

 R   G   B              Name
===========             ===================

Run what's left through this program

--]]



parseline = function(line)
	local starting, ending, n1, n2, n3, name = line:find("%s*(%d*)%s*(%d*)%s*(%d*)%s*([%a%d%s]*)")
	return tonumber(n1), tonumber(n2), tonumber(n3), name
end

convertFile = function(filename)
	for line in io.lines(filename) do
		local red,green,blue,name = parseline(line)
		name = name:lower()
		if name:find("%s") == nil then
			io.write(string.format("%s = {%d, %d, %d},\n",name, red, green, blue))
		end
	end
end

convertFile("SGIColors.txt")

