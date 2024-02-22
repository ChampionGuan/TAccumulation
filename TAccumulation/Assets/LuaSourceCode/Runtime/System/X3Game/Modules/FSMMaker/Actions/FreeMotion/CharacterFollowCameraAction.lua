--- X3@PapeGames
--- CharacterFollowCameraAction
--- Created by doudou
--- Created Date: 2023-11-01

---@class X3Game.CharacterFollowCameraAction:FSM.FSMAction
---@field Character FSM.FSMVar | UObject 
---@field CameraPath FSM.FSMVar | string 
---@field TargetBones FSM.FSMVarArray | string[] 
local CharacterFollowCameraAction = class("CharacterFollowCameraAction", FSMAction)

---初始化
function CharacterFollowCameraAction:OnAwake()
    self.camera = nil
end

---进入Action
function CharacterFollowCameraAction:OnEnter()
    local character = self.Character:GetValue()
    local cameraPath = self.CameraPath:GetValue()
    if character then
        self.camera = CS.PapeGames.X3.Res.LoadGameObject(cameraPath)
        self.camera.transform.position = self.camera.transform.localPosition
        self.camera.transform.rotation = self.camera.transform.localRotation
        self.camera.transform.parent = GlobalCameraMgr.GetRoot().transform

        local targets = {}
        for i = 1, self.TargetBones:GetLength() do
            table.insert(targets, CharacterMgr.GetBoneByName(character, self.TargetBones:GetElement(i)))
        end

        local cameraCtrl = self.camera:GetComponent(typeof(CS.X3Game.CharacterInteractionCamera))
        cameraCtrl.targets = targets
    end
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function CharacterFollowCameraAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function CharacterFollowCameraAction:OnUpdate()
end
--]]

---退出Action
function CharacterFollowCameraAction:OnExit()
    GameObjectUtil.Destroy(self.camera)
    self.camera = nil
end

---被重置
function CharacterFollowCameraAction:OnReset()
end

---被销毁
function CharacterFollowCameraAction:OnDestroy()
end

return CharacterFollowCameraAction