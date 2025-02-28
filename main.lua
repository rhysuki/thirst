-- Run specs
if _G.love then
	_G.THIRST = require("thirst")
	THIRST.run_folder("spec")
else
	_G.THIRST = require("thirst.thirst")
	require("spec.expect")
	THIRST.finish()
end
