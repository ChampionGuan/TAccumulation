﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/4/20 15:25
---

---@class DollController : GameObjectCtrl
local DollController = class("DollController", GameObjectCtrl)
local UFOCatcherEnum = require("Runtime.System.X3Game.Modules.UFOCatcher.Data.UFOCatcherEnum")

---@class RigidbodyConstraints
local RigidbodyConstraints = {
    None = 0,
    FreezePositionX = 2,
    FreezePositionY = 4,
    FreezePositionZ = 8,
    FreezePosition = 14,
    FreezeRotationX = 16,
    FreezeRotationY = 32,
    FreezeRotationZ = 64,
    FreezeRotation = 112,
    FreezeAll = 126,
}

---
function DollController:Init()
    ---@type CS.UnityEngine.Rigidbody
    self.rigidBody = self.gameObject:GetComponentInChildren(typeof(CS.UnityEngine.Rigidbody))
    ---@type boolean
    self.isFreezing = false
    ---@type Transform
    self.freezeParent = nil
    ---@type Vector3
    self.freezePos = nil
    ---@type GameObject 冰冻用的盒子，为了顶墙
    self.fakeBox = nil
    ---@type int
    self.fixedUpdateTimer = 0
    ---@type int
    self.updateTimer = 0
    ---@type Vector3 漂浮
    self.isFloating = false
    ---@type Vector3 娃娃初始位置
    self.initPos = nil
    EventMgr.AddListener("EVENT_UFOCATCHER_CLAW_LOOSEN", self.CheckPhysics, self)
    EventMgr.AddListener("EVENT_UFOCATCHER_CLAW_BEGIN_CATCHING", self.RecordInitPos, self)
end

---
function DollController:FixedUpdate()
    ---冰冻效果
    if self.isFreezing then
        local pos = GameObjectUtil.GetPosition(self.freezeParent) - self.freezePos
        GameObjectUtil.SetPosition(self.fakeBox, pos)
        local velocityY = self.rigidBody.velocity.y
        self.rigidBody.velocity = Vector3(0, velocityY, 0)
    end
    ---漂浮效果
    if self.isFloating then
        self:UpdateFloating()
    end
end

--[[---
function DollController:LateUpdate()
    local freezePos = GameObjectUtil.GetPosition(self.freezeParent) - GameObjectUtil.GetPosition(self.gameObject)
    --顶墙相对位置修正
    if Vector2.Distance(freezePos, self.freezePos) > 0.01 then
        self.freezePos = freezePos
        Debug.LogFormat("DollController触发顶墙位置修正")
    end
end]]

--region 个性化-冰冻
---冰冻效果
function DollController:OpenFreeze()
    --self:SetLayer(self.gameObject, Const.LayerMask.DEFAULT, true)
    --self.rigidBody.useGravity = false
    --self.rigidBody.isKinematic = true
    self.fakeBox = GameObjectUtil.CreateGameObject("FreezeBox", self.transform.parent, true)
    GameObjectUtil.SetParent(self.gameObject, self.fakeBox, true)
    self.freezePos = GameObjectUtil.GetPosition(self.freezeParent) - GameObjectUtil.GetPosition(self.fakeBox)
    self.rigidBody.constraints = RigidbodyConstraints.FreezePositionY + RigidbodyConstraints.FreezeRotation
    self.isFreezing = true
    --self.fixedUpdateTimer = TimerMgr.AddTimerByFrame(1, self.FixedUpdate, self, true, TimerMgr.UpdateType.FIXED_UPDATE)
    self.updateTimer = TimerMgr.AddTimerByFrame(1, self.FixedUpdate, self, true, TimerMgr.UpdateType.LATE_UPDATE)
end

---关闭冰冻
---@param clawType UFOCatcherEnum.ClawType
function DollController:CloseFreeze(clawType)
    if self.isFreezing then
        --self:SetLayer(self.gameObject, Const.LayerMask.PhysicsLayer, true)
        --self.rigidBody.useGravity = true
        --self.rigidBody.isKinematic = false
        self.rigidBody.constraints = RigidbodyConstraints.None
        local velocityY = self.rigidBody.velocity.y
        self.rigidBody.velocity = Vector3(0, velocityY, 0)
        if clawType == UFOCatcherEnum.ClawType.TwoClaw then
            self.rigidBody.angularVelocity = Vector3.Temp(100, 0, 0)
        end
        self.isFreezing = false
        GameObjectUtil.SetParent(self.gameObject, self.fakeBox.transform.parent, true)
        if self.fakeBox then
            GameObjectUtil.Destroy(self.fakeBox)
            self.fakeBox = nil
        end
        if self.fixedUpdateTimer then
            TimerMgr.Discard(self.fixedUpdateTimer)
            self.fixedUpdateTimer = 0
        end
        if self.updateTimer then
            TimerMgr.Discard(self.updateTimer)
            self.updateTimer = 0
        end
    end
end

---设置冰冻父节点
---@param parent Transform
function DollController:SetFreezeParent(parent)
    self.freezeParent = parent
end
--endregion

--region 个性化-漂浮
---更新漂浮位置
function DollController:UpdateFloating()

end

---
function DollController:OpenFloating(time, power)
    --TODO
    self.isFloating = true
end
--endregion

---记录抓取时的初始位置
function DollController:RecordInitPos()
    self.initPos = GameObjectUtil.GetPosition(self.gameObject)
end

---检查物理状态，如果娃娃在爪子上卡住之类的，开关下物理
function DollController:CheckPhysics()
    if self.initPos then
        local _, y, _ = GameObjectUtil.GetPositionXYZ(self.gameObject)
        if math.abs(self.initPos.y - y) > 0.3 then
            local velocityY = self.rigidBody.velocity.y
            self.rigidBody.useGravity = false
            self.rigidBody.useGravity = true
            self.rigidBody.velocity = Vector3(0, math.max(velocityY, 0.1), 0)
        end
    end
end

---销毁逻辑
function DollController:OnDestroy()
    if self.fixedUpdateTimer then
        TimerMgr.Discard(self.fixedUpdateTimer)
        self.fixedUpdateTimer = 0
    end
    if self.updateTimer then
        TimerMgr.Discard(self.updateTimer)
        self.updateTimer = 0
    end
    if self.fakeBox then
        GameObjectUtil.Destroy(self.fakeBox)
        self.fakeBox = nil
    end
end
return DollController