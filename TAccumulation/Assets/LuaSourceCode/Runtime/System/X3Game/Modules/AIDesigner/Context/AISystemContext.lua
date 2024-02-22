﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/7/16 14:49
---

local AIContext = require("Runtime.Plugins.AIDesigner.Base.AIContext")

---@class AISystemContext:AIContext
local AISystemContext = class("AISystemContext", AIContext)

function AISystemContext:ctor(master)
    AIContext.ctor(self,master)
    math.randomseed(os.time())
end

---@return number
function AISystemContext:GetRealtime()
    return  TimerMgr.RealtimeSinceStartup()
end

---@return number
function AISystemContext:GetDeltaTime()
    return TimerMgr.GetCurTickDelta()
end

---@return table
function AISystemContext:GetTable()
    return PoolUtil.GetTable()
end

---@param t table
function AISystemContext:ReleaseTable(t)
    PoolUtil.ReleaseTable(t)
end

function AISystemContext:Random(min, max)
    return math.random(min, max)
end

---@param value float
---@return float
function AISystemContext:Ceil(value)
    return math.ceil(value)
end

---@param value float
---@return float
function AISystemContext:Floor(value)
    return math.floor(value)
end

---@return any
function AISystemContext:ParseVarValue(type, value)
    if type == AIVarType.None then
        return value
    elseif type == AIVarType.Float then
        return value * 0.001
    elseif type == AIVarType.Int then
        return value
    elseif type == AIVarType.String then
        return value
    elseif type == AIVarType.Boolean then
        return value
    elseif type == AIVarType.Object then
        return value
    elseif type == AIVarType.Vector2 then
        return CS.UnityEngine.Vector2(value.x, value.y) * 0.001
    elseif type == AIVarType.Vector2Int then
        return CS.UnityEngine.Vector2Int(value.x, value.y)
    elseif type == AIVarType.Vector3 then
        return CS.UnityEngine.Vector3(value.x, value.y, value.z) * 0.001
    elseif type == AIVarType.Vector3Int then
        return CS.UnityEngine.Vector3Int(value.x, value.y, value.z)
    elseif type == AIVarType.Vector4 then
        return CS.UnityEngine.Vector4(value.x, value.y, value.z, value.w) * 0.001
    end
end

return AISystemContext