--[[
	This table and the accompanying routines can be used
	for several different purposes.  If an application has
	the need for ASCII characters with names and descriptions,
	it can just access the table directly.

	Another usage is to use the table to generate constant
	values, that are easy to use.  The GetASCIITokens() function
	will create a string that contains all of the characters
	represented as constants, such as:

	T_A = 65;
	T_CR = 13;
	T_COLON = 58;

	This string can be copied into a program and the values used.

	Another way to do it is to use the routines is to run the
	function: CreateASCIITokens()

	This will first run GetASCIITokens(), to get a string representing
	the constants, then it will use loadstring() to actually make the
	constants available in the running program.

	The most likely usage is to simply generate the string, and copy
	it into your program and use the constants.
--]]

ASCIILookupTable = {
{"NUL",		0, "null"};
{"SOH",		1, "start of heading"};
{"STX",		2, "start of text"};
{"ETX",		3, "end of text"};
{"EOT",		4, "end of transmission"};
{"ENQ",		5, "enquiry"};
{"ACK",		6, "acknowledge"};
{"BEL",		7, "bell"};
{"BS",		8, "backspace"};
{"HT",		9, "horizontal tab"};
{"LF",		10, "NL line feed, new line"};
{"VT",		11, "vertical tab"};
{"FF",		12, "NP form feed, new page"};
{"CR",		13, "carriage return"};
{"SO",		14, "shift out"};
{"SI",		15,  "shift in"};
{"DLE",		16, "data link escape"};
{"DC1",		17, "device control 1"};
{"DC2",		18, "device control 2"};
{"DC3",		19, "device control 3"};
{"DC4",		20, "device control 4"};
{"NAK",		21, "negative acknowledge"};
{"SYN",		22, "synchronous idle"};
{"ETB",		23, "end of trans. block"};
{"CAN",		24, "cancel"};
{"EM",		25, "end of medium"};
{"SUB",		26, "substitute"};
{"ESC",		27, "escape"};
{"FS",		28, "file separator"};
{"GS",		29, "group separator"};
{"RS",		30, "record separator"};
{"US",		31, "unit separator"};
{"SP",		32,  "space"};
{"EXCLAIM",	33,  "exclamation mark"};		-- !
{"DQUOTE",	34,  "double quote"};			-- "
{"HASH",	35,  "number sign"};			-- #
{"DOLLAR",	36,  "dollar sign"};			-- $
{"PERCENT",	37,  "percent sign"};			-- %
{"AMP",		38,  "ampersand"};				-- &
{"SQUOTE",	39,  "apostrophe"};				-- '
{"LPAREN",  40,  "left parenthesis"};		-- (
{"RPAREN",	41,  "right parenthesis"};		-- )
{"ASTERISK",42,  "asterisk"};				-- *
{"PLUS",	43,  "plus sign"};				-- +
{"COMMA",	44,  "comma"};					-- ,
{"HYPHEN",	45,  "hyphen"};					-- -
{"PERIOD",	46,  "period"};					-- .
{"SLASH",	47,  "slash"};					-- /
{"0",		48,  "0"};
{"1",		49,  "1"};
{"2",    	50,  "2"};
{"3",		51,  "3"};
{"4",		52,  "4"};
{"5",		53,  "5"};
{"6",		54,  "6"};
{"7",		55,  "7"};
{"8",		56,  "8"};
{"9",		57,  "9"};
{"COLON",	58,  "colon"};					-- :
{"SEMI",	59,  "semicolon"};				-- ;
{"LANGLE",	60,  "less-than sign"};			-- <
{"EQUAL",	61,  "equals sign"};			-- =
{"RANGLE",	62,  "greater-than sign"};		-- >
{"QUES",	63,  "question mark"};			-- ?
{"AT",		64,  "at sign"};				-- @
{"A",		65,  "A"};
{"B",		66,  "B"};
{"C",		67,  "C"};
{"D",		68,  "D"};
{"E",		69,  "E"};
{"F",		70,  "F"};
{"G",		71,  "G"};
{"H",		72,  "H"};
{"I",		73,  "I"};
{"J",		74,  "J"};
{"K",		75,  "K"};
{"L",		76,  "L"};
{"M",		77,  "M"};
{"N",		78,  "N"};
{"O",		79,  "O"};
{"P",		80,  "P"};
{"Q",		81,  "Q"};
{"R",		82,  "R"};
{"S",		83,  "S"};
{"T",		84,  "T"};
{"U",		85,  "U"};
{"V",		86,  "V"};
{"W",		87,  "W"};
{"X",		88,  "X"};
{"Y",		89,  "Y"};
{"Z",		90,  "Z"};
{"LBRACKET",91,  "left square bracket"};	-- [
{"BACKSLASH",92, "backslash"};				-- \
{"RBRACKET",93,  "right square bracket"};	-- ]
{"HAT",		94,  "caret"};  				-- ^
{"UNDER",	95,  "underscore"};				-- _
{"LQUOTE",	96,  "grave accent"};			-- `
{"a",		97,  "a"};
{"b",		98,  "b"};
{"c",		99,  "c"};
{"d",		100,  "d"};
{"e",		101,  "e"};
{"f",		102,  "f"};
{"g",		103,  "g"};
{"h",		104,  "h"};
{"i",		105,  "i"};
{"j",		106,  "j"};
{"k",		107,  "k"};
{"l",		108,  "l"};
{"m",		109,  "m"};
{"n",		110,  "n"};
{"o",		111,  "o"};
{"p",		112,  "p"};
{"q",		113,  "q"};
{"r",		114,  "r"};
{"s",		115,  "s"};
{"t",		116,  "t"};
{"u",		117,  "u"};
{"v",		118,  "v"};
{"w",		119,  "w"};
{"x",		120,  "x"};
{"y",		121,  "y"};
{"z",		122,  "z"};
{"LCURLY",	123,  "left curly brace"};		-- {
{"PIPE",	124,  "vertical bar"};			-- |
{"RCURLY",	125,  "right curly brace"};		-- }
{"TILDE",	126,  "tilde"};					-- ~
{"DEL",		127,  "delete"};
}

function GetASCIITokens()
	local res = {};

	for i,v in ipairs(ASCIILookupTable) do
		table.insert(res, string.format("T_%s = %d;\n", v[1], v[2]));
	end

	return table.concat(res);
end

function CreateASCIITokens()
	local str = GetASCIITokens()
	local f = loadstring(str)
	f();
end

--print(GetASCIITokens())

-- Use the following if you want character constants
-- to be available in your program
--CreateASCIITokens();

