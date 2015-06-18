package.path = package.path..";../?.lua"

local function test_alt()
	local getopt = require("getopt_alt")

	print(#arg, arg);

	local opts = getopt( arg, "nt:" )
	for k, v in pairs(opts) do
  		print( k, v )
	end
end

--[[
	getopt_posix has the most interesting
	implementation in that it uses coroutines
	to implement the iterator, which means it
	does not create an intermediate table.

	This is how the iterators within lua itself
	operate.
--]]
local function test_posix()
	local getopt = require("getopt_posix")

	for opt, optarg in getopt("nt:", arg) do
        print("opt:", opt, "arg:", optarg)
	end
end

--[[
	get_opts seems to have the most features with 
	respect to being easily posix compliant.
--]]
local function test_get_opts()
	local getopt = require("alt_getopt")
	
	-- Specify the mapping of long options
	-- to their shorter counterparts.
	local long_opts = {
    	verbose = "v",
   		help    = "h",
   		fake    = 0,
   		len     = 1,
   		output  = "o",
   		set_value = "S",
   		["set-output"] = "o"
	}

	local ret
	local optarg
	local optind
	local opts,optind,optarg = getopt.get_ordered_opts (arg, "hVvo:n:S:", long_opts)
	print("==== get_ordered_opts ====")
	for i,v in ipairs (opts) do
   		if optarg [i] then
      		io.write ("option `" .. v .. "': " .. optarg [i] .. "\n")
   		else
      		io.write ("option `" .. v .. "'\n")
   		end
	end

	print("==== get_opts ====")
	optarg,optind = getopt.get_opts (arg, "hVvo:n:S:", long_opts)
	for k,v in pairs (optarg) do
   		io.write ("fin-option `" .. k .. "': " .. v .. "\n")
	end

	print("==== the rest ====")
	for i = optind,#arg do
   		io.write (string.format ("ARGV [%s] = %s\n", i, arg [i]))
	end
end


--test_alt();
--test_posix();
test_get_opts({});