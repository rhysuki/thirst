local lust = require("thirst.thirst2")
print("up'n'running")

lust.section("test")
lust.it("haaa", {lust.test_equals(1, 0)})
lust.it("haaa", {lust.test_equals(1, 0)})
lust.it("haaa", {lust.test_equals(1, 0)})
lust.it("haaa", {lust.test_equals(1, 0)})
lust.it("haaa", {lust.test_equals(1, 0)})
lust.it("haaa", {lust.test_equals(1, 0)})

lust.push_section("top!")

lust.section("test")
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})
lust.it("haaa", {lust.test_equals(1, 1)})

lust.section("test")
lust.it("haaa", {lust.test_equals(1, 1)})

lust.pop_section()

lust.it("FFFFF", {lust.test_equals(1, 1)})

lust.finish()
--[[
lust.push_section("top")

-- this auto section knows it's inside the "top" section
-- starts a section
lust.auto_section("middle 1")
lust.it("blablabla", {})
lust.it("blablabla", {})
lust.it("blablabla", {})

-- this one too
--
lust.auto_section("middle 2")
lust.it("blablabla", {})
lust.it("blablabla", {})
lust.it("blablabla", {})

lust.pop_section()

-- this one's part of no section.
lust.auto_section("bhlablabal")
]]
