﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/2/6 15:20
---
---@type FlowNode
local FlowNode = require("Runtime.Plugins.FlowCanvas.Base.FlowNode")
---@class FlowCondition:FlowNode
local FlowCondition = class("FlowCondition", FlowNode)

function FlowCondition:OnUpdate()
    return FlowState.Success
end

return FlowCondition