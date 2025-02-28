---@class Thirst_Common
local common = {}

---Create a new Thirst-compatible test result table. `success` should be `true` when
---when the test passes, and `false` when it fails. `error_message` will be collected
---and displayed if it fails.
---
---This can be used to make custom tests; see expect.lua for examples.
---@param success boolean
---@param error_message string
---@return Thirst_Test
function common.create_test(success, error_message)
	return {
		success = success,
		error_message = error_message,
		source_line = debug.traceback("", 2):match("%s([^%s]+%.lua:%d+:)"),
		it_name = "",
	}
end

return common
