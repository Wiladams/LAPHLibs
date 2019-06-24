package.path = package.path..";../?.lua"

local easing = require("easing")


easeInQuad = easing.easeInQuad;
easeLinear = easing.easeLinear;

--easer = easeLinear;
easer = easeInQuad;

local t = 0;    -- starting time
local d = 3.0;  -- duration

local b = 5;    -- starting value
local c = 10;    -- change in value

for t=0, d, 0.25 do
    local v = easer(t, b, c, d)
    print(string.format("%3.2f",v))
end 
