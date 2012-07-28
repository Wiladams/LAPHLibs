package.path = package.path..";..\\?.lua";

local bencode = require "bencode"

local atable = {
	["Name"] = {"William", "Albert", "Adams"},
	["Age"] = 47,
	["Address"] = {
		Street1 = "958 111th Ave NE",
		Street2 = "Apt 2301",
		City = "Bellevue",
		State = "WA",
		Zip = 98004},
	}

local encoded = bencode.encode(atable)

print("== ENCODED ==")
print(encoded);

print("== DECODED ==")
local decoded = bencode.decode(encoded)
print(decoded)

print("== REENCODED ==")
local reencoded = bencode.encode(decoded)
print(reencoded)
assert((reencoded == encoded), "reencoding not equal to encoding");
print("PASS")
