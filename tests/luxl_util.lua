package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

local luxl = require "luxl"
require "stringzutils"
require "memutils"

ffi.cdef[[
typedef struct {
  char* entity;
  int sz;
  char ch;
} entity_t;
]]

local entity_refs =  ffi.new("const entity_t[6]", {
  {strdup("lt;"),	3, string.byte'<'},
  {strdup("gt;"),	3, string.byte'>'},
  {strdup("amp;"), 	4, string.byte'&'},
  {strdup("apos;"),	5, string.byte'\''},
  {strdup("quot;"),	5, string.byte'"'},
  {nil, 0, 0}
})



luxl_event_str_mapper = {
  [luxl.EVENT_START] = "start tag";
  [luxl.EVENT_END] = "end tag";
  [luxl.EVENT_TEXT] = "text";
  [luxl.EVENT_ATTR_NAME] = "attr name";
  [luxl.EVENT_ATTR_VAL] = "attr val";
  [luxl.EVENT_END_DOC] = "end document";
}

function luxl_event_str(event)
	local mapped = luxl_event_str_mapper[event] or "err";
	return mapped;
end


-- Turn a pointer, offset, length of a string
-- into an integer value
local function GetInt(src, offset, len)
	local TSIZE = 64

	srcptr = ffi.cast("const uint8_t *", (src + offset));
	local buf = ffi.new("char[?]",TSIZE);

	local sz = len;
	if(sz >= TSIZE) then
		sz = TSIZE;
	end -- bound size

	memcpy(buf, srcptr, sz);
	buf[sz] = 0;
	local val = atoi(buf);

	return val;
end



--[[
	fetches the content as a string from last event; e.g., for
	start/end tags, the actual tag text is returned, text/attr
	name/attr value all return the specific text, and start/end
	document return null. Note: if text context has whitespace, it is
	retained.
--]]
local function GetString(src, offset, len)

	local sz = len;
	local buf = ffi.new("char[?]",(sz + 1));

	if not buf then return false, "out of memory" end
	
	local i = offset;
	local j = 0;
	local found = false;
	while (i<offset+sz) do
		-- i indexes src buffer, while j indexes output buffer
		-- do entity ref expansion
		if(src[i] == string.byte'&' and i+1 < sz) then
			i = i + 1;
			local k = 0;
			found = false;
			while(entity_refs[k].entity ~= 0 ) do
				if(strncmp(src+i, entity_refs[k].entity, entity_refs[k].sz) == 0) then
					buf[j] = entity_refs[k].ch;
					i = i + entity_refs[k].sz - 1; -- increment index into src
					found = true;
					break;
				end
				k = k + 1;
			end

			if (not found) then
				-- didn't find any defined entity
				--buf[j] = src[--i];
				i = i - 1;
				buf[j] = src[i];
			end
		else
			buf[j] = src[i];
		end
		j = j + 1;
		i = i + 1;
	end
	
	buf[j] = 0; -- null terminate

	return ffi.string(buf);
end

function CreateXNode(xlex, name)
	local currentelement = {Name = name}
	local currentattributename = nil;

	-- start reading the thing
	local txt=nil;
	for event, offset, size in xlex:Lexemes() do
		txt = GetString(xlex.buf, offset, size);

		if event == EVENT_START and txt ~= "xml" then
			if currentelement.Children == nil then
				currentelement.Children = {}
			end
			table.insert(currentelement.Children, CreateXNode(xlex, txt))
		end

		if event == EVENT_ATTR_NAME then
			currentattributename = txt
		end

		if event == EVENT_ATTR_VAL then
			if currentelement.Attributes == nil then
				currentelement.Attributes = {}
			end
			currentelement.Attributes[currentattributename] = txt
			currentattributename = nil
		end

		if event == EVENT_TEXT then
			currentelement.Content = txt
		end

		if event == EVENT_END then
			return currentelement
		end
	end

	return currentelement
end


function MsgHandler(offset, state, c)
	--io.stderr:write(string.format("ix=%d; c='%c' (0x%x); state=[%s]\n", i,
	--  (isprint(c) ? c : '.'), c, state_str(p.state)));
	print("Message: ", offset, state, string.char(c));
end

function ErrHandler(offset, state, c)
	--io.stderr:write(string.format("WARNING: No match in state [%s] defaulting\n",
	--state_str(p.state)));
	print("Error: ", offset, state, string.char(c));
end

function EventHandler(event, offset, len)
	io.stderr:write(string.format("event fired: [%s]\n",
	luxl_event_str(event)));
end
