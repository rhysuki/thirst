---Extracts Markdown-formatted text out of docstrings and function names in Lua files.
---Requires LÖVE.
local contents = love.filesystem.read("thirst/doc_test.lua")

for match in contents:gmatch("\r\n\r\n(.-function .-%(.-%))") do
	if not match:match("---") then goto continue end

	local docs = match:match("(.-)function .-%(.-%)")

	-- Strip "local" at the start of funcs
	if docs:match("\nlocal") then
		docs = docs:match("(.*)\nlocal")
	end

	-- Strip whitespace around docs
	docs = docs:match("^%s?(.-)%s?$")
	local docs2 = ""
	local special = {}

	for line in docs:gmatch("[^\r\n]+") do
		local text = line:match("%-%-%-(.*)")

		if text:match("^@") then
			if text:match("^@param") then
				local name, type, description = text:match("^@param (.+) (.+) ?(.*)")
				table.insert(special, {type = "param", name = name, type_name = type, description = description})
			end

			if text:match("^@return") then
				local type, description = text:match("^@return ([%S]+) ?(.*)")
				table.insert(special, {type = "return", type_name = type, description = description})
			end
			goto continue_line
		end

		if text == "" then
			text = "\n"
		else
			text = text .. " "
		end

		docs2 = docs2 .. text

		::continue_line::
	end

	local name = match:match("function (.-)%(.-%)")
	local final = name .. "("

	for _, s in ipairs(special) do
		if s.type == "param" then
			if final:match(":") then
				final = final .. ", "
			end

			final = final .. ("%s: %s"):format(s.name, s.type_name)
		else
			final = final .. ("): %s"):format(s.type_name)
		end
	end

	if not final:match("%)") then
		final = final .. ")"
	end

	print()
	print("`" .. final .. "`\n" .. docs2)
	print()
	print("********************************************")

	::continue::
end
