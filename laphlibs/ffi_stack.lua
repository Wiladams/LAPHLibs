--[[
	This code came from Mike Pall, who is the author of
	the LuaJIT program.

	It was written as a demonstration of how best to
	implement a data structure with parameterized types.

	This can be seen in the makestack() function.
--]]


local ffi = require("ffi")

local function stack_iter(stack)
	local top = stack.top
	if top > 0 then
		stack.top = top-1
		return stack.slot[top-1]
	end
end

local stack_mt = {
	__new = function(tp, max)
		return ffi.new(tp, max, 0, max)
	end,

	__index = {
		push = function(stack, val)
			local top = stack.top
			if top >= stack.max then
				error("stack overflow")
			end
			stack.top = top + 1
			stack.slot[top] = val
		end,

		pop = function(stack)
			local top = stack.top
			if top <= 0 then
				error("stack underflow")
			end
			stack.top = top-1
			return stack.slot[top-1]
		end,

		iter = function(stack)
			return stack_iter, stack
		end,
	}
}

local function makestack(ct)
	local tp = ffi.typeof("struct { int top, max; $ slot[?]; }", ct)

	return ffi.metatype(tp, stack_mt)
end

return {
	makestack = makestack,
	stack_iter = stack_iter,
}
