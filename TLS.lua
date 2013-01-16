

local ffi = require ("ffi")
local BinaryStream = require("BinaryStream")


TLS = {}

-- A.1. Record layer

TLS.ProtocolVersion_t = {}
TLS.ProtocolVersion_mt = {
	__tostring = function(self)
		return string.format("%d.%d", self.major, self.minor)
	end,

	__index = TLS.ProtocolVersion_t,
}


TLS.ProtocolVersion = function(major, minor)
	major = major or 0
	minor = minor or 0

	local obj = {major=major, minor=minor}
	setmetatable(obj, TLS.ProtocolVersion_mt)

	return obj;
end

TLS.ProtocolVersion_t.Length = function(self)
	return 2;
end

TLS.ProtocolVersion_t.WriteToStream = function(self, bstream)
	bstream:WriteByte(self.major);
	bstream:WriteByte(self.minor);
end

TLS.ProtocolVersion_t.ReadFromStream = function(self, bstream)
	self.major = bstream:ReadByte();
	self.minor = bstream:ReadByte();
end

-- Create an instace
TLS.version = TLS.ProtocolVersion(3, 1);     -- TLS v1.0


-- uint8_t
TLS.ContentType = {
	change_cipher_spec 	= 20;
	alert 				= 21;
	handshake 			= 22;
	application_data 	= 23;
}



--[[
	TLSPlaintext
--]]

TLS.TLSPlaintext_t = {}
TLS.TLSPlaintext_mt = {
	__tostring = function(self)
		return string.format([[{ContentType= %d, version= %s,length= %d}]], 
			self.ContentType, tostring(self.version), self.length)
	end,

	__index = TLS.TLSPlaintext_t
}

TLS.TLSPlaintext = function(ctype, fragment, length, version)
	length = length or 0
	version = version or TLS.version;

	local obj = {
		ContentType = ctype,
		version = version,
		fragment = fragment,
		length = length,
	}
	setmetatable(obj, TLS.TLSPlaintext_mt);
	
	return obj
end 

TLS.TLSPlaintext_t.Length = function(self)
	return self.length;
end

TLS.TLSPlaintext_t.WriteToStream = function(self, bstream)
	bstream:WriteByte(self.ContentType);
	self.version:WriteToStream(bstream)
	bstream:WriteInt16(self.length);
	if self.fragment then
		bstream:WriteBytes(ffi.cast("const uint8_t *", self.fragment), self.length);
	end
end

TLS.TLSPlaintext_t.ReadFromStream = function(self, bstream)
	self.ContentType = bstream:ReadByte()
	self.version = TLS.ProtocolVersion():ReadFromStream(bstream)
	self.length = bstream:ReadUInt16()
	self.fragment = ffi.new("uint8_t[?]", self.length)
	bstream:ReadBytes(self.fragment, self.length, 0)
end 



ffi.cdef[[
/*
typedef struct {
        uint8_t type;			// ContentType
        ProtocolVersion version;
        uint16_t length;
        uint8_t * fragment;		// [TLSCompressed.length];
} TLSCompressed;

typedef struct stream_ciphered struct {
        uint8_t * content;		// [TLSCompressed.length];
        uint8_t * MAC;			// [CipherSpec.hash_size];
} GenericStreamCipher;

typedef struct {				// block-ciphered 
        uint8_t * content;		// [TLSCompressed.length];
        uint8_t * MAC;			// [CipherSpec.hash_size];
        uint8_t * padding;		// [?];		[GenericBlockCipher.padding_length];
        uint8_t padding_length;
} GenericBlockCipher;

typedef struct {
        uint8_t type;
        ProtocolVersion version;
        uint16_t length;
        union  {				// (CipherSpec.cipher_type)
            GenericStreamCipher stream;
            GenericBlockCipher block;
        } fragment;
} TLSCiphertext;
*/
]]






-- A.2. Change cipher specs message

TLS.ChangeCipherSpec = {
	change_cipher_spec = 1;
}


-- A.3. Alert messages
-- uint8_t
TLS.AlertLevel = { 
	warning = 1; 
	fatal = 2;
}

-- uint8_t
TLS.AlertDescription = {
	close_notify =(0);
	unexpected_message =(10);
	bad_record_mac = (20);
	decryption_failed = (21);
	record_overflow = (22);
	decompression_failure = (30);
	handshake_failure = (40);
	bad_certificate = (42);
	unsupported_certificate = (43);
	certificate_revoked = (44);
	certificate_expired = (45);
	certificate_unknown = (46);
	illegal_parameter = (47);
	unknown_ca = (48);
	access_denied = (49);
	decode_error = (50);
	decrypt_error = (51);
	export_restriction = (60);
	protocol_version = (70);
	insufficient_security = (71);
	nternal_error = (80);
	user_canceled = (90);
	no_renegotiation = (100);
}

