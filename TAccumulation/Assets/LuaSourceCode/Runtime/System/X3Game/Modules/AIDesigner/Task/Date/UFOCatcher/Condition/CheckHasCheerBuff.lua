﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/14 15:12
---

local AICondition = require("Runtime.Plugins.AIDesigner.Base.AITask").AICondition

---Category:Date/UFOCatcher
---@class CheckHasCheerBuff:AICondition
local CheckHasCheerBuff = class("CheckHasCheerBuff", AICondition)

---@return AITaskState
function CheckHasCheerBuff:OnUpdate()
    local cheerBuffData = BllMgr.GetUFOCatcherBLL():UFOCatcherSPAction()
    if cheerBuffData and cheerBuffData.BuffFucType == 1 then
        return AITaskState.Success
    end
    return AITaskState.Failure
end

return CheckHasCheerBuff