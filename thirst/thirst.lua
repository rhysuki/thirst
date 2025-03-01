---@class (exact) Thirst_Assertion
---@field success boolean `true` if this Assertion ran with no errors.
---@field error_message string The error message that'll be displayed if this Assertion fails.
---@field source_line string The filename and line number this Assertion was created in.
---@field it_name string The name of the `it()` block this Assertion belongs to. Gets set in `it()` calls.

local path = (...):gsub("thirst$", "")
---@type Thirst_Common
local common = require(path .. "common")
---@type Thirst_Expect
local expect = require(path .. "expect")
local thirst = {
	_VERSION = "v0.2.0",
	_DESCRIPTION = "Smooth unit testing for Lua",
	_URL = "https://github.com/rhysuki/thirst",
	_LICENSE = [[
		MIT License

		Copyright (c) 2025 rhysuki

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]],

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
	is_print_errors_on_finish_enabled = false,
	level = 0,
	passes = 0,
	errors = 0,
	before_functions = {},
	after_functions = {},
	errorring_assertions = {},
	expect = expect,
	---`true` if the last used section was an automatic section; If `true`, we should
	---automatically clean up the last pushed section when starting a new one.
	is_inside_auto_section = false,
	create_assertion = common.create_assertion,
}
local red = string.char(27) .. "[31m"
local green = string.char(27) .. "[32m"
local white = string.char(27) .. "[0m"

--#region LOCAL FUNCTIONS

---Get `amount` amount of tab strings in a row, or `thirst.level` tabs by default.
---@param amount integer?
---@return string
local function get_indent(amount)
	return string.rep("\t", amount or thirst.level)
end

---If `is_color_enabled`, return a color-coded version of `text`, in the given color,
---with ANSI color codes.
---If it's disabled, return the text in the default color.
---@param color string
---@param text string
---@return string
local function get_colored_text(color, text)
	if not thirst.is_color_enabled then
		return text
	end

	return color .. text .. white
end

---If we're inside an auto section, call pertinent functions to finish it, like
---popping it out of the stack. Otherwise, nothing happens.
local function clean_up_auto_section()
	if thirst.is_inside_auto_section then
		thirst.pop_section()
	end
end

---If any of the Assertions inside `assertions` failed, return `false` and a table
---containing only the errorring Assertions. Otherwise, return `true` and an empty table.
---@param assertions table
---@return boolean, table
local function check_assertions(assertions)
	local erroring_assertions = {}

	for _, assertion in ipairs(assertions) do
		if not assertion.success then table.insert(erroring_assertions, assertion) end
	end

	return #erroring_assertions == 0, erroring_assertions
end

---Recursively execute every Lua file inside `folder` and all nested folders, except
---if they match the `exclude` pattern.
---@param folder string
---@param exclude? string
local function run_folder(folder, exclude)
	for _, name in ipairs(love.filesystem.getDirectoryItems(folder)) do
		local path = folder .. "/" .. name
		local file_type = love.filesystem.getInfo(path).type

		if (not exclude) or (not path:match(exclude)) then
			if file_type == "file" and name:match(".lua$") then
				assert(love.filesystem.load(path))()
			else
				thirst.run_folder(path)
			end
		end
	end
end

--#endregion

--#region API

---Run a new test (inside the current section, if any) and prints out results if
---`is_printing_enabled` is `true`. Calls before-functions before and after-functions
---after it runs.
---@param name string
---@param assertions table
function thirst.it(name, assertions)
	for level = 1, thirst.level do
		if thirst.before_functions[level] then
			for i = 1, #thirst.before_functions[level] do
				thirst.before_functions[level][i](name)
			end
		end
	end

	local success, erroring_assertions = check_assertions(assertions)

	if success then
		thirst.passes = thirst.passes + 1
	else
		thirst.errors = thirst.errors + 1
	end

	if thirst.is_printing_enabled then
		local color = success and green or red
		local label = success and "[PASS]" or "[FAIL]"

		print(get_indent() .. get_colored_text(color, label) .. " " .. name)

		for _, assertion in ipairs(erroring_assertions) do
			print(get_indent(thirst.level + 1) .. assertion.source_line .. " " .. assertion.error_message)
		end
	end

	for _, assertion in ipairs(erroring_assertions) do
		assertion.it_name = name
		table.insert(thirst.errorring_assertions, assertion)
	end

	for level = 1, thirst.level do
		if thirst.after_functions[level] then
			for i = 1, #thirst.after_functions[level] do
				thirst.after_functions[level][i](name)
			end
		end
	end