TLS.Alert_t = {}
TLS.Alert_mt = {
	__index = Alert_t;

}
TLS.Alert = function(level, description)
	local obj = {
		level = level;				-- uint8_t
		description = description;	-- uint8_t
	}
	setmetatable(obj, TLS.Alert_mt)

	return obj
end

TLS.Alert_t.WriteToStream = function(self, bstream)	
	bstream:WriteByte(self.level);
	bstream:WriteByte(self.description);
end



-- A.4.1. Hello messages
--[[
	HelloRequest
--]]
TLS.HelloRequest_t = {}
TLS.HelloRequest_mt = {
	__index = TLS.HelloRequest_t
}
TLS.HelloRequest = function()
	local obj = {}

	setmetatable(obj, TLS.HelloRequest_mt)

	return obj
end

TLS.HelloRequest_t.Length = function(self)
	return 0;
end

--[[
	Random
--]]
TLS.Random_t = {}
TLS.Random_mt = {
	__index = TLS.Random_t,
}
TLS.Random = function(random_bytes, unix_time)
	unix_time = unix_time or os.time();
	random_bytes = random_bytes	or ffi.new("uint8_t[28]");  -- 28 bytes

	local obj = {
		gmt_unix_time = unix_time,
		random_bytes = random_bytes
	}
	setmetatable(obj, TLS.Random_mt)

	return obj
end

TLS.Random_t.Length = function(self)
	return 4 + 28;
end

TLS.Random_t.WriteToStream = function(self, bstream)
	bstream:WriteInt32(self.gmt_unix_time);
	bstream:WriteBytes(self.random_bytes, 28);
end

TLS.Random_t.ReadFromStream = function(self, bstream)
	self.gmt_unix_time = bstream:ReadByte();
	bstream:ReadBytes(self.random_bytes, 28, 0);
end

--[[
	SessionID
--]]
TLS.SessionID_t = {}
TLS.SessionID_mt = {
	__len = function(self)
		return 32;
	end,

	__index = TLS.SessionID_t,	
}
TLS.SessionID = function()
	local obj = {
		data = ffi.new("uint8_t[32]");
	}
	setmetatable(obj, TLS.SessionID_mt)

	return obj;
end

TLS.SessionID_t.Length = function(self)
	return 32;
end

TLS.SessionID_t.WriteToStream = function(self, bstream)
	bstream:WriteBytes(self.data, self:Length())
end

TLS.SessionID_t.ReadFromStream = function(self, bstream)
	bstream:ReadBytes(self.data, self:Length(), 0);
end



TLS.CipherSuite_t = {}
TLS.CipherSuite_mt = {
	__index = TLS.CipherSuite_t
}
--TLS.CipherSuite = ffi.typeof("CipherSuite")
TLS.CipherSuite = function(a,b)
	local obj = {a,b}

	setmetatable(obj, TLS.CipherSuite_mt)

	return obj
end

TLS.CipherSuite_t.WriteToStream = function(self, stream)
	stream:WriteByte(self.a)
	stream:WriteByte(self.b)
end



TLS.CompressionMethod = 
{ 
	null = 0;
}


--[[
	ClientHello
--]]
TLS.ClientHello_t = {}
TLS.ClientHello_mt = {
	__index = TLS.ClientHello_t,
}
TLS.ClientHello = function(random, session_id, cipher_suites, compression_methods)
	random = random or TLS.Random()
	session_id = session_id or TLS.SessionID();

	cipher_suites = cipher_suites or {TLS.TLS_RSA_WITH_RC4_128_SHA, TLS.TLS_RSA_WITH_NULL_SHA}
	compression_methods = compression_methods or {TLS.CompressionMethod.null}

	local obj = {
		client_version = TLS.version,
		random = random,
		session_id = session_id,
		cipher_suites = cipher_suites,
		compression_methods = compression_methods
	}
	setmetatable(obj, TLS.ClientHello_mt)

	return obj
end

TLS.ClientHello_t.Length = function(self)
	local len = self.client_version:Length();
	len = len + self.random:Length();
	len = len + self.session_id:Length();
	if self.cipher_suite then
		len = len + #self.cipher_suites * cipher_suites[1]:Length();
	end
	if self.compression_methods then
		len = len + #self.compression_methods;
	end

	return len;
end

TLS.ClientHello_t.WriteToStream = function(self, bstream)
	self.client_version:WriteToStream(bstream)
	self.random:WriteToStream(bstream)
	self.session_id:WriteToStream(bstream)

	for i=1,#self.cipher_suites do
		self.cipher_suites[i]:WriteToStream(bstream)
	end

	for i=1,#self.compression_methods do
		bstream:WriteByte(self.compression_methods[i]);
	end
