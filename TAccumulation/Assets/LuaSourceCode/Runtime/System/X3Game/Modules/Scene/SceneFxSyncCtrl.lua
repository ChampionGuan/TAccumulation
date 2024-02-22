﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/10/30 16:34
---

local SceneFxSyncCtrl = class("SceneFxSyncCtrl", GameObjectCtrl)

---初始化函数，保证SceneFx和相机保持x、y轴同步
function SceneFxSyncCtrl:Init()
    TimerMgr.AddFinalUpdate(self.FinalUpdate, self)
    GameObjectUtil.SetParent(self.gameObject, GlobalCameraMgr.GetUnityMainCamera(), true)
    local _, _, cameraPosZ = GameObjectUtil.GetPositionXYZ(GlobalCameraMgr.GetUnityMainCamera())
    local _, _, posZ = self:GetPositionXYZ(self.gameObject)
    self.deltaPosZ = posZ - cameraPosZ
end

---
function SceneFxSyncCtrl:FinalUpdate()
    local _, _, cameraPosZ = GameObjectUtil.GetPositionXYZ(GlobalCameraMgr.GetUnityMainCamera())
    local posX, posY = self:GetPositionXYZ(self.gameObject)
    self:SetPosition(self.gameObject, posX, posY, cameraPosZ + self.deltaPosZ)
end

---销毁函数
function SceneFxSyncCtrl:OnDestroy()
    TimerMgr.RemoveFinalUpdateByTarget(self)
    self.super.OnDestroy(self)
end

return SceneFxSyncCtrl