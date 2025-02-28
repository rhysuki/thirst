local section, push_section, pop_section, it, expect = THIRST.section, THIRST.push_section, THIRST.pop_section, THIRST
	.it, THIRST.expect

---@param fn function
---@param outcome boolean
---@param ...any
local function test_expect_outcome(fn, outcome, ...)
	return expect.equals(fn(...).success, outcome)
end

push_section("expect")
section("pass")
it("succeeds", {
	test_expect_outcome(expect.pass, true)
})

section("fail")
it("fails", {
	test_expect_outcome(expect.fail, false)
})

section("exists")
it("succeeds with existing values", {
	test_expect_outcome(expect.exists, true, true),
	test_expect_outcome(expect.exists, true, false),
	test_expect_outcome(expect.exists, true, {}),
})
it("fails on nil", {
	test_expect_outcome(expect.exists, false, nil)
})

section("does_not_exist")
it("fails on existing values", {
	test_expect_outcome(expect.does_not_exist, false, true),
	test_expect_outcome(expect.does_not_exist, false, false),
	test_expect_outcome(expect.does_not_exist, false, {}),
})
it("succeeds with nil", {
	test_expect_outcome(expect.does_not_exist, true, nil)
})

section("is_a")
it("succeeds with matching types", {
	test_expect_outcome(expect.is_a, true, "aaa", "string"),
	test_expect_outcome(expect.is_a, true, true, "boolean"),
	test_expect_outcome(expect.is_a, true, false, "boolean"),
	test_expect_outcome(expect.is_a, true, {}, "table"),
	test_expect_outcome(expect.is_a, true, 10, "number"),
})

it("fails with mismatched types", {
	test_expect_outcome(expect.is_a, false, "aaa", "boolean"),
	test_expect_outcome(expect.is_a, false, "aaa", "number"),
	test_expect_outcome(expect.is_a, false, "aaa", "table"),
	test_expect_outcome(expect.is_a, false, true, "table"),
	test_expect_outcome(expect.is_a, false, true, "number"),
	test_expect_outcome(expect.is_a, false, true, "string"),
	test_expect_outcome(expect.is_a, false, {}, "number"),
	test_expect_outcome(expect.is_a, false, {}, "boolean"),
	test_expect_outcome(expect.is_a, false, {}, "string"),
	test_expect_outcome(expect.is_a, false, 10, "table"),
	test_expect_outcome(expect.is_a, false, 10, "boolean"),
	test_expect_outcome(expect.is_a, false, 10, "string"),
})

section("is_not_a")
it("fails with matching types", {
	test_expect_outcome(expect.is_not_a, false, "aaa", "string"),
	test_expect_outcome(expect.is_not_a, false, true, "boolean"),
	test_expect_outcome(expect.is_not_a, false, false, "boolean"),
	test_expect_outcome(expect.is_not_a, false, {}, "table"),
	test_expect_outcome(expect.is_not_a, false, 10, "number"),
})

it("succeeds with mismatched types", {
	test_expect_outcome(expect.is_not_a, true, "aaa", "boolean"),
	test_expect_outcome(expect.is_not_a, true, "aaa", "number"),
	test_expect_outcome(expect.is_not_a, true, "aaa", "table"),
	test_expect_outcome(expect.is_not_a, true, true, "table"),
	test_expect_outcome(expect.is_not_a, true, true, "number"),
	test_expect_outcome(expect.is_not_a, true, true, "string"),
	test_expect_outcome(expect.is_not_a, true, {}, "number"),
	test_expect_outcome(expect.is_not_a, true, {}, "boolean"),
	test_expect_outcome(expect.is_not_a, true, {}, "string"),
	test_expect_outcome(expect.is_not_a, true, 10, "table"),
	test_expect_outcome(expect.is_not_a, true, 10, "boolean"),
	test_expect_outcome(expect.is_not_a, true, 10, "string"),
})

