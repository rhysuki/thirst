---<3 batteries
---https://github.com/1bardesign/batteries/blob/master/tablex.lua
---Slightly edited for more error messages
--[[
Copyright 2021 Max Cahill

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
]]
---@class Thirst_BatteriesTableX
local tablex = {}

local str = tostring

--check if two tables have equal contents at the first level
--slow, as it needs two loops
--if they're not equal, also return the reason why
---@param a table
---@param b table
---@return boolean, string
function tablex.shallow_equal(a, b)
	if a == b then return true, "" end
	for k, v in pairs(a) do
		if b[k] ~= v then
			return false, ("Tables had mismatched values on key [%s]: '%s' vs '%s'"):format(str(k), str(v), str(b[k]))
		end
	end
	-- second loop to ensure a isn't missing any keys from b.
	-- we don't compare the values - if any are missing we're not equal
	for k, v in pairs(b) do
		if a[k] == nil then
			return false, ("2nd table had an extra value: [%s] = %s"):format(str(k), str(v))
		end
	end
	return true, ""
end

--check if two tables have equal contents all the way down
--slow, as it needs two potentially recursive loops
--if they're not equal, also return the reason why
---@param a table
---@param b table
---@param level integer?
---@return boolean, string
function tablex.deep_equal(a, b, level)
	if not level then
		level = 1
	end

	if a == b then return true, "" end

	for k, v in pairs(a) do
		local v2 = b[k]
		if type(v) ~= type(v2) then
			return false, ("Tables had mismatched types on level %d, key [%s]: '%s' vs '%s'"):format(
				level,
				str(k),
				str(v),
				str(v2)
			)
		end

		if type(v) == "table" then
			local success, err = tablex.deep_equal(v, v2, level + 1)

			if not success then
				return false, err
			end
		else
			if v ~= v2 then
				return false, ("Tables had mismatched values on level %s, key [%s]: '%s' vs '%s'"):format(
					level,
					str(k),
					str(v),
					str(v2)
				)
			end
		end
	end

	-- loop to ensure a isn't missing any keys from b
	-- we don't compare the values - if any are missing we're not equal
	for k, v in pairs(b) do
		if a[k] == nil then
			return false, ("Table had an extra value: [%s] = '%s'"):format(str(k), str(v))
		end
	end

	return true, ""
end

return tablex
