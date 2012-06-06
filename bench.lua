#!/usr/bin/env lua
local socket = require"socket"
local time = socket.gettime
local clock = os.clock
local quiet = false
local disable_gc = true

local debug = false
local test_name=nil
local output = function() end

local ffi
local tests_list = { "luxl", "luxl_orig", "xmlreader", "lxp" }
local tests = {
	luxl = {
		load = function(self)
			ffi = require"ffi"
			self.luxl = require"luxl"
			-- copy constants to 'self'
			for k,v in pairs(self.luxl) do
				if not self[k] then
					self[k] = v
				end
			end
		end,
		new = function(self, data, old_parser)
			local buf = ffi.cast('const char *', data)
			local len = #data
			-- need to cache buffer for extracting values.
			self.buf = buf
			self.len = len
			-- can't re-use old parser, make a new one each time.
			return self.luxl.new(buf, len)
		end,
		parse = function(self, parser, data)
			repeat
				local event, off, size = parser:GetNext()
				if event == self.EVENT_START then
					output(parser:GetString(), ':\n')
				elseif event == self.EVENT_ATTR_NAME then
					output('  ',parser:GetString())
				elseif event == self.EVENT_ATTR_VAL then
					output('=',parser:GetString(), '\n')
				end
			until (event == self.EVENT_END_DOC)
		end,
	},
	luxl_orig = {
		load = function(self)
			ffi = require"ffi"
			self.luxl = require"luxl_orig"
			-- copy constants to 'self'
			for k,v in pairs(self.luxl) do
				if not self[k] then
					self[k] = v
				end
			end
		end,
		new = function(self, data, old_parser)
			local buf = ffi.cast('const char *', data)
			local len = #data
			-- need to cache buffer for extracting values.
			self.buf = buf
			self.len = len
			-- can't re-use old parser.
			return self.luxl.new(buf, len)
		end,
		parse = function(self, parser, data)
			repeat
				local event, off, size = parser:GetNext()
				if event == self.EVENT_START then
					output(ffi.string(parser.buf + off, size), ':\n')
				elseif event == self.EVENT_ATTR_NAME then
					output('  ',ffi.string(parser.buf + off, size))
				elseif event == self.EVENT_ATTR_VAL then
					output('=',ffi.string(parser.buf + off, size), '\n')
				end
			until (event == self.EVENT_END_DOC or event == nil)
		end,
	},
	xmlreader = {
		load = function(self)
			self.mod = require"xmlreader"
		end,
		new = function(self, data, old_parser)
			-- can't re-use old parser, make a new one each time.
			return self.mod.from_string(data)
		end,
		parse = function(self, parser, data)
			while parser:read() do
				local ntype = parser:node_type()
				if ntype == 'element' then
					output(parser:name(), ':\n')
					while parser:move_to_next_attribute() do
						output('  ',parser:name(),'=',parser:value(),'\n')
					end
				end
			end
		end,
	},
	lxp = {
		load = function(self)
			self.mod = require"lxp"
		end,
		cbs = {
			StartElement = function(parser, element, attrs)
				output(element, ':\n')
				for _,name in ipairs(attrs) do
					output('  ',name,'=',attrs[name],'\n')
				end
			end,
		},
		new = function(self, data, old_parser)
			return self.mod.new(self.cbs)
		end,
		parse = function(self, parser, data)
			return parser:parse(data)
		end,
	},
}

for i=1,#arg do
	local a = arg[i]
	if a:find("^-") then
		if a == '-gc' then
			disable_gc = false
		elseif a == '-debug' then
			debug = true
		end
	else
		test_name = a
		assert(tests[a], "Unknown test name: " .. a)
	end
end

if disable_gc then
	print"GC is disabled so we can track memory usage better"
	print""
end

if debug then
	N=1
	output = io.write
end

local function printf(fmt, ...)
	local res
	if not quiet then
		fmt = fmt or ''
		res = print(string.format(fmt, ...))
		io.stdout:flush()
	end
	return res
