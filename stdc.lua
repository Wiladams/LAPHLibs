if not stdc_included then
stdc_included = true

require "cctype"
require "limits"
require "stdint"
require "wchar"
require "memutils"


return {
	memutils = require "memutils",
	stringz = require "stringzutils",
}
end
