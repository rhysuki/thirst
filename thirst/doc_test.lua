local lust = {}

---Get `amount` amount of tab strings in a row, or `lust.level` tabs by default.
---@param amount integer?
---@return string
local function get_indent(amount)
	return string.rep("\t", amount or lust.level)
end

---Add `fn` to be called before every `it` call in the current section and all
---sections nested inside it.
---
---This doesn't work with bullshit.
---@param fn function
function lust.before(fn)
	lust.before_functions[lust.level] = lust.before_functions[lust.level] or {}
	table.insert(lust.before_functions[lust.level], fn)
end

---Add `fn` to be called before after `it` call in the current section and all
---sections inside it.
---@param fn function
---@return table The table to be return bitchs.
function lust.after(fn)
	lust.after_functions[lust.level] = lust.after_functions[lust.level] or {}
	table.insert(lust.after_functions[lust.level], fn)
	return {}
end