section("function_works")
it("succeeds with working functions", {
	test_expect_outcome(expect.function_works, true, function() end),
	test_expect_outcome(expect.function_works, true, math.sin, 2),
	test_expect_outcome(expect.function_works, true, table.insert, {}, 10),
})

it("fails with errorring functions", {
	test_expect_outcome(expect.function_works, false, function() error() end),
	test_expect_outcome(expect.function_works, false, math.sin, true),
	test_expect_outcome(expect.function_works, false, table.insert, 10),
})

section("function_fails")
it("fails with working functions", {
	test_expect_outcome(expect.function_fails, false, function() end),
	test_expect_outcome(expect.function_fails, false, math.sin, 2),
	test_expect_outcome(expect.function_fails, false, table.insert, {}, 10),
})

it("succeeds with errorring functions", {
	test_expect_outcome(expect.function_fails, true, function() error() end),
	test_expect_outcome(expect.function_fails, true, math.sin, true),
	test_expect_outcome(expect.function_fails, true, table.insert, 10),
})

section("contains")
it("succeeds with existent values", {
	test_expect_outcome(expect.contains, true, {10, 20, 30}, 20),
	test_expect_outcome(expect.contains, true, {"a", "b", "c"}, "b"),
	test_expect_outcome(expect.contains, true, {a = 1, [true] = 2, c = 3}, 2),
	test_expect_outcome(expect.contains, true, {a = 1, [{}] = 2, c = 3}, 2),
})

it("fails with nonexistent values", {
	test_expect_outcome(expect.contains, false, {10, 20, 30}, 40),
	test_expect_outcome(expect.contains, false, {"a", "b", "c"}, "d"),
	test_expect_outcome(expect.contains, false, {a = 1, [true] = 2, c = 3}, 4),
	test_expect_outcome(expect.contains, false, {a = 1, [{}] = 2, c = 3}, 4),
})

it("fails with empty tables", {
	test_expect_outcome(expect.contains, false, {}, 10),
	test_expect_outcome(expect.contains, false, {}, nil),
})

it("errors with invalid data", {
	expect.function_fails(expect.contains, true, 10),
	expect.function_fails(expect.contains, "", 10),
	expect.function_fails(expect.contains, 10, 10),
})

section("does_not_contain")
it("fails with existent values", {
	test_expect_outcome(expect.does_not_contain, false, {10, 20, 30}, 20),
	test_expect_outcome(expect.does_not_contain, false, {"a", "b", "c"}, "b"),
	test_expect_outcome(expect.does_not_contain, false, {a = 1, [true] = 2, c = 3}, 2),
	test_expect_outcome(expect.does_not_contain, false, {a = 1, [{}] = 2, c = 3}, 2),
})

it("succeeds with nonexistent values", {
	test_expect_outcome(expect.does_not_contain, true, {10, 20, 30}, 40),
	test_expect_outcome(expect.does_not_contain, true, {"a", "b", "c"}, "d"),
	test_expect_outcome(expect.does_not_contain, true, {a = 1, [true] = 2, c = 3}, 4),
	test_expect_outcome(expect.does_not_contain, true, {a = 1, [{}] = 2, c = 3}, 4),
})

it("succeeds with empty tables", {
	test_expect_outcome(expect.does_not_contain, true, {}, 10),
	test_expect_outcome(expect.does_not_contain, true, {}, nil),
})

it("errors with invalid data", {
	expect.function_fails(expect.does_not_contain, true, 10),
	expect.function_fails(expect.does_not_contain, "", 10),
	expect.function_fails(expect.does_not_contain, 10, 10),
})

section("is_empty")
it("succeeds with empty tables", {
	test_expect_outcome(expect.is_empty, true, {}),
	test_expect_outcome(expect.is_empty, true, {nil, nil, nil}),
	test_expect_outcome(expect.is_empty, true, {a = nil}),
})

it("fails with non-empty tables", {
	test_expect_outcome(expect.is_empty, false, {10}),
	test_expect_outcome(expect.is_empty, false, {a = 10}),
	test_expect_outcome(expect.is_empty, false, {a = 10, 10}),
})

