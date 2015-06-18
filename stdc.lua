local exports = {}

if not stdc_included then
stdc_included = true


exports.c99_types = require "c99_types";
exports.cctype = require("cctype");
exports.limits = require("limits");
exports.memutils = require "memutils";
exports.stringz = require "stringzutils";

function exports.atoi(str)
	return tonumber(str, 10);
end

exports.atol = exports.atoi;
exports.atoll = exports.atoi;

return exports
