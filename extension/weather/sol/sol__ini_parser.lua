function lines_from(file)

	if not file_exists(file) then return {} end

	lines = {}
	for line in io.lines(file) do 
		
		lines[#lines + 1] = line
	end
	return lines
end

function parse_line(line)

	local params = { "", "", {} }
	local pos = 2
	local n = 0
	local buffer = ""
	local reading = false

	for i=1, #line do

		local c = string.sub(line,i,i)

		if c == ';' then
		-- break with comment
			break

		elseif c == ' ' then
		--do nothing if space character

		elseif c == '[' and reading == false then 
		--start of key
			pos = 1

		elseif c == ']' and pos==1 then
		--end of key
			params[1] = ""..buffer..""
			buffer = ""
			pos = 2

		elseif c == '=' and pos == 2 then
		--end of parameter
			pos = 3

			params[2] = ""..buffer..""
			buffer = ""
		elseif c == ',' and pos == 3 then

			n = n + 1
			params[3][n] = buffer

			buffer = ""
		else

			buffer = buffer..c
		end 
	end

	if pos == 3 and #buffer > 0 then
	
		n = n + 1
		params[3][n] = buffer
	end

	return params
end

function parse_PPFilter(lines)

	local t = {}
	local tmp
	local current_key = ""

	for i=1, #lines do 
		
		tmp = parse_line(lines[i])
		if tmp ~= nil and tmp[1] ~= "" then
		--reading key
			current_key = tmp[1]
			t[current_key] = {}
		
		elseif current_key ~= "" and tmp[1] == "" and tmp[2] ~= "" and tmp[3] ~= nil then
		--inside a key, reading parameter and value
			t[current_key][tmp[2]] = tmp[3]
		end
	end

	return t
end

function parse_INI(file, type)

	local f=io.open(file,"r")
   	if f==nil or type == nil or type == "" then return nil end

   	local lines = lines_from(file)
   	if lines == nil then return nil end

   	local t = nil

   	if type == "PP" then
   		t = parse_PPFilter(lines)
	end

   	io.close(f)

   	return t
end

function get_parsed_value(t, key, parameter)

	if t ~= nil and key ~= nil and t[key] ~= nil then

		if parameter ~= nil and t[key][parameter] ~= nil and #t[key][parameter] > 0 then

			local tmp = ""

			for i=1, #t[key][parameter] do
              tmp = tmp..t[key][parameter][i]
            end

			if tonumber(tmp) == nil then

                return tmp
			else
				return tonumber(tmp)
			end
		end
	end

	return nil
end
