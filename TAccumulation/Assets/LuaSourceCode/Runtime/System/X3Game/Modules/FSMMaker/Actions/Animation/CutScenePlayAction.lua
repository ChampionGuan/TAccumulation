--- X3@PapeGames
--- CutScenePlayAction
--- Created by dengzi
--- Created Date: 2023-11-22

---@class X3Game.CutScenePlayAction:FSM.FSMAction
---@field cutSceneName FSM.FSMVar | string 
---@field playMode FSM.FSMVar | int 
---@field wrapMode FSM.FSMVar | int 
---@field initialTime FSM.FSMVar | float 
---@field endTime FSM.FSMVar | float 
---@field autoPause FSM.FSMVar | boolean 
---@field parent FSM.FSMVar | UObject 
---@field tag FSM.FSMVar | int 
---@field playId FSM.FSMVar | int 
local CutScenePlayAction = class("CutScenePlayAction", FSMAction)

---初始化
function CutScenePlayAction:OnAwake()
    self.ctsEventCallback = handler(self, self.SignatureCallback)
end

---进入Action
function CutScenePlayAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    CutSceneMgr.RegisterEventCallback(self.ctsEventCallback)
    local playItem = CutSceneMgr.Play(self.cutSceneName:GetValue(), self.playMode:GetValue(), self.wrapMode:GetValue(),
            self.initialTime:GetValue(), self.endTime:GetValue(), self.autoPause:GetValue(), self.parent:GetValue(), self.tag:GetValue())
    if not playItem then
        self:Finish()
        return
    end
    self.playItem = playItem
    self.loop = self.wrapMode:GetValue() == DirectorWrapMode.Loop
    if self.playId then
        self.playId:SetValue(playItem.PlayId)
    end
end

---@param evtData PapeGames.CutScene.CutSceneEventData
function CutScenePlayAction:SignatureCallback(evtData)
    if not self.playItem then
        return
    end
    if evtData.PlayId == self.playItem.PlayId then
        if (evtData.EventType == CutSceneEventType.ReachEnd and not self.loop) or evtData.EventType == CutSceneEventType.Stop then
            self:Finish()
        end
    end
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function CutScenePlayAction:OnPause(isPaused)
    if isPaused then
        CutSceneMgr.Pause(self.playItem.PlayId)
    else
        CutSceneMgr.Resume(self.playItem.PlayId)
    end
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function CutScenePlayAction:OnUpdate()
end
--]]

---退出Action
function CutScenePlayAction:OnExit()
    CutSceneMgr.RegisterEventCallback(self.ctsEventCallback)
    if self.playItem then
        CutSceneMgr.Stop(self.playItem.PlayId)
        self.playItem = nil
    end
    self.playId:SetValue(0)
end

---被重置
function CutScenePlayAction:OnReset()

end

---被销毁
function CutScenePlayAction:OnDestroy()
    self.ctsEventCallback = nil
end

return CutScenePlayAction