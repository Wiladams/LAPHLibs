
local STATES, next_char, char_type = ...

local T_LT = string.byte('<')
local T_SLASH = string.byte('/')
local T_GT = string.byte('>')
local T_EQ = string.byte('=')
local T_QUOTE = string.byte('"')

local ST_START_f
local ST_TEXT_f
local ST_START_TAG_f
local ST_START_TAGNAME_f
local ST_START_TAGNAME_END_f
local ST_END_TAG_f
local ST_END_TAGNAME_f
local ST_END_TAGNAME_END_f
local ST_EMPTY_TAG_f
local ST_SPACE_f
local ST_ATTR_NAME_f
local ST_ATTR_NAME_END_f
local ST_ATTR_VAL_f
local ST_ATTR_VAL2_f
local ST_ERROR_f
function ST_START_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 3) then
    return next_char(ps, ST_SPACE_f, verbose)
  elseif (c == T_LT) then
    return next_char(ps, ST_START_TAG_f, verbose)
  end
  if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
  return next_char(ps, ST_TEXT_f, verbose)
end
STATES[0] = ST_START_f
STATES[ST_START_f] = 0
function ST_TEXT_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 3) then
    return next_char(ps, ST_SPACE_f, verbose)
  elseif (c == T_LT) then
    if(ps.mark > 0) then
      return 2, ST_START_TAG_f
    end
    return next_char(ps, ST_START_TAG_f, verbose)
  end
  return next_char(ps, ST_TEXT_f, verbose)
end
STATES[1] = ST_TEXT_f
STATES[ST_TEXT_f] = 1
function ST_START_TAG_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 1 or ctype == 2) then
    if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
    return next_char(ps, ST_START_TAGNAME_f, verbose)
  elseif (c == T_SLASH) then
    if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
    return next_char(ps, ST_END_TAG_f, verbose)
  elseif (ctype == 3) then
    return next_char(ps, ST_START_TAG_f, verbose)
  end
  return nil, ST_START_TAG_f, c
end
STATES[2] = ST_START_TAG_f
STATES[ST_START_TAG_f] = 2
function ST_START_TAGNAME_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 1 or ctype == 2) then
    return next_char(ps, ST_START_TAGNAME_f, verbose)
  elseif (ctype == 3) then
    if(ps.mark > 0) then
      return 0, ST_START_TAGNAME_END_f
    end
    return next_char(ps, ST_START_TAGNAME_END_f, verbose)
  elseif (c == T_SLASH) then
    if(ps.mark > 0) then
      return 1, ST_EMPTY_TAG_f
    end
    return next_char(ps, ST_EMPTY_TAG_f, verbose)
  elseif (c == T_GT) then
    if(ps.mark > 0) then
      return 0, ST_START_f
    end
    return next_char(ps, ST_START_f, verbose)
  end
  return nil, ST_START_TAGNAME_f, c
end
STATES[3] = ST_START_TAGNAME_f
STATES[ST_START_TAGNAME_f] = 3
function ST_START_TAGNAME_END_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 1 or ctype == 2) then
    if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
    return next_char(ps, ST_ATTR_NAME_f, verbose)
  elseif (ctype == 3) then
    return next_char(ps, ST_START_TAGNAME_END_f, verbose)
  elseif (c == T_GT) then
    if(ps.mark > 0) then
      return 0, ST_START_f
    end
    return next_char(ps, ST_START_f, verbose)
  elseif (c == T_SLASH) then
    if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
    return next_char(ps, ST_EMPTY_TAG_f, verbose)
  end
  return nil, ST_START_TAGNAME_END_f, c
end
STATES[4] = ST_START_TAGNAME_END_f
STATES[ST_START_TAGNAME_END_f] = 4
function ST_END_TAG_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 1 or ctype == 2) then
    return next_char(ps, ST_END_TAGNAME_f, verbose)
  end
  return nil, ST_END_TAG_f, c
end
STATES[5] = ST_END_TAG_f
STATES[ST_END_TAG_f] = 5
function ST_END_TAGNAME_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 1 or ctype == 2) then
    return next_char(ps, ST_END_TAGNAME_f, verbose)
  elseif (c == T_GT) then
    if(ps.mark > 0) then
      return 1, ST_START_f
    end
    return next_char(ps, ST_START_f, verbose)
  elseif (ctype == 3) then
    if(ps.mark > 0) then
      return 1, ST_END_TAGNAME_END_f
    end
    return next_char(ps, ST_END_TAGNAME_END_f, verbose)
  end
  return nil, ST_END_TAGNAME_f, c
