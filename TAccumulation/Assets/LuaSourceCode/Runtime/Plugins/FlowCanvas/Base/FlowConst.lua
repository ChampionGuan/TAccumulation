﻿---
--- Generated by EmmyLua(https:..github.com.EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023.2.6 11:28

---@class FlowConst
local FlowConst = {}
---@type FlowConst.FlowType
FlowConst.FlowType = require("Config.System.AutoGenerated.FlowTypeConf")
---@type FlowConst.FlowClassType
FlowConst.FlowClassType = require("Config.System.AutoGenerated.FlowClassConf")
---当前基本目录
FlowConst.FlowGraphRootPath = "Assets.Build.Res.GameObjectRes.FlowCanvas."
FlowConst.FlowGraphPrefabRootPath = string.concat(FlowConst.FlowGraphRootPath, "FlowPrefab.")
FlowConst.FlowGraphAssetRootPath = string.concat(FlowConst.FlowGraphRootPath, "FlowAsset.")
---状态
---@class FlowState
FlowState = {
    None = 0,
    Failure = 1,
    Success = 2,
    Running = 3,
}

---@class FlowNodeType
FlowNodeType = {
    Action = 1,
    Condition = 2,
    Event = 3,
    Listener = 4,
}

return FlowConst