it("errors with invalid data", {
	expect.function_fails(expect.is_empty, 10),
	expect.function_fails(expect.is_empty, "string"),
	expect.function_fails(expect.is_empty, true),
})

section("is_not_empty")
it("fails with empty tables", {
	test_expect_outcome(expect.is_not_empty, false, {}),
	test_expect_outcome(expect.is_not_empty, false, {nil, nil, nil}),
	test_expect_outcome(expect.is_not_empty, false, {a = nil}),
})

it("succeeds with non-empty tables", {
	test_expect_outcome(expect.is_not_empty, true, {10}),
	test_expect_outcome(expect.is_not_empty, true, {a = 10}),
	test_expect_outcome(expect.is_not_empty, true, {a = 10, 10}),
})

it("errors with invalid data", {
	expect.function_fails(expect.is_not_empty, 10),
	expect.function_fails(expect.is_not_empty, "string"),
	expect.function_fails(expect.is_not_empty, true),
})

--I don't really feel like testing all the basic assertions since they're so obviously
--self evident

section("in_between")
it("succeeds with correct data", {
	test_expect_outcome(expect.in_between, true, 1, 0, 10),
	test_expect_outcome(expect.in_between, true, 0, 0, 10),
	test_expect_outcome(expect.in_between, true, 1.1, 1, 1.2),
	test_expect_outcome(expect.in_between, true, 1, -10, 10),
	test_expect_outcome(expect.in_between, true, -40, -50, -30),
})

it("fails with wrong data", {
	test_expect_outcome(expect.in_between, false, -1, 0, 10),
	test_expect_outcome(expect.in_between, false, 1, 100, -100),
	test_expect_outcome(expect.in_between, false, 20, 0, 10),
	test_expect_outcome(expect.in_between, false, 0.9, 1, 1.2),
	test_expect_outcome(expect.in_between, false, -11, -10, 10),
	test_expect_outcome(expect.in_between, false, -70, -50, -30),
	test_expect_outcome(expect.in_between, false, -20, -40, -30),
})

it("errors with invalid data", {
	expect.function_fails(expect.in_between, false, 10, 10),
	expect.function_fails(expect.in_between, 10, false, 10),
	expect.function_fails(expect.in_between, 10, 10, false),
	expect.function_fails(expect.in_between, 10, {}, 10),
	expect.function_fails(expect.in_between, 10, "string", 10),
	expect.function_fails(expect.in_between, 10, true, 10),
})

section("not_in_between")
it("fails with correct data", {
	test_expect_outcome(expect.not_in_between, false, 1, 0, 10),
	test_expect_outcome(expect.not_in_between, false, 0, 0, 10),
	test_expect_outcome(expect.not_in_between, false, 1.1, 1, 1.2),
	test_expect_outcome(expect.not_in_between, false, 1, -10, 10),
	test_expect_outcome(expect.not_in_between, false, -40, -50, -30),
})

it("succeeds with wrong data", {
	test_expect_outcome(expect.not_in_between, true, -1, 0, 10),
	test_expect_outcome(expect.not_in_between, true, 1, 100, -100),
	test_expect_outcome(expect.not_in_between, true, 20, 0, 10),
	test_expect_outcome(expect.not_in_between, true, 0.9, 1, 1.2),
	test_expect_outcome(expect.not_in_between, true, -11, -10, 10),
	test_expect_outcome(expect.not_in_between, true, -70, -50, -30),
	test_expect_outcome(expect.not_in_between, true, -20, -40, -30),
})

it("errors with invalid data", {
	expect.function_fails(expect.not_in_between, false, 10, 10),
	expect.function_fails(expect.not_in_between, 10, false, 10),
	expect.function_fails(expect.not_in_between, 10, 10, false),
	expect.function_fails(expect.not_in_between, 10, {}, 10),
	expect.function_fails(expect.not_in_between, 10, "string", 10),
	expect.function_fails(expect.not_in_between, 10, true, 10),
})
