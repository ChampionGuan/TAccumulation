--- X3@PapeGames
--- ScreenTransitionAction
--- Created by doudou
--- Created Date: 2023-11-10

---@class X3Game.ScreenTransitionAction:FSM.FSMAction
---@field OperationType FSM.FSMVar | int 
---@field TransitionType FSM.FSMVar | int 
---@field SceneTransition FSM.FSMVar | boolean 
---@field Duration FSM.FSMVar | float 
local ScreenTransitionAction = class("ScreenTransitionAction", FSMAction)

---初始化
function ScreenTransitionAction:OnAwake()
end

---进入Action
function ScreenTransitionAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    local optType = self.OperationType:GetValue()
    local transitionType = self.TransitionType:GetValue()
    local isSceneTransition = self.SceneTransition:GetValue()
    local duration = self.Duration:GetValue()

    local onComplete = handler(self, self.Finish)
    if optType == 0 then
        if transitionType == 0 then
            if isSceneTransition then
                UICommonUtil.SceneBlackScreenIn(duration, onComplete)
            else
                UICommonUtil.BlackScreenIn(onComplete)
            end
        else
            if isSceneTransition then
                UICommonUtil.SceneWhiteScreenIn(duration, onComplete)
            else
                UICommonUtil.BlackScreenIn(onComplete)
            end
        end
    else
        if transitionType == 0 then
            if isSceneTransition then
                UICommonUtil.SceneBlackScreenOut(duration, onComplete)
            else
                UICommonUtil.BlackScreenOut(onComplete)
            end
        else
            if isSceneTransition then
                UICommonUtil.SceneWhiteScreenOut(duration, onComplete)
            else
                UICommonUtil.BlackScreenOut(onComplete)
            end
        end
    end
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function ScreenTransitionAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function ScreenTransitionAction:OnUpdate()
end
--]]

---退出Action
function ScreenTransitionAction:OnExit()
end

---被重置
function ScreenTransitionAction:OnReset()
end

---被销毁
function ScreenTransitionAction:OnDestroy()
end

return ScreenTransitionAction