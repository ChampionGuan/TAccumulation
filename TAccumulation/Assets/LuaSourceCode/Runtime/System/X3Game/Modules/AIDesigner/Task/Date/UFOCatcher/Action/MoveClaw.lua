﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/13 17:14
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---Category:Date/UFOCatcher
---@class MoveClaw:AIAction
---@field distanceRangeX Vector2
---@field distanceRangeZ Vector2
local MoveClaw = class("MoveClaw", AIAction)

function MoveClaw:OnEnter()
    ---@type GameObject
    self.body = self.tree:GetVariable("clawBody")
    ---@type GameObject
    self.target = self.tree:GetVariable("catchTarget")
    ---@type ClawController
    self.clawController = self.tree:GetVariable("UFOCatcherController").clawController
    ---@type GameObject
    self.ufoCatcher = self.tree:GetVariable("UFOCatcher")
    ---@type float
    self.checkStartTime = 0
    ---@type float
    self.directionX = 0
    ---@type float
    self.directionZ = 0
    ---@type Vector2
    self.moveDirection = Vector2.zero
    ---@type float
    self.lastPositionX = 0
    ---@type float
    self.lastPositionZ = 0
    ---@type Vector2
    self.lastDirection = Vector2.zero
    ---@type float
    self.startPositionX = 0
    ---@type float
    self.startPositionZ = 0
    ---@type float
    self.needMoveX = 0
    ---@type float
    self.needMoveZ = 0

    local bodyPosition = GameObjectUtil.GetPosition(self.body)
    self.startPositionX = bodyPosition.x
    self.startPositionZ = bodyPosition.z
    self.needMoveX = Mathf.RandomFloat(self.distanceRangeX.x, self.distanceRangeX.y)
    self.needMoveZ = Mathf.RandomFloat(self.distanceRangeZ.x, self.distanceRangeZ.y)
    --local targetPosition = GameObjectUtil.GetPosition(self.target)
    local targetPosition = self.target:GetComponentInChildren(typeof(CS.X3Game.DollCheckCollider)).transform.position
    local circleCenter = self.tree:GetVariable("CircleCenter")
    local predictAngle = self.tree:GetVariable("PredictAngle")
    if circleCenter ~= nil and predictAngle ~= nil and predictAngle ~= 0 then
        targetPosition = Quaternion.AngleAxis(predictAngle, Vector3.up) * (targetPosition - circleCenter) + circleCenter
    end
    EventMgr.Dispatch("MoveClaw", targetPosition)
    self.directionX = targetPosition.x - bodyPosition.x
    self.directionZ = targetPosition.z - bodyPosition.z
    EventMgr.Dispatch("UFOCATCHEREVENT_AI_MOVECLAW", nil)
end

---@return AITaskState
function MoveClaw:OnUpdate()
    local bodyPosition = GameObjectUtil.GetPosition(self.body)
    self.moveDirection = Vector2.zero
    if math.abs(bodyPosition.x - self.startPositionX) < self.needMoveX then
        self.moveDirection.x = self.directionX
    end
    if math.abs(bodyPosition.z - self.startPositionZ) < self.needMoveZ then
        self.moveDirection.y = self.directionZ
    end
    if self.clawController.isGetStuck then
        self.clawController.isGetStuck = false
        return AITaskState.Success
    end
    if Vector2.Dot(self.lastDirection, self.moveDirection) < 0 then
        return AITaskState.Success
    end
    self.lastDirection = self.moveDirection
    if TimerMgr.RealtimeSinceStartup() - self.checkStartTime > 1 then
        self.checkStartTime = TimerMgr.RealtimeSinceStartup()
        if Vector2.Distance(Vector2.Temp(self.lastPositionX, self.lastPositionZ),
                Vector2.Temp(bodyPosition.x, bodyPosition.z)) <= 0.005 then
            return AITaskState.Success
        else
            self.lastPositionX = bodyPosition.x
            self.lastPositionZ = bodyPosition.z
        end
    end

    if self.moveDirection:SqrMagnitude() >= 0.0001 then
        --如果有抖动的话挪到FixedUpdate里
        if self.moveDirection ~= Vector2.zero then
            local worldDirection = self.ufoCatcher.transform:TransformDirection(self.moveDirection.x, self.moveDirection.y, 0).normalized
            self.clawController:MoveClawByWorldDirection(worldDirection.x, worldDirection.y)
        end
        return AITaskState.Running
    end
    return AITaskState.Success
end

return MoveClaw