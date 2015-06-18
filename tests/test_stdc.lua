package.path = package.path..";../?.lua";

print("first time")
local stdc1 = require("stdc")

print("second time")
local stdc2 = require("stdc")


print(stdc1, stdc2)