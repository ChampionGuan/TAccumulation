--- X3@PapeGames
--- X3AnimatorPauseOrResumeAction
--- Created by doudou
--- Created Date: 2023-11-24

---@class X3Game.X3AnimatorPauseOrResumeAction:FSM.FSMAction
---@field Animator FSM.FSMVar | UObject
---@field OperationType FSM.FSMVar | int
local X3AnimatorPauseOrResumeAction = class("X3AnimatorPauseOrResumeAction", FSMAction)

---初始化
function X3AnimatorPauseOrResumeAction:OnAwake()
end

---进入Action
function X3AnimatorPauseOrResumeAction:OnEnter()
    ---@type X3Game.X3Animator
    local x3Animator = self.Animator:GetValue()
    if x3Animator then
        if self.OperationType:GetValue() == 0 then
            x3Animator:Pause()
        else
            x3Animator:Resume()
        end
    end
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function X3AnimatorPauseOrResumeAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function X3AnimatorPauseOrResumeAction:OnUpdate()
end
--]]

---退出Action
function X3AnimatorPauseOrResumeAction:OnExit()
end

---被重置
function X3AnimatorPauseOrResumeAction:OnReset()
end

---被销毁
function X3AnimatorPauseOrResumeAction:OnDestroy()
end

return X3AnimatorPauseOrResumeAction