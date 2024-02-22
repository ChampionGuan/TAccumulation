﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/9/1 19:05
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---Category:Date/CoupleUFOCatcher
---@class BlockStopAI:AIAction
---@field block Boolean
---@field unblock Boolean
local BlockStopAI = class("BlockStopAI", AIAction)

---
function BlockStopAI:OnEnter()
    if self.block then
        EventMgr.Dispatch("SwitchDelayCheer", true)
    end

    if self.unblock then
        EventMgr.Dispatch("SwitchDelayCheer", false)
    end
end

---@return AITaskState
function BlockStopAI:OnUpdate()
    return AITaskState.Success
end

return BlockStopAI