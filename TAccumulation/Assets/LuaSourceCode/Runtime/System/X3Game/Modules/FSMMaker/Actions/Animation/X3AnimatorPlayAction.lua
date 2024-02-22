--- X3@PapeGames
--- X3AnimatorPlayAction
--- Created by doudou
--- Created Date: 2023-10-30

---@class X3Game.X3AnimatorPlayAction:FSM.FSMAction
---@field Animator FSM.FSMVar | UObject 
---@field StateName FSM.FSMVar | string 
---@field CrossFade FSM.FSMVar | boolean
---@field CustomPlaySetting FSM.FSMVar | boolean
---@field WrapMode FSM.FSMVar | int
---@field TransitionDuration FSM.FSMVar | float 
---@field InitialTime FSM.FSMVar | float 
local X3AnimatorPlayAction = class("X3AnimatorPlayAction", FSMAction)
local CS_DirectorWrapMode = CS.UnityEngine.Playables.DirectorWrapMode
---初始化
function X3AnimatorPlayAction:OnAwake()
end

---进入Action
function X3AnimatorPlayAction:OnEnter()
    ---@type X3Game.X3Animator
    local x3Animator = self.Animator:GetValue()
    if x3Animator then
        local stateName = self.StateName:GetValue()
        local isCrossFade = self.CrossFade:GetValue()
        local wrapMode = CS_DirectorWrapMode.__CastFrom(self.WrapMode:GetValue())
        local initialTime = self.InitialTime:GetValue()
        local transitionDuration = self.TransitionDuration:GetValue()
        if self.CustomPlaySetting:GetValue() then
            if isCrossFade then
                x3Animator:Crossfade(stateName, initialTime, transitionDuration, wrapMode)
            else
                x3Animator:Play(stateName, initialTime, wrapMode)
            end
        else
            if isCrossFade then
                x3Animator:Crossfade(stateName)
            else
                x3Animator:Play(stateName)
            end
        end
    else
        self.context:LogError("No X3Animator")
    end
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function X3AnimatorPlayAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function X3AnimatorPlayAction:OnUpdate()
end
--]]

---退出Action
function X3AnimatorPlayAction:OnExit()
end

---被重置
function X3AnimatorPlayAction:OnReset()
end

---被销毁
function X3AnimatorPlayAction:OnDestroy()
end

return X3AnimatorPlayAction