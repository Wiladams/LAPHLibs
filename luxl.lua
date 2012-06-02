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

	This lua version contains no copyright

]]

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band



-- Tables and constants

--[[
/* A table of the number of bytes in a UTF-8 sequence starting with
   the character used as the array index.  Note: a zero entry
   indicates an illegal initial byte. Generated with a python script
   from the utf-8 std. */
--]]
local utf8_len = ffi.new("const int[256]", {
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 0, 0
});

--[[
 Types of characters; 0 is not valid, 1 is letters, 2 are digits
   (including '.') and 3 whitespace. Also generated with a throw-away
   python script.
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



-- Types of events: start element, end element, text, attr name, attr
--   val and start/end document. Other events can be ignored!
EVENT_START = 0; -- Start tag
EVENT_END = 1;       -- End tag
EVENT_TEXT = 2;      -- Text
EVENT_ATTR_NAME = 3; -- Attribute name
EVENT_ATTR_VAL = 4;  -- Attribute value
EVENT_END_DOC = 5;   -- End of document
EVENT_MARK = 6;      -- Internal only; notes position in buffer
EVENT_NONE = 7;      -- Internal only; should never see this event


-- Internal states that the parser can be in at any given time.
ST_START = 0;         -- starting base state; default state
ST_TEXT =1;              -- text state
ST_START_TAG = 2;         -- start tag state
ST_START_TAGNAME =3;     -- start tagname state
ST_START_TAGNAME_END =4; -- start tagname ending state
ST_END_TAG =5;           -- end tag state
ST_END_TAGNAME=6;       -- end tag tagname state
ST_END_TAGNAME_END=7;   -- end tag tagname ending
ST_EMPTY_TAG=8;         -- empty tag state
ST_SPACE=9;             -- linear whitespace state
ST_ATTR_NAME=10;         -- attribute name state
ST_ATTR_NAME_END=11;     -- attribute name ending state
ST_ATTR_VAL=12;          -- attribute value starting state
ST_ATTR_VAL2=13;         -- attribute value state
ST_ERROR=14;              -- error state

-- character classes that we will match against; This could be expanded if
--   need be, however, we are aiming for simple.
CCLASS_NONE = 0;         -- matches nothing; a base state
CCLASS_LEFT_ANGLE=1;     -- matches start tag '<'
CCLASS_SLASH=2;          -- matches forward slash
CCLASS_RIGHT_ANGLE=3;    -- matches end tag '>'
CCLASS_EQUALS=4;         -- matches equals sign
CCLASS_QUOTE=5;          -- matches double-quotes
CCLASS_LETTERS=6;        -- matches a-zA-Z letters and digits 0-9
CCLASS_SPACE=7;          -- matches whitespace
CCLASS_ANY=8;            -- matches any ASCII character; will match all above classes


--[[
 State transition table element; contains:
 (1) current state,
 (2) clazz that must match,
 (3) next state if we match, and
 (4) event that is emitted upon match.
--]]

-- Note: States must be grouped in match order AND grouped together!
local PICO_STATES = {
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


luxl = {}
luxl_mt = {
	__index = luxl
}

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

--[[
	This is the main driver that moves through the state table based on
	characters in the input buffer. Returns an event type: start, end,
	text, attr name, attr val
--]]
function luxl:GetNext()
	local j;
	local c, jmp;
	local ctype;
	local match;


	local i = self.ix;
	local fired=false;
	local mark=0;

	while (i < self.bufsz and not fired) do
		c = band(self.buf[i], 0xff);
		jmp = utf8_len[c]; -- advance through buffer by utf-8 char sz
		assert(jmp ~= 0);
		self.ix = self.ix + jmp;
		if(self.MsgHandler) then
			self.MsgHandler(i, self.state, c)
		end

		ctype = char_type[c];
		j=1;
		match = false;
		while (PICO_STATES[j].state ~= ST_ERROR) do
			if(PICO_STATES[j].state == self.state) then
				if PICO_STATES[j].cclass == CCLASS_LETTERS then
					match = (ctype == 1 or ctype == 2);
				elseif PICO_STATES[j].cclass == CCLASS_LEFT_ANGLE then
					match = (c == string.byte('<'));
				elseif PICO_STATES[j].cclass ==  CCLASS_SLASH then
					match = (c == string.byte('/'));
				elseif PICO_STATES[j].cclass == CCLASS_RIGHT_ANGLE then
					match = (c == string.byte('>'));
				elseif PICO_STATES[j].cclass == CCLASS_EQUALS then
					match = (c == string.byte('='));
				elseif PICO_STATES[j].cclass == CCLASS_QUOTE then
					match = (c == string.byte('"'));
				elseif PICO_STATES[j].cclass == CCLASS_SPACE then
					match = (ctype == 3);
				elseif PICO_STATES[j].cclass == CCLASS_ANY then
					match = true;
				end


				if(match) then
					-- we matched a character class
					if(PICO_STATES[j].event == EVENT_MARK) then
						if(mark == 0) then
							mark = i;
						end -- mark the position
					elseif(PICO_STATES[j].event ~= EVENT_NONE) then
						if(mark > 0) then
							-- basically we are guaranteed never to have an event of
							--   type EVENT_MARK or EVENT_NONE here.
							self.markix = mark;
							self.marksz = i-mark;
							self.event = PICO_STATES[j].event;
							fired = true;
							if(self.EventHandler) then
								self.EventHandler(p.event, self.markix, self.marksz)
							end
						end
					end

					self.state = PICO_STATES[j].next_state; -- change state
					break; -- break out of loop though state search
				end
			end

			j = j + 1
		end

		if(match==0) then
			-- didn't match, default to start state
			self.err = self.err + 1;
			if self.ErrHandler then
				self.ErrHandler(i, self.state, c);
			end
			self.state = ST_START;
		end
		i = i + jmp
	end

	if(not fired) then
		self.event = PICO_EVENT_END_DOC;
	end

	return self.event, self.markix, self.marksz;
end

function luxl:Lexemes()
	return function()
		local event, offset, size = self:GetNext();
		if(event == PICO_EVENT_END_DOC) then
			return nil;
		else
			return event, offset, size;
		end
	end
end

return luxl
