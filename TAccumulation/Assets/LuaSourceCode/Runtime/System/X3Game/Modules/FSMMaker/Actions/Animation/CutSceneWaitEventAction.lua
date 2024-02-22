--- X3@PapeGames
--- CutSceneWaitEventAction
--- Created by doudou
--- Created Date: 2023-10-31

---@class X3Game.CutSceneWaitEventAction:FSM.FSMAction
---@field EventType FSM.FSMVar | int 
---@field SendEvent FSM.FSMVar | boolean
---@field EventName FSM.FSMVar | string
local CutSceneWaitEventAction = class("CutSceneWaitEventAction", FSMAction)
local CS_CutSceneEventType = CS.PapeGames.CutScene.CutSceneEventType

---初始化
function CutSceneWaitEventAction:OnAwake()
    self.signatureCallback = handler(self, self.SignatureCallback)
end

---进入Action
function CutSceneWaitEventAction:OnEnter()
    CutSceneMgr.RegisterEventCallback(self.signatureCallback)
end

function CutSceneWaitEventAction:SignatureCallback(evtData)
    if evtData.EventType == CS_CutSceneEventType.__CastFrom(self.EventType:GetValue()) then
        if self.SendEvent:GetValue() and self.EventName and not string.isnilorempty(self.EventName:GetValue()) then
            self.fsm:FireEvent(self.EventName:GetValue())
        end
        self:Finish()
    end
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function CutSceneWaitEventAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function CutSceneWaitEventAction:OnUpdate()
end
--]]

---退出Action
function CutSceneWaitEventAction:OnExit()
    CutSceneMgr.UnregisterEventCallback(self.signatureCallback)
end

---被重置
function CutSceneWaitEventAction:OnReset()
end

---被销毁
function CutSceneWaitEventAction:OnDestroy()
    self.signatureCallback = nil
end

return CutSceneWaitEventAction