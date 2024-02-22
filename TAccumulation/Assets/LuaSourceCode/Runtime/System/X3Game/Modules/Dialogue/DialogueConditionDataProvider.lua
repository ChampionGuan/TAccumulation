﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by 峻峻.
--- DateTime: 2021/4/12 14:47
---

---@class DialogueConditionDataProvider
local DialogueConditionDataProvider = class("DialogueConditionDataProvider")

---@param ownerSystem DialogueSystem
function DialogueConditionDataProvider:ctor(ownerSystem)
    self.ownerSystem = ownerSystem
end

---条件检查的特殊数据提供器
---@param type ConditionType
---@param param1 string
---@return table
function DialogueConditionDataProvider:GetData(type, param1)
    local data = nil
    if type == X3_CFG_CONST.CONDITION_RANDOM then
        data = self.ownerSystem:GetRandom(0, 10000)
    elseif type == X3_CFG_CONST.CONDITION_VARIABLE_STATE then
        data = self.ownerSystem:GetVariableState(tonumber(param1))
    end

    return data
end

return DialogueConditionDataProvider