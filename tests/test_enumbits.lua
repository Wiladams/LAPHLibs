--test_enumbits.lua
package.path = package.path..";../?.lua"
local bit = require("bit")
local lshift, rshift, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor

local enumbits = require("enumbits")

local testtbl = {
	LOWEST 	= 0x0001;
	MEDIUM 	= 0x0002;
	HIGHEST = 0x0004;
	MIGHTY 	= 0x0008;
	SLUGGO 	= 0x0010;
	MUGGO 	= 0x0020;
	BUGGO 	= 0x0040;
	PUGGO 	= 0x0080;
}


local caps = {
	V4L2_CAP_VIDEO_CAPTURE		= 0x00000001 ; -- Is a video capture device */
	V4L2_CAP_VIDEO_OUTPUT		= 0x00000002; -- Is a video output device */
	V4L2_CAP_VIDEO_OVERLAY		= 0x00000004; -- Can do video overlay */
	V4L2_CAP_VBI_CAPTURE		= 0x00000010; -- Is a raw VBI capture device */
	V4L2_CAP_VBI_OUTPUT			= 0x00000020; -- Is a raw VBI output device */
	V4L2_CAP_SLICED_VBI_CAPTURE	= 0x00000040; -- Is a sliced VBI capture device */
	V4L2_CAP_SLICED_VBI_OUTPUT	= 0x00000080; -- Is a sliced VBI output device */
	V4L2_CAP_RDS_CAPTURE		= 0x00000100; -- RDS data capture */
	V4L2_CAP_VIDEO_OUTPUT_OVERLAY	= 0x00000200; -- Can do video output overlay */
	V4L2_CAP_HW_FREQ_SEEK		= 0x00000400; -- Can do hardware frequency seek  */
	V4L2_CAP_RDS_OUTPUT			= 0x00000800; -- Is an RDS encoder */

	V4L2_CAP_VIDEO_CAPTURE_MPLANE	= 0x00001000;
	V4L2_CAP_VIDEO_OUTPUT_MPLANE	= 0x00002000;
	V4L2_CAP_VIDEO_M2M_MPLANE		= 0x00004000;
	V4L2_CAP_VIDEO_M2M				= 0x00008000;

	V4L2_CAP_TUNER			= 0x00010000; -- has a tuner */
	V4L2_CAP_AUDIO			= 0x00020000; -- has audio support */
	V4L2_CAP_RADIO			= 0x00040000; -- is a radio device */
	V4L2_CAP_MODULATOR		= 0x00080000; -- has a modulator */

	V4L2_CAP_READWRITE              = 0x01000000; -- read/write systemcalls */
	V4L2_CAP_ASYNCIO                = 0x02000000; -- async I/O */
	V4L2_CAP_STREAMING              = 0x04000000; -- streaming I/O ioctls */
}

local function printBits(bitsValue, tbl)
	tbl = tbl or testtbl
	for _, name in enumbits(bitsValue, tbl) do
		io.write(string.format("%s, ",name))
	end
	print()
end

-- single bits
printBits(lshift(1,0))
printBits(lshift(1,1))
printBits(lshift(1,31))

-- combined bits
printBits(0x0045)
printBits(0x04000001, caps)