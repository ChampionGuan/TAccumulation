--- X3@PapeGames
--- SwitchMultiTouch
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.SwitchMultiTouch:FSM.FSMAction
---@field isEnable FSM.FSMVar | boolean 是否开启
---@field lockType FSM.FSMVar | int 控制类型
local SwitchMultiTouch = class("SwitchMultiTouch", FSMAction)

---进入Action
function SwitchMultiTouch:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    GameHelper.SetMultiTouchEnable(self.isEnable:GetValue(), self.lockType:GetValue())
    self:Finish()
end

---被销毁
function SwitchMultiTouch:OnDestroy()
    GameHelper.SetMultiTouchEnable(true, self.lockType:GetValue())
end

return SwitchMultiTouch