end
STATES[6] = ST_END_TAGNAME_f
STATES[ST_END_TAGNAME_f] = 6
function ST_END_TAGNAME_END_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 3) then
    return next_char(ps, ST_END_TAGNAME_END_f, verbose)
  elseif (c == T_GT) then
    return next_char(ps, ST_START_f, verbose)
  end
  return nil, ST_END_TAGNAME_END_f, c
end
STATES[7] = ST_END_TAGNAME_END_f
STATES[ST_END_TAGNAME_END_f] = 7
function ST_EMPTY_TAG_f(ps, c, verbose)
  local ctype = char_type[c]
  if (c == T_GT) then
    if(ps.mark > 0) then
      return 1, ST_START_f
    end
    return next_char(ps, ST_START_f, verbose)
  end
  return nil, ST_EMPTY_TAG_f, c
end
STATES[8] = ST_EMPTY_TAG_f
STATES[ST_EMPTY_TAG_f] = 8
function ST_SPACE_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 3) then
    return next_char(ps, ST_SPACE_f, verbose)
  elseif (c == T_LT) then
    if(ps.mark > 0) then
      return 2, ST_START_TAG_f
    end
    return next_char(ps, ST_START_TAG_f, verbose)
  end
  if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
  return next_char(ps, ST_TEXT_f, verbose)
end
STATES[9] = ST_SPACE_f
STATES[ST_SPACE_f] = 9
function ST_ATTR_NAME_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 1 or ctype == 2) then
    if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
    return next_char(ps, ST_ATTR_NAME_f, verbose)
  elseif (ctype == 3) then
    if(ps.mark > 0) then
      return 3, ST_ATTR_NAME_END_f
    end
    return next_char(ps, ST_ATTR_NAME_END_f, verbose)
  elseif (c == T_EQ) then
    if(ps.mark > 0) then
      return 3, ST_ATTR_VAL_f
    end
    return next_char(ps, ST_ATTR_VAL_f, verbose)
  end
  return nil, ST_ATTR_NAME_f, c
end
STATES[10] = ST_ATTR_NAME_f
STATES[ST_ATTR_NAME_f] = 10
function ST_ATTR_NAME_END_f(ps, c, verbose)
  local ctype = char_type[c]
  if (ctype == 3) then
    return next_char(ps, ST_ATTR_NAME_END_f, verbose)
  elseif (ctype == 1 or ctype == 2) then
    if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
    return next_char(ps, ST_ATTR_NAME_f, verbose)
  elseif (c == T_EQ) then
    return next_char(ps, ST_ATTR_VAL_f, verbose)
  end
  return nil, ST_ATTR_NAME_END_f, c
end
STATES[11] = ST_ATTR_NAME_END_f
STATES[ST_ATTR_NAME_END_f] = 11
function ST_ATTR_VAL_f(ps, c, verbose)
  local ctype = char_type[c]
  if (c == T_QUOTE) then
    return next_char(ps, ST_ATTR_VAL2_f, verbose)
  elseif (ctype == 3) then
    return next_char(ps, ST_ATTR_VAL_f, verbose)
  end
  return nil, ST_ATTR_VAL_f, c
end
STATES[12] = ST_ATTR_VAL_f
STATES[ST_ATTR_VAL_f] = 12
function ST_ATTR_VAL2_f(ps, c, verbose)
  local ctype = char_type[c]
  if (c == T_QUOTE) then
    if(ps.mark > 0) then
      return 4, ST_START_TAGNAME_END_f
    end
    return next_char(ps, ST_START_TAGNAME_END_f, verbose)
  elseif (ctype == 1 or ctype == 2) then
    if(ps.mark == 0) then ps.mark = ps.i end -- mark the position
    return next_char(ps, ST_ATTR_VAL2_f, verbose)
  elseif (c == T_SLASH) then
    return next_char(ps, ST_ATTR_VAL2_f, verbose)
  end
  return nil, ST_ATTR_VAL2_f, c
end
STATES[13] = ST_ATTR_VAL2_f
STATES[ST_ATTR_VAL2_f] = 13
function ST_ERROR_f(ps, c, verbose)
  local ctype = char_type[c]
  if nil then
    return next_char(ps, ST_ERROR_f, verbose)
  end
  return nil, ST_ERROR_f, c
end
STATES[14] = ST_ERROR_f
STATES[ST_ERROR_f] = 14

