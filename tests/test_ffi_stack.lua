package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

local stacker = require "ffi_stack"


function test_stack_double()
	local stack_ofdouble = stacker.makestack(ffi.typeof("double"))

	local maxsize = 100
	local dstack = stack_ofdouble(maxsize)

	-- push values onto the stack
	for i=1,maxsize do
		dstack:push(i)
	end

	-- write out the values in stack order
	for x in dstack:iter() do
		io.write(x, " ")
	end

	io.write("\n")
end

test_stack_double();


