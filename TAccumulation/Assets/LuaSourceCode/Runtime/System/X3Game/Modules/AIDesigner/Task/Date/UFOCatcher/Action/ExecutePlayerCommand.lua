﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/13 17:06
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---Category:Date/UFOCatcher
---@class ExecutePlayerCommand:AIAction
---@field duration Float
---@field durationVar Float
local ExecutePlayerCommand = class("ExecutePlayerCommand", AIAction)

function ExecutePlayerCommand:OnEnter()
    ---@type float
    self.deltaTime = 0
    ---@type float
    self.needMoveTime = Mathf.RandomFloat(self.duration, self.duration + self.durationVar)
    ---@type Vector3
    self.commandDirection = BllMgr.GetUFOCatcherBLL():GetMoveDirection()
    ---@type GameObject
    self.body = self.tree:GetVariable("clawBody")
    ---@type ClawController
    self.clawController = self.tree:GetVariable("UFOCatcherController").clawController
end

---@return AITaskState
function ExecutePlayerCommand:OnUpdate()
    self.deltaTime = self.deltaTime + TimerMgr.GetCurTickDelta()
    self.clawController:MoveClawByWorldDirection(self.commandDirection.x, self.commandDirection.z)

    if self.deltaTime < self.needMoveTime then
        return AITaskState.Running
    end
    return AITaskState.Success
end

return ExecutePlayerCommand