﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/10/30 16:36
---
local unpack = table.unpack
local orderTable = require("Runtime.Common.Base.OrderTable")

---返回table的克隆
---@param object table
---@param no_set_metatable boolean 是否需要metatable 默认true
---@param fun_meta_filter fun(type:table):boolean 检测meta是否有效，用于过滤meta
---@return table
function table.clone(object, no_set_metatable, fun_meta_filter)
    local lookup_table = {}
    local function _copy(object)
        if object == nil then
            return object
        end
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        if no_set_metatable then
            return new_table
        end
        local meta = getmetatable(object)
        if not meta then
            return new_table
        end
        if fun_meta_filter then
            if fun_meta_filter(meta) then
                return new_table
            end
        end

        return setmetatable(new_table, meta)
    end
    return _copy(object)
end

---把表格转成lua语法格式的字符串
---注意：性能非常差，性能非常差，性能非常差！字符拼接太严重
---只能数据用于小的表格
---@param t table
---@param name string
---@param indent string
---@return string
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

-----------------------------------------serialize file begin
---http://lua-users.org/wiki/TablePersistence
-- write indent
local writeIndent = function(file, level)
    for i = 1, level do
        file:write("\t")
    end
end

local writers
local write = function(file, item, level, objRefNames)
    writers[type(item)](file, item, level, objRefNames)
end

-- Format items for the purpose of restoring
writers = {
    ["nil"] = function(file, item)
        file:write("nil")
    end,
    ["number"] = function(file, item)
        file:write(tostring(item))
    end,
    ["string"] = function(file, item)
        file:write(string.format("%q", item))
    end,
    ["boolean"] = function(file, item)
        if item then
            file:write("true")
        else
            file:write("false")
        end
    end,
    ["table"] = function(file, item, level)
        -- Single use table
        file:write("{\n")
        for k, v in pairs(item) do
            writeIndent(file, level + 1)
            file:write("[")
            write(file, k, level + 1)
            file:write("] = ")
            write(file, v, level + 1)
            file:write(",\n")
        end
        writeIndent(file, level)
        file:write("}")
    end,
    ["userdata"] = function(file, item)
        local strValue = nil
        strValue = tostring(item)
        file:write(string.format("%q", strValue))
    end
}

-- write thing (dispatcher)


---@param path string
---@param value table
table.saveFile = function(path, value)
    local file, e = io.open(path, "w")
    if not file then
        return error(e)
    end

    file:write("local " .. "obj = ")
    write(file, value, 0)
    file:write("\n")

    file:write("return obj")
    file:close()
end

table.saveStrToBinaryFile = function(path, string)
    local file, e = io.open(path, "wb")
    if not file then
        return error(e)
    end
    file:write(string)
    file:close()
    return nil
end

---@return table
table.loadFile = function(path)
    local f, e
    f, e = loadfile(path)
    return f()
end

table.readBinaryFile = function(path)
    local file, e = io.open(path, "rb")
    if not file then
        return error(e)
    end
    local content = file:read("*all")
    file:close()
    return content
end

-----------------------------------------serialize file end

function table.toArrayString(arr)
    local str = ""
    for i, element in ipairs(arr) do
        str = str .. string.format("%s,", tostring(element))
    end

    return str
end

