﻿return function(obj)
	local isKeyValuePair
	local function lua_iter(cs_iter, k)
		if cs_iter:MoveNext() then
			local current = cs_iter.Current
			if isKeyValuePair == nil then
				if type(current) == 'userdata' then
					local t = current:GetType()
					isKeyValuePair = t.Name == 'KeyValuePair`2' and t.Namespace == 'System.Collections.Generic'
				 else
					isKeyValuePair = false
				 end
				 --print(current, isKeyValuePair)
			end
			if isKeyValuePair then
				return current.Key, current.Value
			else
				return k + 1, current
			end
		end
	end
	return lua_iter, obj:GetEnumerator(), -1
end