end

--[[
	ServerHello
--]]

TLS.ServerHello_t = {}
TLS.ServerHello_mt = {
	__index = TLS.ServerHello_t,
}
TLS.ServerHello = function(random, session_id, cipher_suite, compression_method)
	local obj = {
		server_version = TLS.version,
		random = random,
		session_id = session_id,
		cipher_suite = cipher_suite,
		compression_method = compression_method,
	}

	setmetatable(obj, TLS.ServerHello_mt)
	return obj
end

TLS.ServerHello_t.WriteToStream = function(self, bstream)
	self.server_version:WriteToStream(bstream);
	self.random:WriteToStream(bstream);
	self.session_id:WriteToStream(bstream);
	self.cipher_suite:WriteToStream(bstream);
	self.compression_method:WriteToStream(bstream);
end

-- A.4. Handshake protocol
-- uint8_t
TLS.HandshakeType = {
	hello_request		= 0; 
	client_hello		= 1; 
	server_hello 		= 2;
	certificate 		= 11;
	server_key_exchange = 12;
	certificate_request = 13; 
	server_hello_done 	= 14;
	certificate_verify 	= 15;
	client_key_exchange = 16;
	finished 			= 20;
}

TLS.HandshakeTypeMap = {
	[TLS.HandshakeType.hello_request]		= TLS.HelloRequest; 
	[TLS.HandshakeType.client_hello]		= TLS.ClientHello; 
	[TLS.HandshakeType.server_hello] 		= TLS.ServerHello;
	[TLS.HandshakeType.certificate] 		= nil;
	[TLS.HandshakeType.server_key_exchange] = nil;
	[TLS.HandshakeType.certificate_request] = nil; 
	[TLS.HandshakeType.server_hello_done] 	= nil;
	[TLS.HandshakeType.certificate_verify] 	= nil;
	[TLS.HandshakeType.client_key_exchange] = nil;
	[TLS.HandshakeType.finished] 			= nil;
	
}

ffi.cdef[[
/*
typedef struct {
	uint8_t msg_type;		// HandshakeType
    uint32_t length;		// uint24
    union {			// HandshakeType
		HelloRequest 		hello_request;
		ClientHello 		client_hello;
		ServerHello 		server_hello;
		Certificate 		certificate;
		ServerKeyExchange 	server_key_exchange;
		CertificateRequest 	certificate_request;
		ServerHelloDone 	server_hello_done;
		CertificateVerify 	certificate_verify;
		ClientKeyExchange 	client_key_exchange;
		Finished 			finished;
	} body;
} Handshake;
*/
]]

TLS.Handshake_t = {}
TLS.Handshake_mt = {
	__index = TLS.Handshake_t;
}
TLS.Handshake = function(msg_type, body)
	local length
	if body then length = body:Length() end

	local obj = {
		msg_type	= msg_type,
		body 		= body,
		length 		= length,
	}
	setmetatable(obj, TLS.Handshake_mt)

	return obj
end

TLS.Handshake_t.Length = function(self)
	return self.length;
end

TLS.Handshake_t.WriteToStream = function(self, bstream)
	self.length = self.body:Length();

	bstream:WriteByte(self.msg_type);
	bstream:WriteInt32(self.length);
	self.body:WriteToStream(bstream);
end

TLS.Handshake_t.ReadFromStream = function(self, bstream)
	self.msg_type = bstream:ReadByte();
	self.length = bstream:ReadInt32();
	local constructor = TLS.HandshakeTypeMap[self.msg_type]
	if constructor then
		self.body = constructor()
		self.body:ReadFromStream(bstream)
	else
		-- read the length specified
		-- skipping over a part we don't understand
	end
end


-- A.4.3. Client authentication and key exchange messages
--[=[
ffi.cdef[[
    struct {
        select (KeyExchangeAlgorithm) {
            case rsa: EncryptedPreMasterSecret;
            case diffie_hellman: DiffieHellmanClientPublicValue;
        } exchange_keys;
    } ClientKeyExchange;

    struct {
        ProtocolVersion client_version;
        opaque random[46];

    } PreMasterSecret;

    struct {
        public-key-encrypted PreMasterSecret pre_master_secret;
    } EncryptedPreMasterSecret;

    enum { implicit, explicit } PublicValueEncoding;

    typedef struct {
        select (PublicValueEncoding) {
            case implicit: struct {};
            case explicit: opaque DH_Yc<1..2^16-1>;
       } dh_public;
} ClientDiffieHellmanPublic;
]]


ffi.cdef[[
typedef struct {
	Signature signature;
} CertificateVerify;

typedef struct {
	uint8_t verify_data[12];
} Finished;
]]
--]=]


-- A.5. The CipherSuite



