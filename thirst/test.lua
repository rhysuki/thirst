local lust = require("thirst.thirst2")
print("up'n'running")

lust.it("test", {
	lust.expect.equals(1, 1),
	lust.expect.not_equal(1, 1)
})

-- lust.finish()
