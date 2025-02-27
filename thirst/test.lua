local lust = require("thirst.thirst2")
local expect = lust.expect
print("up'n'running")

lust.it("test", {
	expect.equals(1, 1),
	expect.in_between(3, 5, 20),
	expect.function_works(function() error(":( fuck my puppy life......no wet food") end)
})

-- lust.finish()
