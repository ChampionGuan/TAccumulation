﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2020/12/4 20:56
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---@class SystemAI.SetVector4:AIAction
---@field sourceValue AIVar|Vector4
---@field storeResult AIVar|Vector4
local SetVector4 = AIUtil.class("SetVector4", AIAction)

function SetVector4:OnUpdate()
    self.storeResult:SetValue(self.sourceValue:GetValue())
    return AITaskState.Success
end

return SetVector4