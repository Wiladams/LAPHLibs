
local lua = require "lua_ffi"



local function report_errors(L, status)
	if status ~=0 then
		print("-- ", ffi.string(lua_tostring(L, -1)))
		lua_pop(L, 1); -- remove error message
	end
end

local LuaState_t = {}
local LuaState_mt = {
	__index = LuaState_t;
}

local function LuaState(codechunk, autorun)
	local status, result
	local L = lua.luaL_newstate();  -- create state


	if L == nil then
		return nil, "could not create lua state"
	end

	local obj = {}
	setmetatable(obj, LuaState_mt);

	obj.State = L
	--self.Init = LuaState.Defaults.InitLua

	-- Must at least load base library
	-- or 'require' and print won't work
	lua.luaopen_base(L)
	lua.luaopen_string(L);
	lua.luaopen_math(L);
	lua.luaopen_io(L);
	lua.luaopen_table(L);

	lua.luaopen_bit(L);
	lua.luaopen_jit(L);
	lua.luaopen_ffi(L);


	if codechunk then
		obj.CodeChunk = codechunk
		if autorun then
			obj:Run(codechunk)
		end
	end

	return obj
end

function LuaState_t.LoadChunk(self, codechunk)
	self.CodeChunk = codechunk
	local result = lua.luaL_loadstring(self.State, codechunk)
	report_errors(self.State, result)

	return result
end

function LuaState_t.Run(self, codechunk)
	codechunk = codechunk or self.CodeChunk

	if not codechunk then
		return nil, "no code to run"
	end

	local result = self:LoadChunk(codechunk)


	if result == 0 then
		result = lua.lua_pcall(self.State, 0, LUA_MULTRET, 0)
		report_errors(self.State, result)
	end

	return result
end

return LuaState;
