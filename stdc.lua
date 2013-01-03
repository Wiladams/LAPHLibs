if not stdc_included then
stdc_included = true

require "c99_types"
require "cctype"
require "limits"
require "memutils"


return {
	memutils = require "memutils",
	stringz = require "stringzutils",
}
end
