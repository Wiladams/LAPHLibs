--[[
	References

	http://www.faqs.org/rfcs/rfc3076.html
	http://www.w3.org/TR/REC-xml/

	This code was derived from the pico_xml project
	which can be found here:

	http://kd7yhr.org/bushbo/pico_xml.md

	The original code, written in C by Brian O. Bush
	contained the following copyright:

	Copyright (c) 2004-2006 by Brian O. Bush


]]

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band


--[[
 Types of characters; 0 is not valid, 1 is letters, 2 are digits
   (including '.') and 3 whitespace. 
--]]

local char_type = ffi.new("const int[256]", {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 3, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
});



-- Internal states that the parser can be in at any given time.
local ST_START = 0;         -- starting base state; default state
local ST_TEXT =1;              -- text state
local ST_START_TAG = 2;         -- start tag state
local ST_START_TAGNAME =3;     -- start tagname state
local ST_START_TAGNAME_END =4; -- start tagname ending state
local ST_END_TAG =5;           -- end tag state
local ST_END_TAGNAME=6;       -- end tag tagname state
local ST_END_TAGNAME_END=7;   -- end tag tagname ending
local ST_EMPTY_TAG=8;         -- empty tag state
local ST_SPACE=9;             -- linear whitespace state
local ST_ATTR_NAME=10;         -- attribute name state
local ST_ATTR_NAME_END=11;     -- attribute name ending state
local ST_ATTR_VAL=12;          -- attribute value starting state
local ST_ATTR_VAL2=13;         -- attribute value state
local ST_ERROR=14;              -- error state

-- character classes that we will match against; This could be expanded if
--   need be, however, we are aiming for simple.
local CCLASS_NONE = 0;         -- matches nothing; a base state
local CCLASS_LEFT_ANGLE=1;     -- matches start tag '<'
local CCLASS_SLASH=2;          -- matches forward slash
local CCLASS_RIGHT_ANGLE=3;    -- matches end tag '>'
local CCLASS_EQUALS=4;         -- matches equals sign
local CCLASS_QUOTE=5;          -- matches double-quotes
local CCLASS_LETTERS=6;        -- matches a-zA-Z letters and digits 0-9
local CCLASS_SPACE=7;          -- matches whitespace
local CCLASS_ANY=8;            -- matches any ASCII character; will match all above classes

-- Types of events: start element, end element, text, attr name, attr
-- val and start/end document. Other events can be ignored!
local EVENT_START = 0; 	 -- Start tag
local EVENT_END = 1;       -- End tag
local EVENT_TEXT = 2;      -- Text
local EVENT_ATTR_NAME = 3; -- Attribute name
local EVENT_ATTR_VAL = 4;  -- Attribute value
local EVENT_END_DOC = 5;   -- End of document
local EVENT_MARK = 6;      -- Internal only; notes position in buffer
local EVENT_NONE = 7;      -- Internal only; should never see this event

local entity_refs =  {
  ["&lt;"] = '<',
  ["&gt;"] = '>',
  ["&amp;"] = '&',
  ["&apos;"] = '\'',
  ["&quot;"] = '"',
}

--[[
 State transition table element; contains:
 (1) current state,
 (2) clazz that must match,
 (3) next state if we match, and
 (4) event that is emitted upon match.
--]]

