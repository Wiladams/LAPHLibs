package.path = package.path..";../?.lua";

local StringBuilder = require("stringbuilder")

local function testAppend()
    print("==== testAppend() ====")

    local sb1 = StringBuilder();

    sb1:append("the quick")
    sb1:append("fox")
    sb1:append("jumps over")
    sb1:append("the lazy dogs")
    sb1:append("back")

    print(tostring(sb1))
end

local function testMetaAdd()
    print("==== testMetaAdd() ====")

    local sb = StringBuilder();

    sb = sb + "the quick " + "brown fox " + "jumps over " + "the lazy dogs " + "back"

    print(tostring(sb))
end

--[[
    Overriding '__concat' doesn't work for string literals because
    the parser will enact the string concatenation function on the 
    individual string segments before calling the '__concat' meta
    function on the stringbuilder object itself.

    __concat will work when you are trying to concatenate other 
    things such as table values.
]]
local function testMetaConcatStrings()
    print("==== testMetaConcat() ====")

    local sb = StringBuilder();

    sb = sb.."the quick ".."brown fox ".."jumps over ".."the lazy dogs ".."back"

    print(tostring(sb))
end

local function testMetaConcatSBuilder()
    print("==== testMetaConcatInts() ====")

    local sb = StringBuilder();
    sb = sb + "the quick " + "brown fox " + "jumps over "
    
    local sb2 = StringBuilder();
    sb2 = sb2 + "the lazy dogs " + "back"
    sb = sb..sb2;

    print(tostring(sb))
end


local function testLineEnding()
    print("==== testLineEnding() ====")

    local sb1 = StringBuilder();

print("StringBuilder: ", StringBuilder, "sb1: ", sb1)

    sb1:append("the quick")
    sb1:append("fox")
    sb1:append("jumps over")
    sb1:append("the lazy dogs")
    sb1:append("back")

    print(sb1:toString("\n"))
end

testMetaAdd();
testMetaConcatStrings();
testMetaConcatSBuilder();
--testAppend();
--testLineEnding();
