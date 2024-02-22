--- X3@PapeGames
--- SwitchGlobalTouch
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.SwitchGlobalTouch:FSM.FSMAction
---@field isEnable FSM.FSMVar | boolean 是否开启
---@field lockType FSM.FSMVar | int 控制类型
local SwitchGlobalTouch = class("SwitchGlobalTouch", FSMAction)

---进入Action
function SwitchGlobalTouch:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    GameHelper.SetGlobalTouchEnable(self.isEnable:GetValue(), self.lockType:GetValue())
    self:Finish()
end

---被销毁
---需要重置操作
function SwitchGlobalTouch:OnDestroy()
    GameHelper.SetGlobalTouchEnable(true, self.lockType:GetValue())
end

return SwitchGlobalTouch