local thirst = {
	_VERSION = 'v0.1.0',
	_DESCRIPTION = 'Painless wrapper around lust.lua, by bjornbytes',
	_URL = 'https://github.com/rhysuki/thirst',
	_LICENSE = nil
}
local path = (...):gsub('thirst$', '')
local lust = require(path .. 'lust')

thirst._tests = {}
thirst._name = ''
thirst._red = string.char(27) .. '[31m'
thirst._green = string.char(27) .. '[32m'
thirst._normal = string.char(27) .. '[0m'
thirst._pass = '[PASS]'
thirst._fail = '[FAIL]'

-- local functions --

local function is_empty(t)
	return #t == 0
end

-- inverts the status and the error messages of a test
local function invert_test(t)
	t.success = not t.success
	t.err, t.inverted_err = t.inverted_err, t.err
	return t
end

-- finds the path and line number where the current assertion came from
local function get_source_line()
	return debug.traceback('', 3):match('%s([^%s]+%.lua:%d+:)')
end

-- private functions --

function thirst._indent(level)
	return string.rep('\t', level or lust.level)
end

-- processes the current "it" block's results and prints them out
function thirst._process_tests()
	if is_empty(thirst._tests) then return end

	-- collect erroring tests
	local errors = {}
	for _, test in ipairs(thirst._tests) do
		if not test.success then
			table.insert(errors, test)
		end
	end

	local success = is_empty(errors)
	local color = success and thirst._green or thirst._red
	local label = success and thirst._pass or thirst._fail

	-- print outcome and errors, if any
	print(thirst._indent() .. color .. label .. thirst._normal .. ' ' .. thirst._name)

	for _, test in ipairs(errors) do
		print(thirst._indent(lust.level + 1) .. test.source_line .. ' ' .. test.err)
	end

	if success then lust.passes = lust.passes + 1
	else lust.errors = lust.errors + 1 end

	-- call the "after" funcs for the current level and each one below
	for level = 1, lust.level do
		if lust.afters[level] then
			for i = 1, #lust.afters[level] do
				lust.afters[level][i](thirst._name)
			end
		end
	end
end

-- finishes the current test and starts a new one
function thirst._start_new_test(name)
	if not is_empty(thirst._tests) then thirst._process_tests() end

	thirst._tests = {}
	thirst._name = name

	-- call the "before" funcs for the current level and each one below
	for level = 1, lust.level do
		if lust.befores[level] then
			for i = 1, #lust.befores[level] do
				lust.befores[level][i](thirst._name)
			end
		end
	end
end

function thirst._new_assertion(success, err, inverted_err)
	return {
		success = success,
		err = err,
		inverted_err = inverted_err,

		to_fail = invert_test,
		source_line = get_source_line()
	}
end

-- inserts a new block of tests to the stack
function thirst._push(name)
	print(thirst._indent() .. name)
	lust.level = lust.level + 1
end

-- removes the topmost block of tests from the stack
function thirst._pop()
	lust.befores[lust.level] = {}
	lust.afters[lust.level] = {}
	lust.level = lust.level - 1
end

-- pushes the result of a test to the current tests
function thirst._expect(result)
	if result.success then result.err = nil end
	table.insert(thirst._tests, result)
end

-- public API --

-- TODO: replace this with a set_color(bool)?
function thirst.nocolor()
	thirst._red = ''
	thirst._green = ''
	thirst._normal = ''
	return thirst
end

-- starts a new block of tests
function thirst.describe(name)
	if lust.level > 0 then thirst._pop() end
	thirst._push(name)
end

-- starts a new test. you can pass in a list of assertions,
-- and it'll add all of them to the list of results
function thirst.it(name, assertions)
	thirst._start_new_test(name)

	if assertions then
		for _, assertion in ipairs(assertions) do
			thirst._expect(assertion)
		end
	end
end

-- processes the current tests and prints out all results
function thirst.finish()
	if not is_empty(thirst._tests) then thirst._process_tests() end

	print("============================")
	print(("PASSES: %i\nFAILS: %i\nCoverage: %.1f%%"):format(
		lust.passes,
		lust.errors,
		(lust.passes / (lust.passes + lust.errors)) * 100
	))
	print("============================")
end

--[[
	assertion functions

	all functions return 3 values in the order: check, error message,
	inverted error message.
	the inverted error message gets set when the test gets inverted, ie,
	when the expected result and the error message get flipped around,
	namely with a invert_test()/to_fail() call.
--]]

function thirst.exists(a)
	return thirst._new_assertion(
		(a ~= nil),
		("expected %s to exist"):format(a),
		("expected %s to not exist"):format(a)
	)
end

function thirst.equals(a, b)
	return thirst._new_assertion(
		(a == b),
		("expected %s and %s to be equal"):format(a, b),
		("expected %s and %s to be different"):format(a, b)
	)
end

function thirst.function_works(fn, ...)
	local success, err = pcall(fn, ...)

	return thirst._new_assertion(
		success,
		("function failed (%s)"):format(err),
		("expected function to fail")
	)
end

return thirst
