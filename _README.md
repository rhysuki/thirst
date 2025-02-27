# Thirst
Thirst is a modernized version of [lust](https://github.com/bjornbytes/lust/) that seeks to remove as much of the slog of writing unit tests as possible.

The more frictionless it is to write tests, the more you'll want to do it, and the better off your codebase will be in the long run. This is especially important for weakly-typed, dynamic languages like Lua.

To whet your appetite, a comparison:

**Lust**:

```lua
describe("module1", function()
	it("feature1", function()
		expect(1).to.be.a("number")
		expect("astring").to.equal("astring")
	end)

	it("feature2", function()
			expect(nil).to.exist()
		end)
	end)
end)
```

**Thirst**:

```lua
describe("module1")

it("feature1", {
	is_a(1, "number"),
	equals("astring", "astring")
})

it("feature2", {
	exists(nil)
})
```

# Usage
Download the `thirst` folder into your project, then `require` it.

`thirst.describe()` starts a new block of tests. `thirst.it()` defines a test inside the current block. Use Thirst's functions to create assertions.

```lua
local thirst = require("thirst")
local equals, not_equals, function_works = thirst.equals, thirst.not_equals, thirst.function_works

-- New block named "thirst"
thirst.describe("thirst")

-- New test with a table of assertions inside
thirst.it("is as convenient as possible to write", {
	-- New assertion
	equals(1, 1),
	is_not_a(true, "number"),
	function_works(function() math.floor(2) end),
})

thirst.it("error examples", {
	equals(1, 2),
	is_not_a(true, "boolean"),
	function_works(function() math.floor({}) end)
})

-- Once you're done, call finish() to get a rundown of the results
thirst.finish()

```

Output:

```
thirst
	[PASS] is as convenient as possible to write
	[FAIL] gives useful error messages
		dev/thirst_test.lua:19: expected 1 and 2 to be equal
		dev/thirst_test.lua:20: expected boolean to not be a boolean
		dev/thirst_test.lua:21: function failed (dev/thirst_test.lua:21: bad argument #1 to 'floor' (number expected, got table))
============================
PASSES: 1
FAILS: 1
Coverage: 50.0%
============================
```
# API
## Program State
### `thirst.set_color(has_color: bool)`
Changes whether to print out results with or without color codes, in case the current console doesn't support them.
### `thirst.push(name: string)`
### `thirst.describe(name: string)`
Ends the current `describe` block, if any, and starts a new one. This is equivalent to manually calling `push` before and `pop` after a group of `it` blocks.
### `thirst.it(name: string, assertions: table)`
Processes the current `it` block and ends it, if any, then starts a new one.
### `thirst.finish()`
Finishes processing tests and prints all results.

## Assertions
### `thirst.pass()`
Always succeeds. Useful when you don't have anything meaningful to test yet.
### `thirst.fail()`
Always fails. Useful when you don't have anything meaningful to test yet.
### `thirst.exists(value: any)`
Succeeds if `value ~= nil`.
### `thirst.does_not_exist(value: any)`
Succeeds if `value == nil`.
### `thirst.equals(a: any, b: any)`
Succeeds if `a == b`.
### `thirst.not_equals(a: any, b: any): table`
Succeeds if `a ~= b`.
### `thirst.function_works(fn: function, ...: any[])`
Succeeds if `fn` finishes running without errors. Extra args are passed to `fn`.
### `thirst.function_fails(fn: function, ...): table`
Succeeds if `fn` errors during execution. Extra args are passed to `fn`.
### `thirst.contains(t: table, v: any)`
Succeeds if `t` has an entry with value `v`.
### `thirst.does_not_contain(t: table, v:any): table`
Succeeds if `t` doesn't have any entries with value `v`.
### `thirst.is_empty(t: table)`
Succeeds if `t` is empty (that is, it has no entries that aren't `nil`).
### `thirst.is_not_empty(t: table): table`
Succeeds if `t` isn't empty (that is, it has any entries with a non-`nil` value).
### `thirst.greater_than(i: number, j: number)`
Succeeds if `i > j`.
### `thirst.greater_than_or_equal_to(i: number, j: number)`
Succeeds if `i >= j`.
### `thirst.lesser_than(i: number, j: number)`
Succeeds if `i < j`.
### `thirst.lesser_than_or_equal_to(i: number, j: number)`
Succeeds if `i <= j`.
### `thirst.is_between(n: number, low: number, high: number)`
Succeeds if `n` is between `low` and `high`, inclusive. This is equivalent to `(n >= low) and (n <= high)`.
### `thirst.is_not_between(n: number, low: number, high: number)`
Succeeds if `n` is not between `low` and `high`, inclusive. This is equivalent to `(n < low) or (n > high)`.
## Custom Assertions
To make your own assertions, use `thirst.create_assertion()`. It takes 2 arguments:

* The check, which should evaluate to `true` on success and `false` on failure;
* The error message if the check fails.

And returns a thirst-compatible assertion table.

For example, `thirst.equals()` is implemented like this:

```lua
local function equals(a, b)
	return thirst.create_assertion(
		a == b,
		"expected " .. a .. " and " .. b .. " to be equal."
	)
end
```

You can then use it inside an `it` call.

```lua
thirst.it("can make custom assertions", {
	equals(10, 10)
})
```
# Contributing
This library's still in its early stages. Issues and pull requests regarding missing features, lacking features and improvements are always welcome. 💚

# License
MIT, see [LICENSE](LICENSE) for details.

# Not Yet Implemented
### `thirst.push(name: string)`
Inserts a new block of tests into the stack.
### `thirst.pop()`
Removes the current block of tests from the stack, processing it and printing out the results.
### `thirst.before(fn: function, ...)`
Sets `fn` to run before every test in the current `describe` block.
### `thirst.after(fn: function, ...)`
Sets `fn` to run after every test in the current `describe` block.