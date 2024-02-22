--- X3@PapeGames
--- X3AnimatorAddStateAction
--- Created by doudou
--- Created Date: 2023-10-30

---@class X3Game.X3AnimatorAddStateAction:FSM.FSMAction
---@field Animator FSM.FSMVar | UObject 
---@field StateName FSM.FSMVar | string
---@field CtsName FSM.FSMVar | string 
---@field WrapMode FSM.FSMVar | int 
---@field ExitTime FSM.FSMVar | float 
---@field TransitionDuration FSM.FSMVar | float 
---@field InheritTransform FSM.FSMVar | boolean 
local X3AnimatorAddStateAction = class("X3AnimatorAddStateAction", FSMAction)
local CS_DirectorWrapMode = CS.UnityEngine.Playables.DirectorWrapMode

---初始化
function X3AnimatorAddStateAction:OnAwake()
end

---进入Action
function X3AnimatorAddStateAction:OnEnter()
    ---@type X3Game.X3Animator
    local x3Animator = self.Animator:GetValue()
    if x3Animator then
        local stateName = self.StateName:GetValue()
        local wrapMode = CS_DirectorWrapMode.__CastFrom(self.WrapMode:GetValue())
        local transitionDuration = self.TransitionDuration:GetValue()
        local inheritTransform = self.InheritTransform:GetValue()
        x3Animator:AddState(stateName, self.CtsName:GetValue(), inheritTransform, wrapMode, transitionDuration)
    else
        self.context:LogError("No X3Animator")
    end
    self:Finish()
end
---暂停或恢复，true==暂停
---@param isPaused boolean
function X3AnimatorAddStateAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function X3AnimatorAddStateAction:OnUpdate()
end
--]]

---退出Action
function X3AnimatorAddStateAction:OnExit()
end

---被重置
function X3AnimatorAddStateAction:OnReset()
end

---被销毁
function X3AnimatorAddStateAction:OnDestroy()
end

return X3AnimatorAddStateAction