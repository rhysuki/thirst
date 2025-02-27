local lust = require("thirst.thirst2")
print("up'n'running")

lust.auto_section("test")
lust.it2("haaa", {lust.test_equals(1, 1)})

lust.push_section("top!")

lust.auto_section("test")
lust.it2("haaa", {lust.test_equals(1, 1)})

lust.auto_section("test")
lust.it2("haaa", {lust.test_equals(1, 1)})

lust.pop_section()

lust.it2("FFFFF", {lust.test_equals(1, 1)})
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
