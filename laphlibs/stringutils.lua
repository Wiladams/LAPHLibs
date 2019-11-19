

local function gsplit(s,sep)
	return coroutine.wrap(function()
		if s == '' or sep == '' then coroutine.yield(s) return end
		local lasti = 1
		for v,i in s:gmatch('(.-)'..sep..'()') do
		   coroutine.yield(v)
		   lasti = i
		end
		coroutine.yield(s:sub(lasti))
	end)
end

local function iunpack(i,s,v1)
   local function pass(...)
	  local v1 = i(s,v1)
	  if v1 == nil then return ... end
	  return v1, pass(...)
   end
   return pass()
end

local function split(s,sep)
   return iunpack(gsplit(s,sep))
end

local function accumulate(t,i,s,v)
    for v in i,s,v do
        t[#t+1] = v
    end
    return t
end

local function tsplit(s,sep)
   return accumulate({}, gsplit(s,sep))
end

local function trim(s)
	local from = s:match"^%s*()"
 	return from > #s and "" or s:match(".*%S", from)
end

return {
	tsplit = tsplit,
	split = split,
	gsplit = gsplit,

	trim = trim,
}