-- Note: States must be grouped in match order AND grouped together!
local LEXER_STATES = {
  -- [0-2] starting state, which also serves as the default state in case of error
  { state = ST_START,         cclass = CCLASS_SPACE,        next_state = ST_SPACE,             event = EVENT_NONE },
  { state = ST_START,         cclass = CCLASS_LEFT_ANGLE,   next_state = ST_START_TAG,         event = EVENT_NONE },
  { state = ST_START,         cclass = CCLASS_ANY,          next_state = ST_TEXT,              event = EVENT_MARK },

  -- [3-5] space state handles linear white space
  { state = ST_SPACE,         cclass = CCLASS_SPACE,        next_state = ST_SPACE,             event = EVENT_NONE },
  { state = ST_SPACE,         cclass = CCLASS_LEFT_ANGLE,   next_state = ST_START_TAG,         event = EVENT_TEXT },
  { state = ST_SPACE,         cclass = CCLASS_ANY,          next_state = ST_TEXT,              event = EVENT_MARK },

  -- [6-8] handle start tag
  { state = ST_START_TAG,     cclass = CCLASS_LETTERS,      next_state = ST_START_TAGNAME,     event = EVENT_MARK },
  { state = ST_START_TAG,     cclass = CCLASS_SLASH,        next_state = ST_END_TAG,           event = EVENT_MARK },
  { state = ST_START_TAG,     cclass = CCLASS_SPACE,        next_state = ST_START_TAG,         event = EVENT_NONE },	-- < tag >

  -- [9-12] handle start tag name
  { state = ST_START_TAGNAME, cclass = CCLASS_LETTERS,      next_state = ST_START_TAGNAME,     event = EVENT_NONE },
  { state = ST_START_TAGNAME, cclass = CCLASS_SPACE,        next_state = ST_START_TAGNAME_END, event = EVENT_START },
  { state = ST_START_TAGNAME, cclass = CCLASS_SLASH,        next_state = ST_EMPTY_TAG,         event = EVENT_END },
  { state = ST_START_TAGNAME, cclass = CCLASS_RIGHT_ANGLE,  next_state = ST_START,             event = EVENT_START },

  -- [13-16] handle start tag name end
  { state = ST_START_TAGNAME_END,  cclass = CCLASS_LETTERS, next_state = ST_ATTR_NAME,         event = EVENT_MARK },
  { state = ST_START_TAGNAME_END,  cclass = CCLASS_SPACE,   next_state = ST_START_TAGNAME_END, event = EVENT_NONE },
  { state = ST_START_TAGNAME_END,  cclass = CCLASS_RIGHT_ANGLE, next_state = ST_START,         event = EVENT_START },
  { state = ST_START_TAGNAME_END,  cclass = CCLASS_SLASH,   next_state = ST_EMPTY_TAG,         event = EVENT_MARK },	-- Empty tag <br />

  -- [17] handle empty tags, e.g., <br />
  { state = ST_EMPTY_TAG,     cclass = CCLASS_RIGHT_ANGLE,  next_state = ST_START,             event = EVENT_END },	-- Empty tag <br />

  -- [18] handle end tag, e.g., <tag />
  { state = ST_END_TAG,       cclass = CCLASS_LETTERS,      next_state = ST_END_TAGNAME,       event = EVENT_NONE },

  -- [19-21] handle end tag name
  { state = ST_END_TAGNAME,   cclass = CCLASS_LETTERS,      next_state = ST_END_TAGNAME,       event = EVENT_NONE },
  { state = ST_END_TAGNAME,   cclass = CCLASS_RIGHT_ANGLE,  next_state = ST_START,             event = EVENT_END },
  { state = ST_END_TAGNAME,   cclass = CCLASS_SPACE,        next_state = ST_END_TAGNAME_END,   event = EVENT_END },	-- space after end tag name </br >

  -- [22-23] handle ending of end tag name
  { state = ST_END_TAGNAME_END, cclass = CCLASS_SPACE,      next_state = ST_END_TAGNAME_END,   event = EVENT_NONE },
  { state = ST_END_TAGNAME_END, cclass = CCLASS_RIGHT_ANGLE,next_state = ST_START,             event = EVENT_NONE },

  -- [24-26] handle text
  { state = ST_TEXT,          cclass = CCLASS_SPACE,        next_state = ST_SPACE,             event = EVENT_NONE },
  { state = ST_TEXT,          cclass = CCLASS_LEFT_ANGLE,   next_state = ST_START_TAG,         event = EVENT_TEXT },
  { state = ST_TEXT,          cclass = CCLASS_ANY,          next_state = ST_TEXT,              event = EVENT_NONE },

  -- [27-29] handle attribute names
  { state = ST_ATTR_NAME,     cclass = CCLASS_LETTERS,      next_state = ST_ATTR_NAME,         event = EVENT_MARK },
  { state = ST_ATTR_NAME,     cclass = CCLASS_SPACE,        next_state = ST_ATTR_NAME_END,     event = EVENT_ATTR_NAME },	-- space before '=' sign
  { state = ST_ATTR_NAME,     cclass = CCLASS_EQUALS,       next_state = ST_ATTR_VAL,          event = EVENT_ATTR_NAME },	-- <tag attr ="2">

  -- [30-32] attribute name end
  { state = ST_ATTR_NAME_END, cclass = CCLASS_SPACE,        next_state = ST_ATTR_NAME_END,     event = EVENT_NONE },
  { state = ST_ATTR_NAME_END, cclass = CCLASS_LETTERS,      next_state = ST_ATTR_NAME,         event = EVENT_MARK },
  { state = ST_ATTR_NAME_END, cclass = CCLASS_EQUALS,       next_state = ST_ATTR_VAL,          event = EVENT_NONE },

  -- [33-34] handle attribute values, initial quote and spaces
  { state = ST_ATTR_VAL,      cclass = CCLASS_QUOTE,        next_state = ST_ATTR_VAL2,         event = EVENT_NONE },
  { state = ST_ATTR_VAL,      cclass = CCLASS_SPACE,        next_state = ST_ATTR_VAL,          event = EVENT_NONE },		-- initial spaces before quoted attribute value

  -- [35-37] handle actual attribute values
  { state = ST_ATTR_VAL2,     cclass = CCLASS_QUOTE,        next_state = ST_START_TAGNAME_END, event = EVENT_ATTR_VAL },
  { state = ST_ATTR_VAL2,     cclass = CCLASS_LETTERS,      next_state = ST_ATTR_VAL2,         event = EVENT_MARK },
  { state = ST_ATTR_VAL2,     cclass = CCLASS_SLASH,        next_state = ST_ATTR_VAL2,         event = EVENT_NONE },

  -- [38] End of table marker
  { state = ST_ERROR,         cclass = CCLASS_NONE,         next_state = ST_ERROR,             event = EVENT_NONE }
};

