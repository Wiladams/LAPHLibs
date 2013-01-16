package.path = package.path..";../?.lua"

local sha2 = require ("sha2");

-- read a file and prints its hash, if given a file name

if arg[1] then
	local file = assert(io.open (arg[1], 'rb'))
	local x = sha2.SHA256_t();
  	for b in file:lines(2^12) do
    	x:add(b)
  	end
  	file:close()
  	
  	print(x:close())
end

