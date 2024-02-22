﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/10/30 16:36

---@class luamd5
---@field tomd5 fun(str:string):string
local md5 = require("luamd5", true, true)
---字符串压缩
---@class zlib
local zlib = require("zlib", true, true)

---支持cs方式传参

---@type table[]
local str_param
---@param value string
---@return string
local function str_replace(value)
    local idx = tonumber(string.sub(value, 2, -2))
    return idx and str_param[idx + 1] or value
end
---@param format_str string
---@vararg string | number  参数列表
---@return string
function string.cs_format(format_str, ...)
    local count = select("#", ...)
    local res = format_str
    if count >= 1 then
        str_param = { ... }
        res = string.gsub(format_str, "{[^{}]+}", str_replace)
    end
    return res
end

---@type table
local split_res
---@param sp string
local function s_split(sp)
    table.insert(split_res, sp)
end

---@param res table
---@param input string
---@param delimiter string
local function split2(res, input, delimiter)
    res = res or {}
    local fpat = string.concat("(.-)", delimiter)
    local last_end = 1
    local s, e, cap = input:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(res, cap)
        end
        last_end = e + 1
        s, e, cap = input:find(fpat, last_end)
    end
    if last_end <= #input then
        cap = input:sub(last_end)
        table.insert(res, cap)
    end
    return res
end

---@param input string
---@param delimiter string 分隔符
---@param isRegex boolean
---@return string[]
function string.split(input, delimiter, isRegex)
    local res = {}
    if string.isnilorempty(input) or string.isnilorempty(delimiter) then
        return res
    end
    if not isRegex and string.len(delimiter) > 1 then
        split2(res, input, delimiter)
    else
        local reg = isRegex and delimiter or string.format("[^%s]+", delimiter)
        split_res = res
        string.gsub(input, reg, s_split)
        split_res = nil
    end
    return res
end


--------------------------------

---检测空字符串
---@param str string
---@return boolean
function string.isnilorempty(str)
    return str == nil or str == ""
end

function string.isnilorwhitespace(str)
    return string.isnilorempty(string.trim(str))
end

---检测是否某个词开始
---@param str string
---@param word string
---@return number|nil
function string.startswith(str, word)
    return utf8.findoffset(str, word, 1)
end

---检测是否某个词结束
---@param str string
---@param word string
---@return boolean
function string.endswith(str, word)
    return word == '' or string.sub(str, -string.len(word)) == word
end

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

-- start --

--------------------------------
-- 将特殊字符转为 HTML 转义符
-- @function [parent=#string] htmlspecialchars
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将特殊字符转为 HTML 转义符

~~~ lua

print(string.htmlspecialchars("<ABC>"))
-- 输出 &lt;ABC&gt;

~~~

]]

-- end --

---@param input string
---@return string
function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

-- start --

--------------------------------
-- 将 HTML 转义符还原为特殊字符，功能与 string.htmlspecialchars() 正好相反
-- @function [parent=#string] restorehtmlspecialchars
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将 HTML 转义符还原为特殊字符，功能与 string.htmlspecialchars() 正好相反

~~~ lua

print(string.restorehtmlspecialchars("&lt;ABC&gt;"))
-- 输出 <ABC>

~~~

]]

-- end --

function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

-- start --

--------------------------------
-- 将字符串中的 \n 换行符转换为 HTML 标记
-- @function [parent=#string] nl2br
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将字符串中的 \n 换行符转换为 HTML 标记

~~~ lua

print(string.nl2br("Hello\nWorld"))
-- 输出
-- Hello<br />World

~~~

]]

-- end --

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

-- start --

--------------------------------
-- 将字符串中的特殊字符和 \n 换行符转换为 HTML 转移符和标记
-- @function [parent=#string] text2html
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将字符串中的特殊字符和 \n 换行符转换为 HTML 转移符和标记

~~~ lua

print(string.text2html("<Hello>\nWorld"))
-- 输出
-- &lt;Hello&gt;<br />World

~~~

]]

-- end --

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

