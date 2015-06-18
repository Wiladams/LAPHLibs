package.path = package.path..";../?.lua";

local ffi = require "ffi"

local bitbang = require "bitbang"
-- make them global
for k,v in pairs(bitbang) do
	_G[k] = v;
end


function test_booleanstring()
	print("==== test_booleanstring ====")
    print("4: ", numbertobinary(4, 8))
    print("8: ", numbertobinary(8, 8))
    print("0x0f: ", numbertobinary(0x0f, 16))
    print("0xff: ", numbertobinary(0xff, 16))
end

function test_stringtonumber()
	print("==== test_stringtonumber ====")
	print(binarytonumber(numbertobinary(4,8)))
	print(binarytonumber(numbertobinary(8,8)))
	print(binarytonumber(numbertobinary(0x0f,16)))
	print(binarytonumber(numbertobinary(0xff,16)))
end

function test_bitstring()
	print("==== test_bitstring ====")
--local function numbertobinary(value, nbits, bigendian)

    print("1: ", numbertobinary(1, 4,true))
    print("3: ", numbertobinary(3, 4,true))

    print("1: ", getbitstring(1, 0,4))
    print("2: ", getbitstring(3, 0,2))
	print("6:3 - ",getbitstring(6, 1,2))
end

function test_getbitsvalue()
	print("==== test_getbitsvalue ====")
	print("0", getbitsvalue(0, 0, 8))
	print("3", getbitsvalue(3, 0, 8))
	print("3", getbitsvalue(6, 1, 8))
	print("255", getbitsvalue(0xff, 0, 8))

	local bin1 = "11000000"
	local n1 = binarytonumber(bin1) -- little endian by default

	print("Binary 3: ", getbitsvalue(n1, 0, 2))
end



function test_modulus()
	print("1 % 8: ", 1 % 8);
	print("2 % 8: ", 2 % 8);
	print("7 % 8: ", 7 % 8);
	print("8 % 8: ", 8 % 8);

	for i=0,32 do
		print("i: ", i, getbitbyteoffset(i))
	end
end

function test_bitsfrombytes()
	-- Construct a string that looks like this
	-- 4 bits - version    (3)
	-- 4 bits - subversion (3)
	-- 24 bits - 523
--	local bitstr = "00100100101010101010101010101010"
--	local num = binarytonumber(bitstr)
--	local bt = bittypes();
--	bt.UInt32 = num

--	print("Bits: ", bytestobinary(bt.b, 4, 0))
	local bytes = ffi.new("uint8_t[4]")
	--setbitstobytes(bytes, startbit, bitcount, value)
	setbitstobytes(bytes, 0, 4, 4)
	setbitstobytes(bytes, 4, 4, 2)
	setbitstobytes(bytes, 8, 24, 5592405);
	print(bytestobinary(bytes, 4))


	local version = getbitsfrombytes(bytes, 0, 4)
	local subversion = getbitsfrombytes(bytes, 4, 4)
	local randval = getbitsfrombytes(bytes, 8, 24)

	print("Version: ", version);
	print("Sub: ", subversion);
	print("Radval: ", randval);

end

function test_clearbit()
	local bits = 0xfb
	--local bits = 0xff
	local bigendian = true;

	-- Try clearing a bit that is already cleared
	print(string.format("0x%x - ", bits), numbertobinary(bits, 8, bigendian))
	bits = clearbit(bits, 2)
	print(string.format("0x%x - ", bits), numbertobinary(bits, 8, bigendian))

	-- Clear a bit that is not already cleared
	bits = 0xff
	print("====")
	print(string.format("0x%x - ", bits), numbertobinary(bits, 8, bigendian))
	bits = clearbit(bits, 2)
	print(string.format("0x%x - ", bits), numbertobinary(bits, 8, bigendian))

end


function test_swap()
	local StreamIsBe = false
	local hostle = ffi.abi("le")

	local needswap = StreamIsBe == hostle

	print("stream BE: false  hostle: true", false == true);
	print("stream BE: false  hostle: false", false == false);
	print("stream BE: true  hostle: true", true == true);
	print("stream BE: true  hostle: false", true == false);
end

test_booleanstring()
--test_stringtonumber()
test_bitstring();
test_getbitsvalue();
test_bitbytes();
--test_modulus();
--test_bitsfrombytes();


--test_clearbit()

--test_swap();
