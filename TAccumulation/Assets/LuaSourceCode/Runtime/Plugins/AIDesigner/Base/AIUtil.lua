﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/7/29 11:47
---

AIUtil = {}

---@return table
function AIUtil.Split(str, reps)
    local tab = {}
    string.gsub(str, '[^' .. reps .. ']+', function(w)
        table.insert(tab, w)
    end)
    return tab
end

---@param str string
---@return boolean
function AIUtil.StringIsNullOrEmpty(str)
    if not str or "" == str then
        return true
    else
        return false
    end
end

---@param func fun()
function AIUtil.TryCall(func, ...)
    if func then
        func(...)
    end
end

---@param func fun()
function AIUtil.TryPCall(func, ...)
    if func then
        pcall(func, ...)
    end
end

---@return
function AIUtil.class(...)
    return class(...)
end