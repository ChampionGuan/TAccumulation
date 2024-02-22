--- X3@PapeGames
--- CutSceneSendEventAction
--- Created by doudou
--- Created Date: 2023-10-30

---@class X3Game.CutSceneSendEventAction:FSM.FSMAction
---@field EventType FSM.FSMVar | string 
---@field WithParam FSM.FSMVar | boolean 
---@field Param FSM.FSMVar | string 
---@field Value FSM.FSMVar | table 
local CutSceneSendEventAction = class("CutSceneSendEventAction", FSMAction)

---初始化
function CutSceneSendEventAction:OnAwake()
end

---进入Action
function CutSceneSendEventAction:OnEnter()
    local eventType = self.EventType:GetValue()
    local withParam = self.WithParam:GetValue()
    local param = self.Param:GetValue()
    local value = self.Value:GetValue()
    if withParam then
        CutSceneMgr.SendEventWithParam(eventType, param, value)
    else
        CutSceneMgr.SendEvent(eventType, value)
    end
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function CutSceneSendEventAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function CutSceneSendEventAction:OnUpdate()
end
--]]

---退出Action
function CutSceneSendEventAction:OnExit()
end

---被重置
function CutSceneSendEventAction:OnReset()
end

---被销毁
function CutSceneSendEventAction:OnDestroy()
end

return CutSceneSendEventAction