---Runtime.System.X3Game.Modules.AIDesigner.Task.Condition/StringComparison.lua
---Created By 教主
--- Created Time 11:31 2021/7/22

local AICondition = require("Runtime.Plugins.AIDesigner.Base.AITask").AICondition

---字符串比较，比较两个字符串是否相等
---@class SystemAI.StringComparison:AICondition
---@field str1 AIVar|String
---@field str2 AIVar|String
local StringComparison = AIUtil.class("StringComparison", AICondition)

function StringComparison:OnUpdate()
    return self.str1:GetValue() == self.str2:GetValue() and AITaskState.Success or AITaskState.Failure
end

return StringComparison