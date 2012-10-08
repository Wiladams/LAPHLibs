package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

local Vector = require "Vector"


function test_Vector()
	local iarray = Vector.new("int");

	for i=1,100 do
		iarray:Push(i);
	end
	
	while iarray:Size() > 0 do
		print(iarray:Pop())
	end
end

function test_Enumerate()
	local carray = Vector.new("char");
	
	-- fill it with some elements
	local values = "The quick brown dog jumped over the lazy dog's back";
	
	for i=1,#values do
		carray:Push(string.byte(values,i,i));
	end
	
	-- retrieve elements using iterator
	print("Size: ", carray:Size());
	
	for e in carray:Elements() do
		io.write(string.char(e));
	end
	io.write('\n');	
end


--test_Vector();

test_Enumerate();
