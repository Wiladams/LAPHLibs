local Tadpole_t = {}
local Tadpole_mt = {
	__index = Tadpole_t
}

local Tadpole = function(name)
	local obj = {
		name = name,
	}
	setmetatable(obj, Tadpole_mt)

	return obj
end

Tadpole_t.Speak = function(atad)
	print("My name is:", atad.name)
end

-- First way, no real 'objects'
local pole1 = {name="William"}
Tadpole_t.Speak(pole1);

-- Second way, a constructed object
local pole2 = Tadpole("Albert")
Tadpole_t.Speak(pole2)

-- Third way, constructed object, with associated function
local pole3 = Tadpole("Adams")
pole3:Speak()