--------------------------------
-- 计算表格包含的字段数量
-- @function [parent=#table] nums
-- @param table t 要检查的表格
-- @return integer#integer

--[[--

计算表格包含的字段数量

Lua table 的 "#" 操作只对依次排序的数值下标数组有效，table.nums() 则计算 table 中所有不为 nil 的值的个数。

]]

-- end --

---@param t table
---@return int
function table.nums(t)
    local count = 0
    if not t then
        return count
    end
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

-- start --

--------------------------------
-- 返回指定表格中的所有键
-- @function [parent=#table] keys
-- @param table hashtable 要检查的表格
-- @return table#table

--[[--

返回指定表格中的所有键

~~~ lua

local hashtable = {a = 1, b = 2, c = 3}
local keys = table.keys(hashtable)
-- keys = {"a", "b", "c"}

~~~

]]

-- end --
---@param hashtable table
---@return table<any>
function table.keys(hashtable)
    local keys = {}
    if not hashtable then
        return keys
    end
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

-- start --

--------------------------------
-- 返回指定表格中的所有值
-- @function [parent=#table] values
-- @param table hashtable 要检查的表格
-- @return table#table

--[[--

返回指定表格中的所有值

~~~ lua

local hashtable = {a = 1, b = 2, c = 3}
local values = table.values(hashtable)
-- values = {1, 2, 3}

~~~

]]

-- end --
---@param hashtable table
---@return table<any>
function table.values(hashtable)
    local values = {}
    if not hashtable then
        return values
    end
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

-- start --

--------------------------------
-- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
-- @function [parent=#table] merge
-- @param table dest 目标表格
-- @param table src 来源表格

--[[--

将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值

~~~ lua

local dest = {a = 1, b = 2}
local src  = {c = 3, d = 4}
table.merge(dest, src)
-- dest = {a = 1, b = 2, c = 3, d = 4}

~~~

]]

-- end --
---@param dest table
---@param src table
function table.merge(dest, src)
    if dest == nil or src == nil then
        return nil
    end
    for k, v in pairs(src) do
        dest[k] = v
    end
end

-- start --

--------------------------------
-- 在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格
-- @function [parent=#table] insertto
-- @param table dest 目标表格
-- @param table src 来源表格
-- @param integer begin 插入位置,默认最后

--[[--

在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格

~~~ lua

local dest = {1, 2, 3}
local src  = {4, 5, 6}
table.insertto(dest, src)
-- dest = {1, 2, 3, 4, 5, 6}

dest = {1, 2, 3}
table.insertto(dest, src, 5)
-- dest = {1, 2, 3, nil, 4, 5, 6}

~~~

]]

-- end --
---@param dest table
---@param src table
---@param begin int
function table.insertto(dest, src, begin)
    if dest == nil or src == nil then
        return nil
    end
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end
    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
    return dest
end

-- start --

--------------------------------
-- 从表格中查找指定值，返回其索引，如果没找到返回 false
-- @function [parent=#table] indexof
-- @param table array 表格
-- @param mixed value 要查找的值
-- @param integer begin 起始索引值
-- @return integer#integer

--[[--

从表格中查找指定值，返回其索引，如果没找到返回 false

~~~ lua

local array = {"a", "b", "c"}
print(table.indexof(array, "b")) -- 输出 2

~~~

]]

-- end --

function table.indexof(array, value, begin)
    if array and value then
        for i = begin or 1, #array do
            if array[i] == value then
                return i
            end
        end
    end
    return false
end

-- start --

--------------------------------
-- 从表格中查找指定值，返回其 key，如果没找到返回 nil
-- @function [parent=#table] keyof
-- @param table hashtable 表格
-- @param mixed value 要查找的值
-- @return string#string  该值对应的 key

--[[--

从表格中查找指定值，返回其 key，如果没找到返回 nil

~~~ lua

local hashtable = {name = "dualface", comp = "chukong"}
print(table.keyof(hashtable, "chukong")) -- 输出 comp

~~~

]]

-- end --

function table.keyof(hashtable, value)
    if not hashtable or not value then
        return nil
    end
    for k, v in pairs(hashtable) do
        if v == value then
            return k
        end
    end
    return nil
end

-- start --

--------------------------------
-- 从表格中删除指定值，返回删除的值的个数
-- @function [parent=#table] removebyvalue
-- @param table array 表格
-- @param mixed value 要删除的值
-- @param boolean removeall 是否删除所有相同的值
-- @return integer#integer

--[[--

从表格中删除指定值，返回删除的值的个数

~~~ lua

local array = {"a", "b", "c", "c"}
print(table.removebyvalue(array, "c", true)) -- 输出 2

~~~

]]

-- end --

function table.removebyvalue(array, value, removeall)
    if not array then
        return
    end
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then
                break
            end
        end
        i = i + 1
    end
    return c
end

-- start --

--------------------------------
-- 对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容
-- @function [parent=#table] map
-- @param table t 表格
-- @param function fn 函数

--[[--

对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.map(t, function(v, k)
    -- 在每一个值前后添加括号
    return "[" .. v .. "]"
end)

-- 输出修改后的表格内容
for k, v in pairs(t) do
    print(k, v)
end

-- 输出
-- name [dualface]
-- comp [chukong]

~~~

fn 参数指定的函数具有两个参数，并且返回一个值。原型如下：

~~~ lua

function map_function(value, key)
    return value
end

~~~

]]

-- end --

function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

-- start --

--------------------------------
-- 对表格中每一个值执行一次指定的函数，但不改变表格内容
-- @function [parent=#table] walk
-- @param table t 表格
-- @param function fn 函数

--[[--

对表格中每一个值执行一次指定的函数，但不改变表格内容

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.walk(t, function(v, k)
    -- 输出每一个值
    print(v)
end)

~~~

fn 参数指定的函数具有两个参数，没有返回值。原型如下：

~~~ lua

function map_function(value, key)

end

~~~

]]

-- end --

function table.walk(t, fn)
    for k, v in pairs(t) do
        fn(v, k)
    end
end

-- start --

--------------------------------
-- 对表格中每一个值执行一次指定的函数，如果该函数返回 false，则对应的值会从表格中删除
-- @function [parent=#table] filter
-- @param table t 表格
-- @param function fn 函数

--[[--

对表格中每一个值执行一次指定的函数，如果该函数返回 false，则对应的值会从表格中删除

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.filter(t, function(v, k)
    return v ~= "dualface" -- 当值等于 dualface 时过滤掉该值
end)

-- 输出修改后的表格内容
for k, v in pairs(t) do
    print(k, v)
end

-- 输出
-- comp chukong

~~~

fn 参数指定的函数具有两个参数，并且返回一个 boolean 值。原型如下：

~~~ lua

function map_function(value, key)
    return true or false
end

~~~

]]

-- end --

---过滤
---@param t table
---@param fn fun(type:any,type:any):boolean
---@return table 存放筛选的数据结果数组
function table.filter(t, fn)
    local res = {}
    for k, v in pairs(t) do
        if fn(v, k) then
            table.insert(res, v)
        end
    end
    return res
end

-- start --

--------------------------------
-- 遍历表格，确保其中的值唯一
-- @function [parent=#table] unique
-- @param table t 表格
-- @param boolean bArray t是否是数组,是数组,t中重复的项被移除后,后续的项会前移
-- @return table#table  包含所有唯一值的新表格

--[[--

遍历表格，确保其中的值唯一

~~~ lua

local t = {"a", "a", "b", "c"} -- 重复的 a 会被过滤掉
local n = table.unique(t)

for k, v in pairs(n) do
    print(v)
end

-- 输出
-- a
-- b
-- c

~~~

]]

-- end --

function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

--[[------------------------------------------------------------------------------
-** 设置table只读 出现改写会抛出lua error
-- 用法 local cfg_proxy = read_only(cfg)  retur cfg_proxy
-- 增加了防重置设置read_only的机制
-- lua5.3支持 1）table库支持调用元方法，所以table.remove table.insert 也会抛出错误，
--               2）不用定义__ipairs 5.3 ipairs迭代器支持访问元方法__index，pairs迭代器next不支持故需要元方法__pairs
-- 低版本lua此函数不能完全按照预期工作
*]]
function table.read_only(inputTable)
    local travelled_tables = {}
    local function __read_only(tbl)
        if not travelled_tables[tbl] then
            local tbl_mt = getmetatable(tbl)
            if not tbl_mt then
                tbl_mt = {}
                setmetatable(tbl, tbl_mt)
            end

            local proxy = tbl_mt.__read_only_proxy
            if not proxy then
                proxy = {}
                tbl_mt.__read_only_proxy = proxy
                local proxy_mt = {
                    __index = tbl,
                    __newindex = function(t, k, v)
                        error("error write to a read-only table with key = " .. tostring(k))
                    end,
                    __pairs = function(t)
                        return pairs(tbl)
                    end,
                    -- __ipairs = function (t) return ipairs(tbl) end,   5.3版本不需要此方法
                    __len = function(t)
                        return #tbl
                    end,
                    __read_only_proxy = proxy
                }
                setmetatable(proxy, proxy_mt)
            end
            travelled_tables[tbl] = proxy
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    tbl[k] = __read_only(v)
                end
            end
        end
        return travelled_tables[tbl]
    end
    return __read_only(inputTable)
end

---分割表
---[[
--- local a = {1,2,3,4}
---local b = table.split(a,2)
---b = {{1,2},{3,4}}
---]]
---@param src table
---@param count int
---@return table[]
function table.split(src, count)
    if not src or not count then
        return src
    end
    local res = {}
    for k, v in pairs(src) do
        local temp = res[#res]
        if not temp or #temp == count then
            temp = {}
            table.insert(res, temp)
        end
        table.insert(temp, v)
    end
    return res
end

---是否包含key
---@param t table
---@param key any
---@return boolean
function table.containskey(t, key)
    return t and key and t[key] ~= nil
end

---是否包含value
---@param t table
---@param value any
---@return boolean
function table.containsvalue(t, value)
    return t and ((table.indexof(t, value) or table.keyof(t, value)) ~= nil)
end

---清理table
---@param t table
function table.clear(t)
    if not t or  type(t)~="table" then
        return
    end
    for k, v in pairs(t) do
        t[k] = nil
    end
end

---检测table是否为空或者是nil
---@param t table
---@return boolean
function table.isnilorempty(t)
    if not t then
        return true
    end
    for k, v in pairs(t) do
        return false
    end
    return true
end

---@param t table
---@param start_index int
---@param end_index int
---@vararg any
function table.unpack(t, start_index, end_index)
    if not t then
        return
    end
    start_index = start_index or 1
    end_index = end_index or (t.n and t.n or #t)
    return unpack(t, start_index, end_index)
end


-- 迭代table，只给value不给key，并且是无序的
---@param list table
---@param iterFunc function
function table.foreach(list, iterFunc)
    if not list or not iterFunc then
        return
    end

    for _, v in pairs(list) do
        iterFunc(v)
    end
end

---字典转换成数组
---@param t table
---@param out table
---@return table
function table.dictoarray(t, out)
    out = out or {}
    if t then
        for k, v in pairs(t) do
            table.insert(out, v)
        end
    end
    return out
end
---字典转换成数组
---@param randomTab table  需要随机的table
---@param retTab table  结果table
---@param num int  随机几个
function table.random_table(randomTab, retTab, num)
    local index = 1
    num = num or #randomTab
    while #randomTab ~= 0 do
        local ran = math.random(0, #randomTab)
        if randomTab[ran] ~= nil then
            table.insert(retTab, randomTab[ran])
            table.remove(randomTab, ran)
            index = index + 1
            if index > num then
                break
            end
        end
    end
    return retTab
end

---两个数组是否相等
---@param tbA table
---@param tbB table
function table.equal(tbA, tbB)
    local type1 = type(tbA)
    local type2 = type(tbB)
    if type1 ~= type2 then
        return false
    end
    -- 默认为true
    local compareResult = true
    if type1 == "table" then
        local c1, c2 = 0, 0
        for k, v in pairs(tbA) do
            c1 = c1 + 1
            compareResult = table.equal(tbA[k], tbB[k])
            if not compareResult then
                break
            end
        end
        if compareResult then
            for k, v in pairs(tbB) do
                c2 = c2 + 1
                if c2 > c1 then
                    break
                end
            end
            compareResult = c1 == c2
        end
    else
        compareResult = tbA == tbB
    end
    return compareResult
end
---@public  定义一个函数来对数组进行倒序处理(本段代码及注释由ChatGPT自动生成)
---@param tab table
function table.reverse_table(tab)
    -- 定义两个变量i和j，分别记录表的首尾位置
    local i, j = 1, #tab
    -- 使用while循环，当i<j时，不断交换i和j位置的元素，同时i+1，j-1
    while i < j do
        tab[i], tab[j] = tab[j], tab[i]
        i = i + 1
        j = j - 1
    end
    -- 返回翻转后的表
    return tab
end
---@return OrderTable
function table.createOrderTable()
    return orderTable.new()
end

---@param t
---@return table
function table.getTopMetatable(t)
    if not t then
        return t
    end
    local last = t
    local cur = getmetatable(t)
    while cur ~= nil do
        last = cur
        cur = getmetatable(cur)
    end
    return last
end

-- 去重
---@param t table
function table.distinct(t)
    local hash = {}
    local res = {}

    for _,v in ipairs(t) do
        if not hash[v] then
            res[#res + 1] = v
            hash[v] = true
        end
    end

    return res
end
