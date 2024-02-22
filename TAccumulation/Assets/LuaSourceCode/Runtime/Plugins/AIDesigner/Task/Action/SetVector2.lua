﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2020/12/4 20:56
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---@class SystemAI.SetVector2:AIAction
---@field sourceValue AIVar|Vector2
---@field storeResult AIVar|Vector2
local SetVector2 = AIUtil.class("SetVector2", AIAction)

function SetVector2:OnUpdate()
    self.storeResult:SetValue(self.sourceValue:GetValue())
    return AITaskState.Success
end

return SetVector2