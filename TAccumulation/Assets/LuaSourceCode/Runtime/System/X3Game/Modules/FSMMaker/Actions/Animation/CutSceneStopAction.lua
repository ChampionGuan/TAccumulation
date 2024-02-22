--- X3@PapeGames
--- CutSceneStopAction
--- Created by dengzi
--- Created Date: 2023-11-22

---@class X3Game.CutSceneStopAction:FSM.FSMAction
---@field stopWay FSM.FSMVar | int
---@field cutSceneName FSM.FSMVar | string
---@field playId FSM.FSMVar | int
---@field tag FSM.FSMVar | int
---@field destroyImmediate FSM.FSMVar | boolean
local CutSceneStopAction = class("CutSceneStopAction", FSMAction)

local StopWay = {
    StopByCtsName = 0,
    StopByPlayId = 1,
    StopByTag = 2,
    StopAll = 3,
}

---初始化
function CutSceneStopAction:OnAwake()
end

---进入Action
function CutSceneStopAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    local way = self.stopWay:GetValue()
    if way == StopWay.StopByCtsName then
        CutSceneMgr.Stop(self.cutSceneName:GetValue(), self.destroyImmediate:GetValue())
    elseif way == StopWay.StopByPlayId then
        CutSceneMgr.Stop(self.playId:GetValue(), self.destroyImmediate:GetValue())
    elseif way == StopWay.StopByTag then
        CutSceneMgr.StopWithTag(self.tag:GetValue(), self.destroyImmediate:GetValue())
    elseif way == StopWay.StopAll then
        CutSceneMgr.StopAll()
    end
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function CutSceneStopAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function CutSceneStopAction:OnUpdate()
end
--]]

---退出Action
function CutSceneStopAction:OnExit()
end

---被重置
function CutSceneStopAction:OnReset()
end

---被销毁
function CutSceneStopAction:OnDestroy()
end

return CutSceneStopAction