-- start --

--------------------------------
-- 去除输入字符串头部的空白字符，返回结果
-- @function [parent=#string] ltrim
-- @param string input 输入字符串
-- @return string#string  结果
-- @see string.rtrim, string.trim

--[[--

去除输入字符串头部的空白字符，返回结果

~~~ lua

local input = "  ABC"
print(string.ltrim(input))
-- 输出 ABC，输入字符串前面的两个空格被去掉了

~~~

空白字符包括：

-   空格
-   制表符 \t
-   换行符 \n
-   回到行首符 \r

]]

-- end --

function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

-- start --

--------------------------------
-- 去除输入字符串尾部的空白字符，返回结果
-- @function [parent=#string] rtrim
-- @param string input 输入字符串
-- @return string#string  结果
-- @see string.ltrim, string.trim

--[[--

去除输入字符串尾部的空白字符，返回结果

~~~ lua

local input = "ABC  "
print(string.rtrim(input))
-- 输出 ABC，输入字符串最后的两个空格被去掉了

~~~

]]

-- end --

function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

-- start --

--------------------------------
-- 去掉字符串首尾的空白字符，返回结果
-- @function [parent=#string] trim
-- @param string input 输入字符串
-- @return string#string  结果
-- @see string.ltrim, string.rtrim

--[[--

去掉字符串首尾的空白字符，返回结果

]]

-- end --

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

-- start --

--------------------------------
-- 将字符串的第一个字符转为大写，返回结果
-- @function [parent=#string] ucfirst
-- @param string input 输入字符串
-- @return string#string  结果

--[[--

将字符串的第一个字符转为大写，返回结果

~~~ lua

local input = "hello"
print(string.ucfirst(input))
-- 输出 Hello

~~~

]]

-- end --

function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

-- start --

--------------------------------
-- 将字符串转换为符合 URL 传递要求的格式，并返回转换结果
-- @function [parent=#string] urlencode
-- @param string input 输入字符串
-- @return string#string  转换后的结果
-- @see string.urldecode

--[[--

将字符串转换为符合 URL 传递要求的格式，并返回转换结果

~~~ lua

local input = "hello world"
print(string.urlencode(input))
-- 输出
-- hello%20world

~~~

]]

-- end --

function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

-- start --

--------------------------------
-- 将 URL 中的特殊字符还原，并返回结果
-- @function [parent=#string] urldecode
-- @param string input 输入字符串
-- @return string#string  转换后的结果
-- @see string.urlencode

--[[--

将 URL 中的特殊字符还原，并返回结果

~~~ lua

local input = "hello%20world"
print(string.urldecode(input))
-- 输出
-- hello world

~~~

]]

-- end --

function string.urldecode(input)
    input = string.gsub(input, "+", " ")
    input = string.gsub(input, "%%(%x%x)", function(h)
        return string.char(checknumber(h, 16))
    end)
    input = string.gsub(input, "\r\n", "\n")
    return input
end

-- start --

--------------------------------


-- start --

--------------------------------
-- 将数值格式化为包含千分位分隔符的字符串
-- @function [parent=#string] formatnumberthousands
-- @param number num 数值
-- @return string#string  格式化结果

--[[--

将数值格式化为包含千分位分隔符的字符串

~~~ lua

print(string.formatnumberthousands(1924235))
-- 输出 1,924,235

~~~

]]

-- end --

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

local s_table = {}
---拼接字符串
---@vararg string 参数列表
---@return string
function string.concat(...)
    table.clear(s_table)
    local len = select("#", ...)
    if len > 0 then
        for i = 1, len do
            local v = select(i, ...)
            table.insert(s_table, tostring(v))
        end
    end
    return #s_table > 0 and table.concat(s_table) or ''
end

---@param delimiter string 连接符
---@param t string[]
function string.join(delimiter, t)
    return table.concat(t, delimiter)
end

---@type table 存放字符串数组
local str_replace_ret = {}
---替换字符串
---@param s string
---@param pattern string
---@param rep string,boolean
function string.replace(s, pattern, rep)
    local i, j = string.find(s, pattern, 1, true)
    if i and j then
        table.clear(str_replace_ret)
        local ret = str_replace_ret
        local start = 1
        while i and j do
            table.insert(ret, string.sub(s, start, i - 1))
            table.insert(ret, rep)
            start = j + 1
            i, j = string.find(s, pattern, start, true)
        end
        table.insert(ret, string.sub(s, start))
        return table.concat(ret), true
    end
    return s, false
end

---获取utf8字符串长度("你好World" 输出 7)
---@param input string
---@return int
function string.utf8len(input)
    return utf8.len(input)
end

---截取字符串
---@param str string
---@param start_index int
---@param end_index int
---@return string
function string.utf8sub(str, start_index, end_index)
    return utf8.sub(str, start_index, end_index)
end

local hash_to_string = {}
---string to hash
---@param key string
---@param cache boolean
---@return number
function string.hash(key, cache)
    if string.isnilorempty(key) then
        return key
    end
    local hash = utf8.getstringcrchash(key)
    ---开启GM的时候才记录
    if UNITY_EDITOR or cache then
        hash_to_string[hash] = key
    end
    return hash
end

---hash to string
---@param hash number
---@return string
function string.hashtostring(hash)
    return hash_to_string[hash]
end

---用utf8Index搜索
---@param s string
---@param pattern string
---@param init number
---@param plain boolean
---@return number, number, string
function string.utf8find(s, pattern, init, plain)
    local minIndex, maxIndex, result = string.find(s, pattern, init, plain)
    local utf8minIndex = nil
    local uft8maxIndex = nil
    if minIndex ~= nil then
        local length = 0 -- 字符的个数
        local singleLength = 0
        local i = 1
        local byteCount = 1
        while i <= maxIndex do
            if i == minIndex then
                utf8minIndex = length + 1
            end
            byteCount, singleLength = string.getbytecountsteplength(s, i)
            length = length + 1
            i = i + byteCount
        end
        uft8maxIndex = length
    end
    return utf8minIndex, uft8maxIndex, result
end

---@public 获取字符串的长度
---@param inputStr string 字符串
---@return int
function string.getcharaterlength(inputStr)
    if type(inputStr) ~= "string" or string.isnilorempty(inputStr) then
        return 0
    end
    return string.getStrUnicodeLength(inputStr)
end
---@public 输入一串字符串，返回经过unicode处理后的长度
---@param inputStr string 字符串
---@return number 字符串的长度，详情见LYDJS-41816 https://www.teambition.com/task/64f9afcbee5a017daa4cf909
function string.getStrUnicodeLength(inputStr)
    local length = 0
    if type(inputStr) ~= "string" or string.isnilorempty(inputStr) then
        return length
    end
    for _, unicode in utf8.codes(inputStr) do
        -- 检查字符是否在指定 Unicode 范围内
        if (unicode >= 0x0000 and unicode <= 0x007F) or --基础拉丁语字符        0000-007F
                (unicode >= 0x0080 and unicode <= 0x00FF) or--拉丁语增补字符        0080-00FF
                (unicode >= 0x0100 and unicode <= 0x017F) or--拉丁语扩展-A字符        0100-017F
                (unicode >= 0x0180 and unicode <= 0x024F) or--拉丁语扩展-B字符        0180-024F
                (unicode >= 0x0250 and unicode <= 0x02AF) or--国际音标扩展字符        0250-02AF
                (unicode >= 0x02B0 and unicode <= 0x02FF) or--间距修饰字符字符        02B0-02FF
                (unicode >= 0x0370 and unicode <= 0x03FF) or--希腊语和科普特语字符        0370-03FF
                (unicode >= 0x0400 and unicode <= 0x04FF) or--西里尔文字符        0400-04FF
                (unicode >= 0x20A0 and unicode <= 0x20CF) or--货币符号        20A0-20CF
                (unicode >= 0x2150 and unicode <= 0x218F) or--数字形式符号        2150-218F
                (unicode >= 0x2200 and unicode <= 0x22FF) then--数学运算符字符        2200-22FF
            length = length + 1 -- 字符在指定范围内，长度1
        else
            length = length + 2 -- 长度为2
        end
    end
    return length
end

---@public 将中英文字符截取在固定长度内
---@param inputStr string
---@param characterLimit number int
function string.cutoverflow(inputStr, characterLimit)
    local totalLength = string.getcharaterlength(inputStr)
    if totalLength <= characterLimit then
        return inputStr
    end

    local length = 0 -- 字符的个数
    local singleLength = 0
    local i = 1
    local byteCount = 1
    local lenInByte = string.len(inputStr)
    local fixValue
    while i <= lenInByte do
        byteCount, singleLength = string.getbytecountsteplength(inputStr, i)
        length = length + singleLength
        i = i + byteCount

        if length <= characterLimit then
            fixValue = string.sub(inputStr, 1, i - 1)
        end

        ---如果算上当前的长度已经超过了，此时ByteCount，不需要加上了。
        if length >= characterLimit then
            break
        end
    end

    return fixValue
end

---@public 从字符串后面截取多余中英文字符
---@param source string 中英文字符
---@param overFlow number 多余的字符长度
---@return string
function string.cutlast(source, overFlow)
    if string.isnilorempty(source) then
        return source
    end
    local realLength = string.len(source)
    if overFlow > realLength then
        return source
    end

    local internal_overflow = 0
    local singleLength = 0
    local i = realLength
    local byteCount = 1
    while i >= 1 do
        byteCount, singleLength = string.getbytecountsteplength(source, i)
        internal_overflow = internal_overflow + singleLength
        i = i - byteCount

        ---如果算上当前的长度已经超过了，此时ByteCount，不需要加上了。
        if internal_overflow >= overFlow then
            break
        end
    end

    local fixSource = string.sub(source, 1, i)
    return fixSource
end

---@public 获取当前index在字符串里面的Byte步进值
---@param str string
---@param index number
---@return number
function string.getbytecount(str, index)
    local byteCount, length = string.getbytecountsteplength(str, index)
    return byteCount
end

---@public 获取当前index在字符串里面的Byte步进值和长度值
---@param str string
---@param index number
---@return number,number
function string.getbytecountsteplength(str, index)
    local byteValue = string.byte(str, index)
    local byteCount = 0
    local length = 0
    if byteValue == nil then
        Debug.LogError("byteValue is nil! ", str, index)
        byteCount = 0
        length = 0
    elseif byteValue > 239 then
        byteCount = 4-- 4字节字符
        length = 2
    elseif byteValue > 223 then
        byteCount = 3-- 汉字
        length = 2
    elseif byteValue > 128 then
        byteCount = 2-- 双字节字符
        length = 2
    else
        byteCount = 1-- 单字节字符
        length = 1
    end
    return byteCount, length
end

---是否包含中文
---@param input string
---@return boolean
function string.containchinese(input)
    if string.isnilorempty(input) then
        return false
    end
    local length = string.len(input)
    for i = 1, length do
        local byte = string.byte(input, i)
        if byte >= 228 and byte <= 233 then
            return true
        end
    end

    return false
end

---是否包含数字或者字母
---@param input string
---@return boolean
function string.containnumorword(input)
    return not string.isnilorempty(input) and not string.isnilorempty(string.match(input, "[%a%d]"))
end

---是否包含字母
---@param input string
---@return boolean
function string.containword(input)
    return not string.isnilorempty(input) and not string.isnilorempty(string.match(input, "[%a]"))
end

---md5加密
---@return string (32位小写)
function string.md5(key)
    --return md5.sumhexa(key)
    return md5.tomd5(key)
end

---@param str string
---@return string
function string.compress(str)
    return not string.isnilorempty(str) and zlib.compress(str) or str
end

---@param str string
---@return string
function string.decompress(str)
    return not string.isnilorempty(str) and zlib.decompress(str) or str
end