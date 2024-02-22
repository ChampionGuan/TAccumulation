﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2020/12/2 18:17
---

local AICondition = require("Runtime.Plugins.AIDesigner.Base.AITask").AICondition

---值比较，boolean1与boolean2大小比较
---@class SystemAI.BooleanComparison:AICondition
---@field boolean1 AIVar|Boolean
---@field boolean2 AIVar|Boolean
local BooleanComparison = AIUtil.class("BooleanComparison", AICondition)

function BooleanComparison:OnUpdate()
    return self.boolean1:GetValue() == self.boolean2:GetValue() and AITaskState.Success or AITaskState.Failure
end

return BooleanComparison