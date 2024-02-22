--- X3@PapeGames
--- TickleWaitAction
--- Created by doudou
--- Created Date: 2023-11-16

---@class X3Game.TickleWaitAction:FSM.FSMAction
---@field IsCrazyHit FSM.FSMVar | table
---@field CoolTime FSM.FSMVar | float
local TickleWaitAction = class("TickleWaitAction", FSMAction)

---初始化
function TickleWaitAction:OnAwake()
end

---进入Action
function TickleWaitAction:OnEnter()
    self.isCrazy = self.IsCrazyHit:GetValue()
    self.crazyTime = TimerMgr.GetRealTimeSeconds()
    ---if need to complete action, call Finish()
    ---self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function TickleWaitAction:OnPause(isPaused)
end

---Tick
function TickleWaitAction:OnUpdate()
    if self.isCrazy and self.crazyTime then
        local curTime = TimerMgr.GetRealTimeSeconds()
        if curTime - self.crazyTime > self.CoolTime:GetValue() then -- 当进入 Crazy 模式后 0.5s 没有点击，自动退出疯狂模式
            self.isCrazy = false
            self.crazyTime = nil
            CutSceneMgr.SendEventWithParam("Click", "IsCrazyHit", self.isCrazy)
            CutSceneMgr.SendEventWithParam("Click", "IsHit", false)
        end
    end
end

---退出Action
function TickleWaitAction:OnExit()
end

---被重置
function TickleWaitAction:OnReset()
end

---被销毁
function TickleWaitAction:OnDestroy()
end

return TickleWaitAction