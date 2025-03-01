# Thirst
Thirst is a testing library for Lua, based on [Lust](https://github.com/bjornbytes/lust/), that optimizes for ease of writing.

The smoother it is to write tests, the more you'll want to do it, and the better off your codebase will be in the long run. This is especially important for weakly-typed, dynamic languages like Lua.

<div align="center">
	<a href="/LICENSE.md">
		<img alt="GitHub License" src="https://img.shields.io/github/license/rhysuki/thirst?style=for-the-badge"></a>
	<img alt="GitHub Release" src="https://img.shields.io/github/v/release/rhysuki/thirst?style=for-the-badge">
	<img alt="Passing" src="https://img.shields.io/badge/passing-100%25-mediumseagreen?style=for-the-badge">
	<br>
	<a href="https://github.com/rhysuki/love-godot-base/releases/latest">
		<img alt="What's new?" src="https://img.shields.io/badge/What's%20new%3F-red?style=for-the-badge">
	</a>
</div>

# Usage
Download the `thirst` folder and `require` it.

`thirst.section()` defines a new block of tests, and `thirst.it()` defines a test with assertions inside. Assertions can be created with the various `thirst.expect` functions. You can then run your entire test suite folder at once with `thirst.run_folder()` (if you're using LÖVE).

Complete example:

```lua
-- spec/example_test.lua
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

--main.lua
local thirst = require("lib.thirst")
thirst.run_folder("spec")
```

Output:

```
examples
        [PASS] is as convenient as possible to write
        [FAIL] error examples
                spec/example_test.lua:12: Expected 'true' and 'false' to be equal.
                spec/example_test.lua:13: Expected 'function: 0x01a304564480' to be a boolean, but it was a function.
                spec/example_test.lua:14: Tables had mismatched values on key [3]: '30' vs '999'
==============================
PASSES: 1
FAILS: 1
Coverage: 50.0%
[++++++++++++++--------------]
==============================
```

# API
## Fields
### `thirst.is_color_enabled: boolean = true`
If `true`, uses ANSI color codes for text when printing test results. If your console doesn't support color codes, switching this off will make all text print in the default color.

### `thirst.is_coverage_bar_enabled: boolean = true`
If `true`, the rundown of passes, fails and coverage printed on `finish()` will have a colored progress bar representing the coverage.

### `thirst.is_printing_enabled: boolean = true`
If `true`, the result of each test will be printed when it's executed.

### `thirst.is_print_errors_on_finish_enabled: boolean = false`
If `true`, a list of all errors that occurred while testing will be printed when calling `finish()`, at the bottom of the results section.

## Functions
### `thirst.it(name: string, assertions: table)`
Run a new test (inside the current section, if any) and prints out results if `is_printing_enabled` is `true`. Calls before-functions before and after-functions after it runs.

### `thirst.before(fn: function)`
Add `fn` to be called before every `it` call in the current section and all sections nested inside it.

### `thirst.after(fn: function)`
Add `fn` to be called before after `it` call in the current section and all sections inside it.

### `thirst.section(name: string)`
Create a group of tests that's automatically ended and cleaned up when the next one starts, or when you manually end it with `pop_section()`.

### `thirst.push_section(name: string)`
Begin a new group of tests. `it()` calls after this function will be nested inside this section, with one level higher of indentation.
You can nest sections by calling this function more than once.

### `thirst.pop_section()`
End the current section, clean up before and after functions, and move back to the previous section.

### `thirst.finish()`
Pop all active sections, clean up internal state, and print some info about the entirety of the test suite so far.
This is automatically called at the end of `run_folder()`.

### `thirst.spy(target, name, run): table`
Watch a function to track the number of times it was called, and the arguments it was called with. This returns a table containing one table for every time the function was called, with the arguements used inside it.

I'll be honest, I don't really understand this one. [Please check the Lust docs for more info.](https://github.com/bjornbytes/lust?tab=readme-ov-file#spies)

### `thirst.run_folder(path: string, exclude: string?)`
* `path` - The path to the folder. This gets passed to `love.filesystem.getDirectoryItems()`.
* `exclude` - Optional. A Lua pattern. Filepaths that match this pattern will be skipped.

Recursively execute every Lua file inside the given folder and all nested folders, printing all results, then prints a rundown of the whole suite. This is the easiest way to run every test inside your `spec` folder, for instance.

Requires LÖVE.

### `thirst.create_assertion(success: boolean, error_message: string): table`
Create a new Thirst-compatible assertion result table, to put inside tests. `success` should be `true` when the test passes, and `false` when it fails. `error_message` will be collected and displayed if it fails.

This can be used to make custom assertions; see [expect.lua](/thirst/expect.lua) for examples.
## Assertions
These are all part of the `expect` table, included in `thirst.expect`, and all return Assertions (return values omitted in these docs for brevity). You can also make custom assertions with `thirst.create_assertion()`.

### `expect.pass()`
Always succeeds. Useful when you don't have anything meaningful to test yet.

### `expect.fail()`
Always fails. Useful when you don't have anything meaningful to test yet.

### `expect.exists(value: any)`
Succeeds if `value ~= nil`.

### `expect.does_not_exist(value: any)`
Succeeds if `value == nil`.

### `expect.equals(a: any, b: any)`
Succeeds if `a == b`.

### `expect.not_equal(a: any, b: any)`
Succeeds if `a ~= b`.

### `expect.is_a(value: any, type_name: string)`
Succeeds if `type(value) == type_name`.

### `expect.is_not_a(value: any, type_name: string)`
Succeeds if `type(value) ~= type_name`.

### `expect.function_works(func: function, ...: any)`
Succeeds if `func` executes successfully without errors. Extra args are passed to `func`.

### `expect.function_fails(func: function, ...: any)`
Succeeds if `func` errors during execution. Extra args are passed to `func`.

### `expect.contains(tab: table, value: any)`
Succeeds if `tab` has an entry with value `value`.

### `expect.does_not_contain(tab: table, value: any)`
Succeeds if `tab` doesn't have any entries with value `value`.

### `expect.is_empty(tab: table)`
Succeeds if `tab` is completely empty.

### `expect.is_not_empty(tab: table)`
Succeeds if `tab` has any non-nil entries.

### `expect.shallow_equals(t1: table, t2: table)`
Succeeds if `t1` and `t2` have the same exact elements, but doesn't check inside any nested tables. (Note: values are compared by equality, so `{} == {}` is `false`).

### `expect.deep_equals(t1: table, t2: table)`
Succeeds if `t1` and `t2` have the same exact elements, including nested tables.

### `expect.greater_than(i: number, j: number)`
Succeeds if `i > j`.

### `expect.greater_than_or_equal_to(i: number, j: number)`
Succeeds if `i >= j`.

### `expect.lesser_than(i: number, j: number)`
Succeeds if `i < j`.

### `expect.lesser_than_or_equal_to(i: number, j: number)`
Succeeds if `i <= j`.

### `expect.in_between(n: number, low: number, high: number)`
Succeeds if `n` is between `low` and `high`, inclusive. This is equivalent to `(n >= low) and (n <= high)`.

### `expect.not_in_between(n: number, low: number, high: number)`
Succeeds if `n` exists outside the range of `low` to `high`, inclusive. This is equivalent to (n < low) or (n > high).
# Contributing
This library's still in its infancy; issues regarding missing/lacking features, suggestions and improvements are always welcome.

Additionally, it'd benefit from more thorough stress-testing, so if your project is open source, easy to run, and has a decent test suite, I'd love to try forking it and converting it to Thrist. You can poke me in the [LÖVE Discord server](https://discord.gg/rhUets9).
# Lincense
MIT. See [LICENSE](/LICENSE) for details.