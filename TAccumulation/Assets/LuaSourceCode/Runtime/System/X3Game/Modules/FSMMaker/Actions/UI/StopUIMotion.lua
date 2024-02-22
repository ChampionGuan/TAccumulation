--- X3@PapeGames
--- StopUIMotionAction
--- Created by jianxin
--- Created Date: 2023-12-07

---@class X3Game.StopUIMotionAction:FSM.FSMAction
---@field motionObj FSM.FSMVar | UObject MotionObj
---@field motionKey FSM.FSMVar | string MotionKey
local StopUIMotionAction = class("StopUIMotionAction", FSMAction)

---进入Action
function StopUIMotionAction:OnEnter()
    if self.motionObj:GetValue() == nil then
        self.context:LogErrorFormat("[StopUIMotionAction] self.motionObj is nil")
        self:Finish()
        return
    end
    ---if need to complete action, call Finish()
    UIUtil.StopMotion(self.motionObj:GetValue(), self.motionKey:GetValue())
    self:Finish()
end

return StopUIMotionAction