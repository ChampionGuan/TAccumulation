﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canglan.
--- DateTime: 2021/11/18 11:04
---

local UIBehaviorBase = require("Runtime.Battle.Behavior.UI.UIBehaviorBase")

---@class WarningFx:UIBehaviorBase
local WarningFx = XECS.class("WarningFx", UIBehaviorBase)
WarningFx.Type = BattleUIBehaviorType.WarningFx

function WarningFx:ctor()
    UIBehaviorBase.ctor(self)
    ---@type bool
    self._active = nil
end

function WarningFx:Awake()
    UIBehaviorBase.Awake(self)
    self._transform = self:GetComponent("OCX_warning", "Transform")
    self:SetActive(self._transform, true)
    self:SetNodeVisible(self._transform, false)
    self._motionOpenIndex = 0
    self._motionKeepIndex = 1
    self._motionCloseIndex = 2
end

function WarningFx:Start()
    UIBehaviorBase.Start(self)
    self._active = false
end

function WarningFx:_OnUpdate()
    if self._battleUI.isArtEditor then
        return
    end
    self:_UpdateWarningAnim()
end

function WarningFx:_UpdateWarningAnim()
    if self._battleUI:LeftIsNearDead() then
        if not self._active then
            self._active = true
            self:SetNodeVisible(self._transform, self._active)
            self:StopAllCustomMotions(self._transform)
            self:PlayCustomMotion(self._transform, self._motionOpenIndex, g_BattleClient:SafeHandler(self,self._PlayKeepMotion))
        end
    else
        if self._active then
            self:StopAllCustomMotions(self._transform)
            self:PlayCustomMotion(self._transform, self._motionCloseIndex)
            self._active = false
            self:SetNodeVisible(self._transform, self._active)
        end
    end
end

function WarningFx:_PlayKeepMotion()
    self:PlayCustomMotion(self._transform, self._motionKeepIndex)
end

function WarningFx:OnDestroy()
    self._active = nil
    UIBehaviorBase.OnDestroy(self)
end

return WarningFx