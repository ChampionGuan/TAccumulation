---
---Created by xujie
---Date: 2020/9/3
---Time: 11:55
---

function table.dump(t, name, indent)
    local cart     -- a container
    local autoref  -- for self references

    -- (RiciLake) returns true if the table is empty
    local function isemptytable(t)
        return next(t) == nil
    end

    local function basicSerialize (o)
        local so = tostring(o)
        if type(o) == "function" then
            local info = debug.getinfo(o, "S")
            -- info.name is nil because o is not a calling level
            if info.what == "C" then
                return string.format("%q", so .. ", C function")
            else
                -- the information is defined through lines
                return string.format("%q", so .. ", defined in (" ..
                        info.linedefined .. "-" .. info.lastlinedefined ..
                        ")" .. info.source)
            end
        elseif type(o) == "number" or type(o) == "boolean" then
            return so
        else
            return string.format("%q", so)
        end
    end

    local function addtocart (value, name, indent, saved, field)
        indent = indent or ""
        saved = saved or {}
        field = field or name

        cart = cart .. indent .. field

        if type(value) ~= "table" then
            cart = cart .. " = " .. basicSerialize(value) .. ",\n"
        else
            if saved[value] then
                cart = cart .. " = {}, -- " .. saved[value]
                        .. " (self reference)\n"
                autoref = autoref .. name .. " = " .. saved[value] .. ",\n"
            else
                saved[value] = name
                --if tablecount(value) == 0 then
                if isemptytable(value) then
                    cart = cart .. " = {},\n"
                else
                    cart = cart .. " = {\n"
                    for k, v in pairs(value) do
                        k = basicSerialize(k)
                        local fname = string.format("%s[%s]", name, k)
                        field = string.format("[%s]", k)
                        -- three spaces between levels
                        addtocart(v, fname, indent .. "   ", saved, field)
                    end

                    ---如果是最后一个括号，即没有缩进
                    if indent == "" then
                        cart = cart .. indent .. "}\n"
                    else
                        cart = cart .. indent .. "},\n"
                    end
                end
            end
        end
    end

    name = name or "__unnamed__"
    if type(t) ~= "table" then
        return name .. " = " .. basicSerialize(t)
    end
    cart, autoref = "", ""
    addtocart(t, name, indent)
    return cart .. autoref
end

function table.save(tbl, tblName, filePath)
    local file, err = io.open(filePath, "wb")
    if err then
        return err
    end

    tblName = tblName or "t"
    local content = "local " .. table.dump(tbl, tblName) .. "\nreturn " .. tblName
    file:write(content)
    file:close()
end

function table.toArrayString(arr)
    local str = ""
    for i, element in ipairs(arr) do
        str = str .. string.format("%s,", tostring(element))
    end

    return str
end

local Util = {}

function Util.ArrayRemove(arr, value)
    local index = nil
    for i, v in ipairs(arr) do
        if v == value then
            index = i
            break
        end
    end

    if not index then
        return false
    end

    table.remove(arr, index)
    return true
end

function Util.ArrayIndex(arr, value)
    local index = nil
    for i, v in ipairs(arr) do
        if v == value then
            index = i
            break
        end
    end

    return index
end

function Util.Split(str, reps)
    local tab = {}
    string.gsub(str, '[^' .. reps .. ']+', function(w)
        table.insert(tab, w)
    end)
    return tab
end

---@param str string
---@return boolean
function Util.StringIsNullOrEmpty(str)
    if not str or "" == str then
        return true
    else
        return false
    end
end

return Util