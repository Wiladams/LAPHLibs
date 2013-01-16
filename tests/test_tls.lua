package.path = package.path..";../?.lua"

local ffi = require("ffi")

TLS = require ("TLS")



MemoryStream = require("MemoryStream")
BinaryStream = require("BinaryStream")


print("TLS Version: ", #TLS.version, TLS.version)


function testPlainText()
	local mstream = MemoryStream.new()
	local bstream = BinaryStream.new(mstream, true)
	local fraglen = 32;
	local fragment = ffi.new("uint8_t[?]", fraglen)
	local pt = TLS.TLSPlaintext(TLS.ContentType.handshake, fragment, fraglen)

	pt:WriteToStream(bstream)

	print("Stream Position: ",mstream.Position)
	print(pt)
end


function WriteHandshake(bstream, hs)
	bstream:WriteByte(TLS.ContentType.handshake);
	TLS.version:WriteToStream(bstream)
	bstream:WriteInt16(hs:Length());
	hs:WriteToStream(bstream)
end

function testClientHello()
	local mstream = MemoryStream.new()
	local bstream = BinaryStream.new(mstream, true)

	-- construct a ClientHello object
	local clienthello = TLS.ClientHello(random, session_id, 
			{TLS.TLS_RSA_WITH_RC4_128_SHA, TLS.TLS_RSA_WITH_NULL_SHA})

	print("Client Length: ", clienthello:Length());

	-- stuff it into a handshake object
	local handshake = TLS.Handshake(TLS.HandshakeType.client_hello, clienthello)

	-- write it out as plaintext
	WriteHandshake(bstream, handshake);

	print("Stream Position: ",mstream.Position)
end

--testPlainText();
testClientHello();

