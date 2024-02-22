﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/14 15:02
---

local AICondition = require("Runtime.Plugins.AIDesigner.Base.AITask").AICondition

---Category:Date/Common
---@class CheckGameCondition:AICondition
---@field id int
---@field paramList int[]
local CheckGameCondition = class("CheckGameCondition", AICondition)

---@return AITaskState
function CheckGameCondition:OnUpdate()
    local result = ConditionCheckUtil.SingleConditionCheck(self.id, self.paramList)
    if result then
        return AITaskState.Success
    end
    return AITaskState.Failure
end

return CheckGameCondition