﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun.
--- DateTime: 2021/6/17 17:14
---

---娃娃机查看男主时的屏幕拖动控制
---@class UFOCatcherTouchCtrl:GameObjectCtrl
local UFOCatcherTouchCtrl = class("UFOCatcherTouchCtrl", GameObjectCtrl)
local CtrlType = GameObjClickUtil.CtrlType
local TouchType = GameObjClickUtil.TouchType

---
function UFOCatcherTouchCtrl:Init()
    self.gestureCtrl = GameObjClickUtil.Get(self.gameObject)
    self.gestureCtrl:SetTouchBlockEnableByUI(TouchType.ON_DRAG, true)
    self.gestureCtrl:SetDelegate(self)
    self.gestureCtrl:SetCtrlType(CtrlType.DRAG)
    self.cameraPath = "Assets/Build/Res/GameObjectRes/Camera/UFOCatcher.prefab"
    self.virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.AutoSyncMode, self.cameraPath)
    self.canControl = false
    self.parameter = {
        RotateWeight = 0.02,
        RotXChangeLimitMin = 0,
        RotXChangeLimitMax = 0,
        RotYChangeLimitMin = -25,
        RotYChangeLimitMax = 5
    }
end

---记录初始位置
function UFOCatcherTouchCtrl:CameraInit()
    if self.initRotation == nil then
        self.initRotation = self.virtualCamera:GetEulerAngles()
    end
end

---@param pos Vector3
---@param deltaPos Vector3
---@param gesture X3Game.InputComponent.GestrueType
function UFOCatcherTouchCtrl:OnDrag(pos, deltaPos, gesture)
    if self.canControl then
        local curRotation = self.virtualCamera:GetEulerAngles()
        local needRotateX = self.parameter.RotateWeight * deltaPos.y
        local needRotateY = -self.parameter.RotateWeight * deltaPos.x
        if math.abs(needRotateX) > 0 or math.abs(needRotateY) > 0 then
            local targetRotation = Vector3.Temp(curRotation.x + needRotateX, curRotation.y + needRotateY, curRotation.z)
            targetRotation.x = math.max(targetRotation.x, self.initRotation.x + self.parameter.RotXChangeLimitMin)
            targetRotation.x = math.min(targetRotation.x, self.initRotation.x + self.parameter.RotXChangeLimitMax)
            targetRotation.y = math.max(targetRotation.y, self.initRotation.y + self.parameter.RotYChangeLimitMin)
            targetRotation.y = math.min(targetRotation.y, self.initRotation.y + self.parameter.RotYChangeLimitMax)
            self.virtualCamera:SetEulerAngles(targetRotation)
        end
    end
end

---开关自动同步
---@param autoSync boolean
function UFOCatcherTouchCtrl:SwitchAutoSync(autoSync)
    self.virtualCamera:GetMode().SyncMainCameraOnActivated = autoSync
    local transitionParams = self.virtualCamera._cineMachineVirtualCamera.m_Transitions
    transitionParams.m_InheritPosition = autoSync
    self.virtualCamera._cineMachineVirtualCamera.m_Transitions = transitionParams
end

---销毁
function UFOCatcherTouchCtrl:OnDestroy()
    if self.virtualCamera then
        GlobalCameraMgr.DestroyVirtualCamera(self.virtualCamera)
        self.virtualCamera = nil
    end
    self.super.OnDestroy(self)
end

return UFOCatcherTouchCtrl