--[[
	Abstract interface for a stream object

	function Stream:Seek(offset, origin)
	end

	function Stream:ReadByte()
		return nil;
	end

	function Stream:ReadBytes(buffer, len, offset)
		return 0
	end

	function Stream:ReadString(count)
		return nil
	end


	function Stream:WriteByte(value)
		return 0
	end

	function Stream:WriteBytes(buffer, len, offset)
		return 0
	end

	function Stream:WriteString(str, count, offset)
		offset = offset or 0
		count = count or #str

		return self:WriteBytes(str, count, offset)
	end
--]]

local STREAM_SEEK_SET = 0	-- from beginning
local STREAM_SEEK_CUR = 1	-- from current position
local STREAM_SEEK_END = 2	-- from end

return {
	SEEK_SET = STREAM_SEEK_SET,
	SEEK_CUR = STREAM_SEEK_CUR,
	SEEK_END = STREAM_SEEK_END,
}
