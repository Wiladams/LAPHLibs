package.path = package.path..";..\\?.lua";

local Hashes = require "Hashes"
local kazhash = Hashes.KazHash

local hello = "This is the string to hash";

local value = kazhash(hello)

print(string.format("0x%X",value))