end

local function full_gc()
	-- make sure all free-able memory is freed
	collectgarbage"collect"
	collectgarbage"collect"
	collectgarbage"collect"
end

local function bench(N, func, ...)
	local start1,start2
	start1 = clock()
	start2 = time()
	func(N, ...)
	local diff1 = (clock() - start1)
	local diff2 = (time() - start2)
	printf("total time: %10.6f (%10.6f) seconds", diff1, diff2)
	return diff1, diff2
end

local function do_test(N, test, data)
	local parser = test:new(data)
	for i=1,N do
		test:parse(parser, data)
		if i ~= N then
			parser = test:new(data, parser) -- reset or create new parser.
		end
	end
end

local function apply_memtest(test, data)
	local start_mem, end_mem
	
	full_gc()
	start_mem = (collectgarbage"count" * 1024)
	if disable_gc then collectgarbage"stop" end
	do_test(1, test, data)
	end_mem = (collectgarbage"count" * 1024)
	print('total memory used: ', (end_mem - start_mem))
	print()
   
	parser = nil
	collectgarbage"restart"
	full_gc()
end

local function apply_speedtest(test, data, N)
	local start_mem, end_mem
 
	full_gc()
	start_mem = (collectgarbage"count" * 1024)
	--print('start memory size: ', start_mem)
	if disable_gc then collectgarbage"stop" end
	local diff1, diff2 = bench(N, do_test, test, data)
	end_mem = (collectgarbage"count" * 1024)
	local mbytes = (#data * N) / (1024 * 1024)
	printf("bandwidth: %10.6f (%10.6f) MBytes/sec", mbytes/diff1, mbytes/diff2)
	local units = N
	printf("units/sec: %10.6f (%10.6f) units/sec", units/diff1, units/diff2)
	--print('end   memory size: ', end_mem)
	print('total memory used: ', (end_mem - start_mem))
	print()
   
	parser = nil
	collectgarbage"restart"
	full_gc()
end

local function per_test_overhead(N, test)
	local start_mem, end_mem
	local parsers = {}
	local data = [[
<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<data></data>
]]
 
	-- pre-grow table
	for i=1,N do
		parsers[i] = true -- add place-holder values.
	end
	full_gc()
	start_mem = (collectgarbage"count" * 1024)
	--print('overhead: start memory size: ', start_mem)
	for i=1,N do
		parsers[i] = test:new(data)
	end
	full_gc()
	end_mem = (collectgarbage"count" * 1024)
	--print('overhead: end   memory size: ', end_mem)
	print('overhead: total memory used: ', (end_mem - start_mem) / N, ' bytes per parser')
   
	parsers = nil
	full_gc()
end

local xml_data = {
	{ name = "small", filename = "data/book-order.xml", N = 10000, },
	{ name = "large", filename = "data/book-order.large.xml", N = 100, },
}
for i=1,#xml_data do
	local xml = xml_data[i]
	local file = io.open(xml.filename, "rb")
	xml.data = file:read("*a")
	file:close()
end

local function run_test(name, test)
	-- try loading the module
	local stat, mod = pcall(test.load, test)
	if not stat then
		-- failed to load xml parser
		test.disable = true
		print("failed to load module:", mod)
		return
	end

	printf("==================================================================", name)
	printf("===================== Benchmark: %s", name)
	for i=1,#xml_data do
		local xml = xml_data[i]
		local data = xml.data
		print('------------------ xml file:', xml.filename)

		print('speed test')
		apply_speedtest(test, data, xml.N)

		print('memory test')
		apply_memtest(test, data)
	end

	print('overhead test')
	per_test_overhead(1000, test)
end

if not test_name then
	for i=1,#tests_list do
		local name = tests_list[i]
		run_test(name, tests[name])
	end
else
	run_test(test_name, tests[test_name])
end


