# thirst
A wrapper around [bjornbyte's Lust](https://github.com/bjornbytes/lust/) that removes as much of the slog of writing tests as possible.

[From eev.ee](https://eev.ee/blog/2016/08/22/testing-for-people-who-hate-testing/):
> If you hate your test harness, you will never enjoy writing tests. It'll always be a slog, and you'll avoid it whenever you can.
# Usage
Download this repository, then move the `thirst` folder to your project. `require` it.

`thirst.describe()` defines a block of tests. `thirst.it()` defines a test with a list of assertions inside, which are created with the provided functions.

Invert an assertion with `:to_fail()`, flipping the check and error message around.
```lua
local thirst = require('thirst')
local equals, function_works = thirst.equals, thirst.function_works

-- define a block of tests
thirst.describe("thirst")

-- define a test with a list of assertions inside
thirst.it("is as convenient as possible to write", {
	-- create an assertion
	equals(1, 1),
	equals(type(true), 'boolean'),
	function_works(function() math.floor(2) end),
	-- create an inverted assertion
	-- as in, "expect equals(1, 2) *to fail*"
	equals(1, 2):to_fail()
})

thirst.it("gives useful error messages", {
	equals(1, 2),
	equals(type(true), 'string'),
	function_works(function() math.floor({}) end)
})

-- once you're done, call finish() to get a rundown of the results
thirst.finish()

```
Output:
```
thirst
	[PASS] is as convenient as possible to write
	[FAIL] gives useful error messages
		dev/thirst_test5.lua:19: expected 1 and 2 to be equal
		dev/thirst_test5.lua:20: expected boolean and string to be equal
		dev/thirst_test5.lua:21: function failed (dev/thirst_test5.lua:21: bad argument #1 to 'floor' (number expected, got table))
============================
PASSES: 1
FAILS: 1
Coverage: 50.0%
============================
```
# API
## State functions
### `thirst.nocolor()`
Disables text coloring, in case the console used doesn't support it.
### `thirst.describe(name: string)`
Ends the current `describe` block and starts a new one.
### `thirst.it(name: string, results: table)`
Processes the current `it` block, ends it, and starts a new one. `results` should be an array of results, each generated with an assertion function.
### `thirst.finish()`
Finishes processing tests and prints all results.
## Assertion functions
### `thirst.exists(value: any): table`
Succeeds if `value ~= nil`.
### `thirst.equals(a: any, b: any): table`
Succeeds if `a == b`.
### `thirst.function_works(fn: function, ...): table`
Succeeds if `fn` finishes running without errors. Extra args are passed to `fn`.
## Extending
You can make custom assertion functions with `thirst._new_assertion()`, like so (using a function like `thirst.equals()` as an example):
```lua
local function not_equals(a, b)
	return thirst._new_assertion(
		-- the check. should evaluate to "true" on success and "false" on failure
		(a ~= b),
		-- the error message if the check fails
		("expected %s and %s to be different"):format(a, b),
		-- the error message if the check was inverted, then fails
		("expected %s and %s to be equal"):format(a, b)
	)
end
```
Just call your function inside an `it` block.
```lua
thirst.it("has custom assertions", {
	not_equals(1, 0) -- pass!
})
```
# Contributing
This library's still in its early stages. Issues and pull requests regarding missing features, lacking features and improvements are always welcome. 💚
# License
MIT, see [LICENSE](LICENSE) for details.
# Not Yet Implemented
### `thirst.push(name: string)`
Inserts a new `describe` block to the stack.
### `thirst.pop()`
Removes the current `describe` block to the stack.
### `thirst.before(fn: function, ...)`
Sets `fn` to run before every test in the current `describe` block.
### `thirst.after(fn: function, ...)`
Sets `fn` to run after every test in the current `describe` block.
### `thirst.contains(t: table, value: any): table`
Succeeds if `t` has a value that equals `value`.
### `thirst.is_empty(t: table): table`
Succeeds if `t` is empty.
