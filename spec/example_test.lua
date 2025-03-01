local thirst = require("thirst")
local expect = thirst.expect

thirst.section("examples")
thirst.it("is as convenient as possible to write", {
	expect.equals(1, 1),
	expect.is_not_a(true, "number"),
	expect.function_works(function() return math.floor(1.5) end)
})

thirst.it("error examples", {
	expect.equals(true, false),
	expect.is_a(function() end, "boolean"),
	expect.shallow_equals({10, 20, 30}, {10, 20, 999})
})
