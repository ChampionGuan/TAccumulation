--- X3@PapeGames
--- X3AnimatorStopAction
--- Created by doudou
--- Created Date: 2023-11-24

---@class X3Game.X3AnimatorStopAction:FSM.FSMAction
---@field Animator FSM.FSMVar | UObject 
---@field AutoComplete FSM.FSMVar | boolean 
local X3AnimatorStopAction = class("X3AnimatorStopAction", FSMAction)

---初始化
function X3AnimatorStopAction:OnAwake()
end

---进入Action
function X3AnimatorStopAction:OnEnter()
    ---@type X3Game.X3Animator
    local x3Animator = self.Animator:GetValue()
    if x3Animator then
        x3Animator:Stop(self.AutoComplete:GetValue())
    end
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function X3AnimatorStopAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function X3AnimatorStopAction:OnUpdate()
end
--]]

---退出Action
function X3AnimatorStopAction:OnExit()
end

---被重置
function X3AnimatorStopAction:OnReset()
end

---被销毁
function X3AnimatorStopAction:OnDestroy()
end

return X3AnimatorStopAction