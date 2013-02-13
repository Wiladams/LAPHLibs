package.path = package.path..";../?.lua";

local LuaState = require("LuaState")

local state = LuaState("print('hello, world!')");

state:Run();

