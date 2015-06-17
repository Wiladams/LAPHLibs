local exports = {}

if not stdc_included then
stdc_included = true

print("std_cinclude")


exports.c99_types = require "c99_types";
exports.cctype = require("cctype");
exports.limits = require("limits");
exports.memutils = require "memutils";
exports.stringz = require "stringzutils";

end

return exports
