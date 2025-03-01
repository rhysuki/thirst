---@class Thirst_Common
local common = {}

---Create a new Thirst-compatible assertion result table, to put inside tests.
---`success` should be `true` when the test passes, and `false` when it fails.
---`error_message` will be collected and displayed if it fails.
---
---This can be used to make custom tests; see expect.lua for examples.
---@param success boolean
---@param error_message string
---@return Thirst_Assertion
function common.create_assertion(success, error_message)
	return {
		success = success,
		error_message = error_message,
		source_line = debug.traceback("", 2):match("%s([^%s]+%.lua:%d+:)"),
		it_name = "",
	}
end

return common
