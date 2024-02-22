﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/14 16:02
---

local AICondition = require("Runtime.Plugins.AIDesigner.Base.AITask").AICondition

---Category:Date/UFOCatcher
---@class CheckNearDoll:AICondition
---@field distance Float 水平距离离娃娃的距离，小于该值判定为成功
---@field checkDistance Float 判断保护用，如果发现爪子前后距离差小于该值，则判断爪子已卡住无法继续移动，条件判断通过
local CheckNearDoll = class("CheckNearDoll", AICondition)

function CheckNearDoll:OnReset()
    ---@type float
    self.lastDistanceX = 0
    ---@type float
    self.lastDistanceZ = 0
end

function CheckNearDoll:OnEnter()
    ---@type GameObject
    self.body = self.tree:GetVariable("clawBody")
    ---@type GameObject
    self.target = self.tree:GetVariable("catchTarget")
    ---@type GameObject
    self.ufoCatcher = self.tree:GetVariable("UFOCatcher")
end

---@return AITaskState
function CheckNearDoll:OnUpdate()
    --local targetPosition = GameObjectUtil.GetPosition(self.target)
    local targetPosition = self.target:GetComponentInChildren(typeof(CS.X3Game.DollCheckCollider)).transform.position
    local circleCenter = self.tree:GetVariable("CircleCenter")
    local predictAngle = self.tree:GetVariable("PredictAngle")
    local bodyPosition = GameObjectUtil.GetPosition(self.body)
    if circleCenter ~= nil and predictAngle ~= nil and predictAngle ~= 0 then
        targetPosition = Quaternion.AngleAxis(predictAngle, Vector3.up) * (targetPosition - circleCenter) + circleCenter
    end

    local distanceX = targetPosition.x - bodyPosition.x
    local distanceZ = targetPosition.z - bodyPosition.z
    if math.abs(Vector2.Temp(self.lastDistanceX, self.lastDistanceZ).magnitude
            - Vector2.Temp(distanceX, distanceZ).magnitude) <= self.checkDistance then
        return AITaskState.Success
    else
        self.lastDistanceX = distanceX
        self.lastDistanceZ = distanceZ
    end
    if math.pow(distanceX, 2) + math.pow(distanceZ, 2) <= math.pow(self.distance, 2) then
        return AITaskState.Success
    end
    return AITaskState.Failure
end

return CheckNearDoll