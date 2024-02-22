---Runtime.System.X3Game.Modules.AIDesigner.Task.Action/SetString.lua
---Created By 教主
--- Created Time 16:24 2021/7/22

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---原始值:sourceValue,存储变量：storeResult
---@class SystemAI.SetString:AIAction
---@field sourceValue AIVar|String
---@field storeResult AIVar|String
local SetString = AIUtil.class("SetString", AIAction)

function SetString:OnUpdate()
    self.storeResult:SetValue(self.sourceValue:GetValue())
    return AITaskState.Success
end

return SetString