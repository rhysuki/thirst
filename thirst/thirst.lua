--#region INIT

---@class (exact) Test
---@field success boolean `true` if this Test ran with no errors.
---@field error_message string The error message that'll be displayed if this Test fails.
---@field source_line string The filename and line number this Test was created in.
---@field it_name string The name of the `it()` block this Test belongs to. Gets set in `it()` calls.

local lust = {
	---If `true`, uses ANSI color codes for text when printing test results.
	---If your console doesn't support color codes, switching this off will make
	---all text print in the default color.
	is_color_enabled = true,
	---If `true`, the rundown of passes, fails and coverage printed on `finish()`
	---will have a colored progress bar representing the coverage.
	is_coverage_bar_enabled = true,
	---If `true`, the result of each test will be printed when it's executed.
	is_printing_enabled = true,
	---If `true`, a list of all errors that occurred while testing will be printed
	---when calling `finish()`, at the bottom of the results section.
	is_print_errors_on_finish_enabled = true,
	level = 0,
	passes = 0,
	errors = 0,
	before_functions = {},
	after_functions = {},
	errorring_tests = {},
	expect = require("thirst.assertions"),
	---`true` if the last used section was an automatic section; If `true`, we should
	---automatically clean up the last pushed section when starting a new one.
	is_inside_auto_section = false,
}
local red = string.char(27) .. "[31m"
local green = string.char(27) .. "[32m"
local white = string.char(27) .. "[0m"
--#endregion

--#region LOCAL FUNCTIONS & ASSERTIONS

---Get `amount` amount of tab strings in a row, or `lust.level` tabs by default.
---@param amount integer?
---@return string
local function get_indent(amount)
	return string.rep("\t", amount or lust.level)
end

---If `is_color_enabled`, return a color-coded version of `text`, in the given color,
---with ANSI color codes.
---If it's disabled, return the text in the default color.
---@param color string
---@param text string
---@return string
local function get_colored_text(color, text)
	if not lust.is_color_enabled then
		color = white
	end

	return color .. text .. white
end

---If we're inside an auto section, call pertinent functions to finish it, like
---popping it out of the stack. Otherwise, nothing happens.
local function clean_up_auto_section()
	if lust.is_inside_auto_section then
		lust.pop_section()
	end
end

---If any of the tests inside `tests` failed, return `false` and a table containing
---only the errorring tests. Otherwise, return `true` and an empty table.
---@param tests table
---@return boolean, table
local function check_tests(tests)
	local erroring_tests = {}

	for _, test in ipairs(tests) do
		if not test.success then table.insert(erroring_tests, test) end
	end

	return #erroring_tests == 0, erroring_tests
end

--#endregion

--#region API

---Create a group of tests that's automatically ended and cleaned up when the
---next one starts, or when you manually end it with `pop_section()`.
---@param name string
function lust.section(name)
	clean_up_auto_section()
	lust.push_section(name)
	lust.is_inside_auto_section = true
end

---Begin a new group of tests. `it()` calls after this function will be nested inside this
---section, with one level higher of indentation.
---You can nest sections by calling this function more than once.
function lust.push_section(name)
	clean_up_auto_section()
	print(get_indent() .. name)
	lust.level = lust.level + 1
end

---End the current section, clean up before and after functions, and move back to the
---previous section.
function lust.pop_section()
	lust.before_functions[lust.level] = {}
	lust.after_functions[lust.level] = {}
	lust.level = math.max(lust.level - 1, 0)
	lust.is_inside_auto_section = false
end

---Pop all active sections, clean up internal state, and print some info about
---the entirety of the test suite so far.
function lust.finish()
	while lust.level > 0 do
		lust.pop_section()
	end

	local size = 30

	print(string.rep("=", size))

	local coverage = lust.passes / (lust.passes + lust.errors)

	print(("PASSES: %i\nFAILS: %i"):format(
		lust.passes,
		lust.errors
	))

	if lust.is_print_errors_on_finish_enabled then
		print()

		for _, test in ipairs(lust.errorring_tests) do
			print(get_colored_text(red, ("On '%s': %s %s"):format(
				test.it_name,
				test.source_line,
				test.error_message
			)))
		end

		print()
	end

	print(("Coverage: %.1f%%"):format(coverage * 100))

	if lust.is_coverage_bar_enabled then
		print(
			"["
			.. get_colored_text(green, string.rep("+", (size - 2) * coverage))
			.. get_colored_text(red, string.rep("-", (size - 2) * (1 - coverage)))
			.. "]"
		)
	end


	print(string.rep("=", size))
end

function lust.it(name, tests)
	for level = 1, lust.level do
		if lust.before_functions[level] then
			for i = 1, #lust.before_functions[level] do
				lust.before_functions[level][i](name)
			end
		end
	end

	local success, erroring_tests = check_tests(tests)

	if success then
		lust.passes = lust.passes + 1
	else
		lust.errors = lust.errors + 1
	end

	if lust.is_printing_enabled then
		local color = success and green or red
		local label = success and "[PASS]" or "[FAIL]"

		print(get_indent() .. get_colored_text(color, label) .. " " .. name)

		for _, test in ipairs(erroring_tests) do
			print(get_indent(lust.level + 1) .. test.source_line .. " " .. test.error_message)
		end
	end

	for _, test in ipairs(erroring_tests) do
		test.it_name = name
		table.insert(lust.errorring_tests, test)
	end

	for level = 1, lust.level do
		if lust.after_functions[level] then
			for i = 1, #lust.after_functions[level] do
				lust.after_functions[level][i](name)
			end
		end
	end
end

---Add `fn` to be called before every `it` call in the current section and all
---sections nested inside it.
---@param fn function
function lust.before(fn)
	lust.before_functions[lust.level] = lust.before_functions[lust.level] or {}
	table.insert(lust.before_functions[lust.level], fn)
end

---Add `fn` to be called before after `it` call in the current section and all
---sections inside it.
---@param fn function
function lust.after(fn)
	lust.after_functions[lust.level] = lust.after_functions[lust.level] or {}
	table.insert(lust.after_functions[lust.level], fn)
end

---Watch a function to track the number of times it was called, and the arguments
---it was called with. This returns a table containing one table for every time the
---function was called, with the arguements used inside it.
---
---I'll be honest, I don't really understand this one. Please check the lust docs
---for further examples.
---
---https://github.com/bjornbytes/lust?tab=readme-ov-file#spies
---@return table
function lust.spy(target, name, run)
	local spy = {}
	local subject

	local function capture(...)
		table.insert(spy, {...})
		return subject(...)
	end

	if type(target) == 'table' then
		subject = target[name]
		target[name] = capture
	else
		run = name
		subject = target or function() end
	end

	setmetatable(spy, {__call = function(_, ...) return capture(...) end})

	if run then run() end

	return spy
end

--#endregion

return lust
