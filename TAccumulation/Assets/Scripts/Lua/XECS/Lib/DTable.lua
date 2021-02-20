---
---Created by xujie
---Date: 2020/9/1
---Time: 17:47
---
---deterministic table
---可以进行确定性遍历的table
---@class DTable
---@field __dt_Keys any[]
---@field __dt_table table<any, any>

local mt = {}
function mt.__index(t, k)
    return rawget(t.__dt_table, k)
end

function mt.__newindex(t, k, v)
    local preValue = rawget(t.__dt_table, k)
    ---如果是相同的key-value键值对，则跳过
    if preValue == v then
        return
    end

    local dtKeys = t.__dt_Keys

    ---删除之前的值
    if preValue then
        for i, dt_key in ipairs(dtKeys) do
            if dt_key == k then
                table.remove(dtKeys, i)
                break
            end
        end
    end

    rawset(t.__dt_table, k, v)
    if v then
        table.insert(dtKeys, k)
    end
end

function mt.__len(t)
    return #t.__dt_Keys
end
local dLen = mt.__len

local function newDT(...)
    local t = {...}
    t.__dt_Keys = {}
    t.__dt_table = {}
    setmetatable(t, mt)
    return t
end

---@generic K, V
---@param dt table<K, V>|V[]
---@return fun(tbl: table<K, V>):K, V
local function dPairs(dt)
    if not dt then
        return function() end
    end

    local dtKeys = dt.__dt_Keys
    local i = #dtKeys + 1
    return function()
        i = i - 1
        if i >= 1 then
            local k = rawget(dtKeys, i)
            return k, rawget(dt.__dt_table, k)
        end
    end
end

---根据key添加的先后顺序，从前往后有序遍历
---@generic K, V
---@param dt table<K, V>|V[]
---@return fun(tbl: table<K, V>):K, V
local function dSortingPair(dt)
    if not dt then
        return function() end
    end

    local dtKeys = dt.__dt_Keys
    local count = #dtKeys
    local i = 0
    return function()
        i = i + 1
        if i <= count then
            local k = rawget(dtKeys, i)
            return k, rawget(dt.__dt_table, k)
        end
    end
end

local function dNext(dt, index)
    return next(dt.__dt_table, index)
end

return function() return newDT, dPairs, dSortingPair, dNext, dLen end