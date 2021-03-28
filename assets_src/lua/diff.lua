--[[
    Diff delta format info:
    https://github.com/benjamine/jsondiffpatch/blob/master/docs/deltas.md

    Refactored from the code of Martin Felis <martin@fysx.org> to use a different delta format
    Original code: https://github.com/martinfelis/luatablediff/blob/master/ltdiff.lua
]]

local function is_array(obj)
  if type(obj) ~= 'table' then return false end
  local i = 1
  for _ in pairs(obj) do
    if obj[i] ~= nil then i = i + 1 else return false end
  end
  if i == 1 then return false else return true end
end

local function table_diff (A, B)
	local diff = {}

    if (#A == 0 and #B > 0) or (#A > 0 and #B == 0) then
        return {A, B}
    end

	for k,a in pairs(A) do
        local b = B[k]

		if type(a) == "function" or type(a) == "userdata" then
			--error ("table_diff only supports diffs of tables!")
		elseif b ~= nil and type(a) == "table" and type(b) == "table" then
			diff[k] = table_diff(a, b)
		elseif b == nil then
            diff[k] = {a, 0, 0}
		elseif b ~= a then
            diff[k] = {a, b}
		end
	end

	for k,b in pairs(B) do
        local a = A[k]
		if type(b) == "function" or type(b) == "userdata" then
			--error ("table_diff only supports diffs of tables!")
		elseif diff[k] ~= nil then
			-- skip	
		elseif a ~= nil and type(a) == "table" and type(b) == "table" then
			diff[k] = table_diff(b, a)
		elseif b ~= a then
			diff[k] = {b}
		end
	end

	if next(diff) == nil then
		diff = nil
    else
        if(is_array(diff)) then
            diff._t = 'a'
        end
	end

	return diff
end

local function table_patch (A, diff)
    for k,v in pairs(diff) do
        if v['_t'] == 'a' then
            A[k] = table_patch(A[k], v)
        else
            local v0, v1, v2 = v[0], v[1], v[2]

            if v2 ~= nil and v2 == 0 then
                A[k] = nil
            elseif v1 == nil then
                A[k] = v0
            else
                A[k] = v1
            end
        end
	end

	return A
end

return table_diff