--- X3@PapeGames
--- PlayUIMotionAction
--- Created by jianxin
--- Created Date: 2023-12-07

---@class X3Game.PlayUIMotionAction:FSM.FSMAction
---@field motionObj FSM.FSMVar | UObject MotionObj
---@field motionKey FSM.FSMVar | string MotionKey
---@field isWaitComplete FSM.FSMVar | boolean 是否等待播放完成
---@field isDestroyStop FSM.FSMVar | boolean FSM Destroy 是否停止
local PlayUIMotionAction = class("PlayUIMotionAction", FSMAction)

---进入Action
function PlayUIMotionAction:OnEnter()
    if self.motionObj:GetValue() == nil then
        self.context:LogErrorFormat("[PlayUIMotionAction] self.motionObj is nil")
        self:Finish()
        return
    end
    ---if need to complete action, call Finish()
    if self.isWaitComplete:GetValue() then
        UIUtil.PlayMotion(self.motionObj:GetValue(), self.motionKey:GetValue(), handler(self, self.Finish))
    else
        UIUtil.PlayMotion(self.motionObj:GetValue(), self.motionKey:GetValue())
        self:Finish()
    end
end

function PlayUIMotionAction:OnDestroy()
    if self.isDestroyStop:GetValue() then
        UIUtil.StopMotion(self.motionObj:GetValue(), self.motionKey:GetValue())
    end
end

return PlayUIMotionAction