--[[
TLS_NULL_WITH_NULL_NULL is specified and is the initial state of a
   TLS connection during the first handshake on that channel, but must
   not be negotiated, as it provides no more protection than an
   unsecured connection.
--]]

TLS.TLS_NULL_WITH_NULL_NULL = TLS.CipherSuite(0x00,00);


--[[
   The following CipherSuite definitions require that the server provide
   an RSA certificate that can be used for key exchange. The server may
   request either an RSA or a DSS signature-capable certificate in the
   certificate request message.
--]]
TLS.TLS_RSA_WITH_NULL_MD5					= TLS.CipherSuite(0x00,0x01);
TLS.TLS_RSA_WITH_NULL_SHA					= TLS.CipherSuite(0x00,0x02);
TLS.TLS_RSA_EXPORT_WITH_RC4_40_MD5			= TLS.CipherSuite(0x00,0x03);
TLS.TLS_RSA_WITH_RC4_128_MD5				= TLS.CipherSuite(0x00,0x04);
TLS.TLS_RSA_WITH_RC4_128_SHA				= TLS.CipherSuite(0x00,0x05);
TLS.TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5		= TLS.CipherSuite(0x00,0x06);
TLS.TLS_RSA_WITH_IDEA_CBC_SHA				= TLS.CipherSuite(0x00,0x07);
TLS.TLS_RSA_EXPORT_WITH_DES40_CBC_SHA 		= TLS.CipherSuite(0x00,0x08);
TLS.TLS_RSA_WITH_DES_CBC_SHA 				= TLS.CipherSuite(0x00,0x09);
TLS.TLS_RSA_WITH_3DES_EDE_CBC_SHA 			= TLS.CipherSuite(0x00,0x0A);


--[[
 The following CipherSuite definitions are used for server-
   authenticated (and optionally client-authenticated) Diffie-Hellman.
   DH denotes cipher suites in which the server's certificate contains
   the Diffie-Hellman parameters signed by the certificate authority
   (CA). DHE denotes ephemeral Diffie-Hellman, where the Diffie-Hellman
   parameters are signed by a DSS or RSA certificate, which has been
   signed by the CA. The signing algorithm used is specified after the
   DH or DHE parameter. The server can request an RSA or DSS signature-
   capable certificate from the client for client authentication or it
   may request a Diffie-Hellman certificate. Any Diffie-Hellman
   certificate provided by the client must use the parameters (group and
   generator) described by the server.
   ]]

TLS.TLS_DH_DSS_EXPORT_WITH_DES40_CBC_SHA   = TLS.CipherSuite(0x00,0x0B );
TLS.TLS_DH_DSS_WITH_DES_CBC_SHA            = TLS.CipherSuite(0x00,0x0C );
TLS.TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA       = TLS.CipherSuite(0x00,0x0D );
TLS.TLS_DH_RSA_EXPORT_WITH_DES40_CBC_SHA   = TLS.CipherSuite(0x00,0x0E );
TLS.TLS_DH_RSA_WITH_DES_CBC_SHA            = TLS.CipherSuite(0x00,0x0F );
TLS.TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA       = TLS.CipherSuite(0x00,0x10 );
TLS.TLS_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA  = TLS.CipherSuite(0x00,0x11 );
TLS.TLS_DHE_DSS_WITH_DES_CBC_SHA           = TLS.CipherSuite(0x00,0x12 );
TLS.TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA      = TLS.CipherSuite(0x00,0x13 );
TLS.TLS_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA  = TLS.CipherSuite(0x00,0x14 );
TLS.TLS_DHE_RSA_WITH_DES_CBC_SHA           = TLS.CipherSuite(0x00,0x15 );
TLS.TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA      = TLS.CipherSuite(0x00,0x16 );

 --[[
   The following cipher suites are used for completely anonymous
   Diffie-Hellman communications in which neither party is
   authenticated. Note that this mode is vulnerable to man-in-the-middle
   attacks and is therefore deprecated.

     TLS_DH_anon_EXPORT_WITH_RC4_40_MD5     = CipherSuite{ 0x00,0x17 };
     TLS_DH_anon_WITH_RC4_128_MD5           = CipherSuite{ 0x00,0x18 };
     TLS_DH_anon_EXPORT_WITH_DES40_CBC_SHA  = CipherSuite{ 0x00,0x19 };
     TLS_DH_anon_WITH_DES_CBC_SHA           = CipherSuite{ 0x00,0x1A };
     TLS_DH_anon_WITH_3DES_EDE_CBC_SHA      = CipherSuite{ 0x00,0x1B };
--]]

TLS.buff2num(buff, len)
	local value = 0
	for i=1,len do
		value = bor(lshift(value,8), buff[len-1])
	end
end

TLS.num2buff(num)
end

return TLS;