end

---Add `fn` to be called before every `it` call in the current section and all
---sections nested inside it.
---@param fn function
function thirst.before(fn)
	thirst.before_functions[thirst.level] = thirst.before_functions[thirst.level] or {}
	table.insert(thirst.before_functions[thirst.level], fn)
end

---Add `fn` to be called before after `it` call in the current section and all
---sections inside it.
---@param fn function
function thirst.after(fn)
	thirst.after_functions[thirst.level] = thirst.after_functions[thirst.level] or {}
	table.insert(thirst.after_functions[thirst.level], fn)
end

---Create a group of tests that's automatically ended and cleaned up when the
---next one starts, or when you manually end it with `pop_section()`.
---@param name string
function thirst.section(name)
	clean_up_auto_section()
	thirst.push_section(name)
	thirst.is_inside_auto_section = true
end

---Begin a new group of tests. `it()` calls after this function will be nested inside this
---section, with one level higher of indentation.
---You can nest sections by calling this function more than once.
function thirst.push_section(name)
	clean_up_auto_section()
	print(get_indent() .. name)
	thirst.level = thirst.level + 1
end

---End the current section, clean up before and after functions, and move back to the
---previous section.
function thirst.pop_section()
	thirst.before_functions[thirst.level] = {}
	thirst.after_functions[thirst.level] = {}
	thirst.level = math.max(thirst.level - 1, 0)
	thirst.is_inside_auto_section = false
end

---Pop all active sections, clean up internal state, and print some info about
---the entirety of the test suite so far.
---This is automatically called at the end of `run_folder()`.
function thirst.finish()
	while thirst.level > 0 do
		thirst.pop_section()
	end

	local size = 30

	print(string.rep("=", size))

	local coverage = thirst.passes / (thirst.passes + thirst.errors)

	if thirst.passes + thirst.errors == 0 then
		coverage = 0
	end

	print(("PASSES: %i\nFAILS: %i"):format(
		thirst.passes,
		thirst.errors
	))

	if thirst.is_print_errors_on_finish_enabled then
		print()

		for _, assertion in ipairs(thirst.errorring_assertions) do
			print(get_colored_text(red, ("On '%s': %s %s"):format(
				assertion.it_name,
				assertion.source_line,
				assertion.error_message
			)))
		end

		print()
	end

	print(("Coverage: %.1f%%"):format(coverage * 100))

	if thirst.is_coverage_bar_enabled then
		print(
			"["
			.. get_colored_text(green, string.rep("+", (size - 2) * coverage))
			.. get_colored_text(red, string.rep("-", (size - 2) * (1 - coverage)))
			.. "]"
		)
	end


	print(string.rep("=", size))
end

---Watch a function to track the number of times it was called, and the arguments
---it was called with. This returns a table containing one table for every time the
---function was called, with the arguements used inside it.
---
---I'll be honest, I don't really understand this one. Please check the Lust docs
---for further examples.
---
---https://github.com/bjornbytes/lust?tab=readme-ov-file#spies
---@return table
function thirst.spy(target, name, run)
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

---Recursively execute every Lua file inside the given folder and all nested folders,
---printing all results, then prints a rundown of the whole suite. This is the easiest
---way to run every test inside your `spec` folder, for instance.
---
---Requires LÖVE.
---@param folder string The path to the folder. This gets passed to `love.filesystem.getDirectoryItems()`.
---@param exclude string? A Lua pattern. Paths that match this pattern will be skipped.
function thirst.run_folder(folder, exclude)
	assert(_G.love, "run_folder() needs to be run within a LÖVE game to work.")
	run_folder(folder, exclude)
	thirst.finish()
end

--#endregion

return thirst
