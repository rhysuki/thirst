# Thirst
Thirst is a testing library for Lua, based on [Lust](https://github.com/bjornbytes/lust/), that seeks to remove as much of the boilerplate of writing tests as possible.

The smoother it is to write tests, the more you'll want to do it, and the better off your codebase in the long run. This is especially important for weakly-typed, dynamic languages like Lua.

<table>
<tr>
<td> Lust </td> <td> Thirst </td>
</tr>
<tr>
<td>

```lua
describe("module", function()
	it("feature", function()
		expect(1).to.be.a("number")
		expect("a string").to.equal("a string")
	end)

	it("other feature", function()
			expect(unitialized_var).to_not.exist()
		end)
	end)
end)
```

</td>
<td>

```lua
section("module")
it("feature", {
	expect.is_a(1, "number"),
	expect.equals("a string", "a string")
})

it("other feature", {
	expect.does_not_exist(unitialized_var)
})
```

</td>
</tr>
</table>

# Usage
Download the `/thirst` folder and `require` it.

`thirst.section()` defines a new block of tests, and `thirst.it()` defines a test. Tests can be created with the various `thirst.expect` functions. You can then run your entire test suite folder at once with `thirst.run_folder()` (provided you're using LÖVE).

Here's a complete example:

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
	expect.is_a(function() end, "boolean")
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
                spec/example_test.lua:13: Expected 'function: 00B0D908' to be a boolean, but it was a function.
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
### `thirst.it(name: string, tests: table)`
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

I'll be honest, I don't really understand this one. [Please check the lust docs for further examples.](https://github.com/bjornbytes/lust?tab=readme-ov-file#spies)

### `thirst.run_folder(path: string, exclude: string?)`
* `path` - The path to the folder. This gets passed to `love.filesystem.getDirectoryItems()`.
* `exclude` - Optional. A Lua pattern. Filepaths that match this pattern will be skipped.

Recursively execute every Lua file inside the given folder and all nested folders, printing all results, then prints a rundown of the whole suite. This is the easiest way to run every test inside your `spec` folder, for instance.

Requires LÖVE.
## Assertions
Check [expect.lua](/thirst/expect.lua) for a comprehensive list of assertion funcs and docs on how they work. These are all included inside `lust.expect`.
# Contributing
This library's still in its infancy; issues regarding missing/lacking features, suggestions and improvements are always welcome.

Additionally, it'd benefit from more thorough stress-testing, so if your project is open source, easy to run, and has a decent test suite, I'd love to try forking it and converting it to Thrist. You can poke me in the [LÖVE Discord server](https://discord.gg/rhUets9).
# Lincense
MIT. See [LICENSE](/LICENSE) for details.