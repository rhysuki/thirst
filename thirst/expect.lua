---@class Expect
local expect = {}

local str = tostring

---@param success boolean
---@param error_message string
---@return Test
local function create_test(success, error_message)
	return {
		success = success,
		error_message = error_message,
		source_line = debug.traceback("", 2):match("%s([^%s]+%.lua:%d+:)"),
		it_name = "",
	}
end

---Template for creating tests.
---@param test any
---@return Test
function expect._base(test)
	return create_test(
		true,
		""
	)
end

---Always succeeds. Useful when you don't have anything meaningful to test yet.
---@return Test
function expect.pass()
	return create_test(
		true,
		"uh"
	)
end

---Always fails. Useful when you don't have anything meaningful to test yet.
---@return Test
function expect.fail()
	return create_test(
		true,
		"Fail!"
	)
end

---Succeeds if `value ~= nil`.
---@param value any
---@return Test
function expect.exists(value)
	return create_test(
		value ~= nil,
		"Expected value to exist, but was nil."
	)
end

---Succeeds if `value == nil`.
---@param value any
---@return Test
function expect.does_not_exist(value)
	return create_test(
		value == nil,
		("Expected value to be nil, but was '%s'."):format(str(value))
	)
end

---Succeeds if `a == b`.
---@param a any
---@param b any
---@return Test
function expect.equals(a, b)
	return create_test(
		a == b,
		("Expected '%s' and '%s' to be equal."):format(str(a), str(b))
	)
end

---Succeeds if `a ~= b`.
---@param a any
---@param b any
---@return Test
function expect.not_equal(a, b)
	return create_test(
		a ~= b,
		("Expected '%s' and '%s' to be different."):format(str(a), str(b))
	)
end

---Succeeds if `type(a) == b`.
---@param value any
---@param type_name string
---@return Test
function expect.is_a(value, type_name)
	return create_test(
		type(value) == type_name,
		("Expected '%s' to be a %s, but it was a %s."):format(str(value), type_name, type(value))
	)
end

---Succeeds if `type(a) ~= b`.
---@param value any
---@param type_name string
---@return Test
function expect.is_not_a(value, type_name)
	return create_test(
		type(value) ~= type_name,
		("Expected '%s' to not be a %s."):format(str(value), str(type_name))
	)
end

---Succeeds if `func` executes successfully without errors. Extra args are passed
---to `func`.
---@param func function
---@param ... any
---@return Test
function expect.function_works(func, ...)
	local success, err = pcall(func, ...)

	return create_test(
		success,
		("Function failed: '%s'"):format(err or "")
	)
end

---Succeeds if `func` errors during execution. Extra args are passed to `func`.
---@param func function
---@param ... any
---@return Test
function expect.function_fails(func, ...)
	local success, err = pcall(func, ...)

	return create_test(
		not success,
		("Expected function to fail."):format(err or "")
	)
end

---Succeeds if `tab` has an entry with value `value`.
---@param tab table
---@param value any
---@return Test
function expect.contains(tab, value)
	local success = false

	for _, v in pairs(tab) do
		if v == value then
			success = true
			break
		end
	end

	return create_test(
		success,
		("Couldn't find '%s' in table."):format(value)
	)
end

---Succeeds if `tab` doesn't have any entries with value `value`.
---@param tab table
---@param value any
---@return Test
function expect.does_not_contain(tab, value)
	local success = true

	for _, v in pairs(tab) do
		if v == value then
			success = false
			break
		end
	end

	return create_test(
		success,
		("Expected table to not contain '%s'."):format(value)
	)
end

---Succeeds if `tab` is completely empty.
---@param tab table
---@return Test
function expect.is_empty(tab)
	local count = 0

	for _, _ in pairs(tab) do
		count = count + 1
	end

	local end_of_word = count == 1 and "y" or "ies"

	return create_test(
		count == 0,
		("Expected table to be empty, but it had %d entr%s."):format(count, end_of_word)
	)
end

---Succeeds if `tab` has any non-nil entries.
---@param tab table
---@return Test
function expect.is_not_empty(tab)
	return create_test(
		next(tab) ~= nil,
		"Expected table to not be empty."
	)
end

---Succeeds if `i > j`.
---@param i number
---@param j number
---@return Test
function expect.greater_than(i, j)
	return create_test(
		i > j,
		("Expected %d to be greater than %d."):format(i, j)
	)
end

---Succeeds if `i < j`.
---@param i number
---@param j number
---@return Test
function expect.lesser_than(i, j)
	return create_test(
		i < j,
		("Expected %d to be lesser than %d."):format(i, j)
	)
end

---Succeeds if `i >= j`.
---@param i number
---@param j number
---@return Test
function expect.greater_than_or_equal_to(i, j)
	return create_test(
		i >= j,
		("Expected %d to be greater than or equal to %d."):format(i, j)
	)
end

---Succeeds if `i <= j`.
---@param i number
---@param j number
---@return Test
function expect.lesser_than_or_equal_to(i, j)
	return create_test(
		i >= j,
		("Expected %d to be lesser than or equal to %d."):format(i, j)
	)
end

---Succeeds if `n` is between `low` and `high`, inclusive. This is equivalent to
---`(n >= low) and (n <= high)`.
---@param n number
---@param low number
---@param high number
---@return Test
function expect.in_between(n, low, high)
	return create_test(
		(n >= low) and (n <= high),
		("Expected %d to be between %d and %d."):format(n, low, high)
	)
end

---Succeeds if `n` exists outside the range of `low` and `high`, inclusive. This
---is equivalent to (n < low) or (n > high).
---@param n number
---@param low number
---@param high number
---@return Test
function expect.not_in_between(n, low, high)
	return create_test(
		(n < low) or (n > high),
		("Expected %d to be between %d and %d."):format(n, low, high)
	)
end

return expect