local T_LT = string.byte('<')
local T_SLASH = string.byte('/')
local T_GT = string.byte('>')
local T_EQ = string.byte('=')
local T_QUOTE = string.byte('"')

local cclass_match = {
[CCLASS_LETTERS] = "(ctype == 1 or ctype == 2)",
[CCLASS_LEFT_ANGLE] = "(c == T_LT)",
[CCLASS_SLASH] = "(c == T_SLASH)",
[CCLASS_RIGHT_ANGLE] = "(c == T_GT)",
[CCLASS_EQUALS] = "(c == T_EQ)",
[CCLASS_QUOTE] = "(c == T_QUOTE)",
[CCLASS_SPACE] = "(ctype == 3)",
[CCLASS_ANY] = "true",
}

local STATES = {}
for i=1,#LEXER_STATES do
	local p_state = LEXER_STATES[i]
	local state = STATES[p_state.state]
	local cclasses
	if not state then
		cclasses = {}
		state = { state = p_state.state, cclasses = cclasses }
		STATES[p_state.state] = state
	else
		cclasses = state.cclasses
	end
	cclasses[#cclasses + 1] = p_state
end


local luxl = {
	EVENT_START = EVENT_START; 	 -- Start tag
	EVENT_END = EVENT_END;       -- End tag
	EVENT_TEXT = EVENT_TEXT;      -- Text
	EVENT_ATTR_NAME = EVENT_ATTR_NAME; -- Attribute name
	EVENT_ATTR_VAL = EVENT_ATTR_VAL;  -- Attribute value
	EVENT_END_DOC = EVENT_END_DOC;   -- End of document
	EVENT_MARK = EVENT_MARK;      -- Internal only; notes position in buffer
	EVENT_NONE = EVENT_NONE;      -- Internal only; should never see this event
}
local luxl_mt = { __index = luxl }

function luxl.new(buffer, bufflen)
	local newone = {
		buf = buffer;			-- pointer to "uint8_t *" buffer (0 based)
		bufsz = bufflen;		-- size of input buffer
		state = ST_START;		-- current state
		event = EVENT_NONE;		-- current event
		ix = 0;					-- current index we're reading from
		err = 0;				-- number of errors thus far
		markix = 0;				-- offset of current item of interest
		marksz = 0;				-- size of current item of interest
		MsgHandler = nil;		-- Routine to handle messages
		ErrHandler = nil;		-- Routine to call when there's an error
		EventHandler = nil;
	}
	setmetatable(newone, luxl_mt);

	return newone;
end


function luxl:SetMessageHandler(handler)
	self.MsgHandler = handler;
end

function luxl:GetString()
	local str = ffi.string(self.buf + self.markix, self.marksz)
	-- only text and attribute value events can contain entities.
	if self.event == EVENT_TEXT or self.event == EVENT_ATTR_VAL then
		return str:gsub("(&%w;)", entity_refs)
	end
	return str
end

	--[[
	GetNext is responsible for moving through the stream
	of characters.  At the moment, it's fairly naive in 
	terms of character encodings.
	
	In a more robust implementation, luxl will read from a 
	stream, which knows about the specific encoding, and 
	will hand out code points based on that particular encoding.
	
	So, only straight ASCII for the moment.
	
	Returns event type, starting offset, size
	--]]

function luxl:GetNext()
	local j;
	local c;
	local ctype;


	local i = self.ix;
	local fired=false;
	local mark=0;

	while (i < self.bufsz and not fired) do
		c = band(self.buf[i], 0xff);
		ctype = char_type[c];
		self.ix = self.ix + 1;
		if(self.MsgHandler) then
			self.MsgHandler(i, self.state, c)
		end

		local state = STATES[self.state]
		local cclasses = state.cclasses
		local match = false;
		for j=1,#cclasses do
			local cclass = cclasses[j]
			if cclass.cclass == CCLASS_LETTERS then
				match = (ctype == 1 or ctype == 2);
			elseif cclass.cclass == CCLASS_LEFT_ANGLE then
				match = (c == T_LT);
			elseif cclass.cclass ==  CCLASS_SLASH then
				match = (c == T_SLASH);
			elseif cclass.cclass == CCLASS_RIGHT_ANGLE then
				match = (c == T_GT);
			elseif cclass.cclass == CCLASS_EQUALS then
				match = (c == T_EQ);
			elseif cclass.cclass == CCLASS_QUOTE then
				match = (c == T_QUOTE);
			elseif cclass.cclass == CCLASS_SPACE then
				match = (ctype == 3);
			elseif cclass.cclass == CCLASS_ANY then
				match = true;
			end



			if(match) then
				-- we matched a character class
				if(cclass.event == EVENT_MARK) then
					if(mark == 0) then
						mark = i;
					end -- mark the position
				elseif(cclass.event ~= EVENT_NONE) then
					if(mark > 0) then
						-- basically we are guaranteed never to have an event of
						--   type EVENT_MARK or EVENT_NONE here.
						self.markix = mark;
						self.marksz = i-mark;
						self.event = cclass.event;
						fired = true;
						if(self.EventHandler) then
							self.EventHandler(self.event, self.markix, self.marksz)
						end
					end
				end

				self.state = cclass.next_state; -- change state
				break; -- break out of loop though state search
			end
		end

		if(match==0) then
			-- didn't match, default to start state
			self.err = self.err + 1;
			if self.ErrHandler then
				self.ErrHandler(i, self.state, c);
			end
			self.state = ST_START;
		end
		i = i + 1
	end

	if(not fired) then
		self.event = EVENT_END_DOC;
	end

	return self.event, self.markix, self.marksz;
end
	
function luxl:Lexemes()
	return function()
		local event, offset, size = self:GetNext();
		if(event == EVENT_END_DOC) then
			return nil;
		else
			return event, offset, size;
		end
	end
end

return luxl
