package.path = package.path..";..\\?.lua";

local ffi = require "ffi"

luxl = require "luxl"

require "stringzutils"
require "strtoul"
require "memutils"
cases = require "xml_samples"

function read_entire_file(filename)
	local fh = io.open(filename, "r")
	if not fh then return nil end

	local buffer = fh:read("*all");
	local len = #buffer;
	fh:close();

	return buffer, len
end

function new_from_file(filename)
	local p = nil;

	if(filename) then
		local buf, len = read_entire_file(filename);
		if(buf ~= nil and len > 0) then
			p = pico_new(buf, len, 0);
		end
	end

	return p;
end

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



local state_str_mapper = {
  [ST_START] ="start";
  [ST_TEXT] ="text";
  [ST_START_TAG] ="start tag";
  [ST_START_TAGNAME] ="start tag name";
  [ST_START_TAGNAME_END] ="start tag name end";
  [ST_END_TAG] ="end tag";
  [ST_END_TAGNAME] ="end tagname";
  [ST_END_TAGNAME_END] ="end tag name end";
  [ST_EMPTY_TAG] ="empty tag";
  [ST_SPACE] ="space";
  [ST_ATTR_NAME] ="attr name";
  [ST_ATTR_NAME_END] ="attr name end";
  [ST_ATTR_VAL] ="attr val";
  [ST_ATTR_VAL2] ="attr val2";
  [ST_ERROR] = "error";
}

function state_str(state)
	local mapped = state_str_mapper[state] or "err"
	return mapped
end




pico_event_str_mapper = {
  [EVENT_START] = "start tag";
  [EVENT_END] = "end tag";
  [EVENT_TEXT] = "text";
  [EVENT_ATTR_NAME] = "attr name";
  [EVENT_ATTR_VAL] = "attr val";
  [EVENT_END_DOC] = "end document";
}

function pico_event_str(event)
	local mapped = pico_event_str_mapper[event] or "err";
	return mapped;
end


-- Turn a pointer, offset, length of a string
-- into an integer value
GetInt = function(src, offset, len)
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
GetString = function (src, offset, len)
	local i, j, k
	local found = false;

	local sz = len;
	local buf = ffi.new("char[?]",(sz + 1));

	if(buf ~= nil) then
		i=offset;
		j=0;
		while (i<offset+sz) do
			-- i indexes src buffer, while j indexes output buffer
			-- do entity ref expansion
			if(src[i] == '&' and i+1 < sz) then
				i = i + 1;
				k = 0;
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
	end

	return ffi.string(buf);
end

--[[
	matches text with current event text; invalid for start/end
	document events; primarily useful in matching start tags;
	Note: NOT case sensitive!
--]]

Match = function(self, txt)
	local match = false;
	local len;

	if(txt ~= nil) then
		len = strlen(txt);
		if(self.ix + len < self.bufsz) then
			match = (0 == strncasecmp(self.buf + self.markix, txt, len));
		end
	end
	return match;
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
	pico_event_str(event)));
end

function test_xml()
	--local buf = strdup(case1);
	--local buf = strdup(cases.amf_case1);
	--local buf = strdup(cases.saml2_xsd);
	--local buf = strdup(cases.schema_case1);
	local buf = strdup(cases.x3d_case1);

	local len = strlen(buf)


	local xlex = luxl.new(buf, len);
	--xlex.MsgHandler = MsgHandler;

	for event, offset, size in xlex:Lexemes() do
		--print("Event: ", pico_event_str(event), offset, size);
		local txt = GetString(buf, offset, size);
		print(string.format("[%s] '%s'", pico_event_str(event), txt));
	end
end

test_xml();
