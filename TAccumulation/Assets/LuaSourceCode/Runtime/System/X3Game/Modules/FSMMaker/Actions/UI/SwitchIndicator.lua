--- X3@PapeGames
--- SwitchIndicator
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.SwitchIndicator:FSM.FSMAction
---@field isEnable FSM.FSMVar | boolean 是否开启
---@field indicatorType FSM.FSMVar | int Indicator类型
---@field textId FSM.FSMVar | int 文本ID
---@field textStr FSM.FSMVar | int 文本内容
---@field showType FSM.FSMVar | int 显示类型
---@field isBlur FSM.FSMVar | boolean 是否开启模糊
---@field isMask FSM.FSMVar | boolean 是否开启半透黑
local SwitchIndicator = class("SwitchIndicator", FSMAction)

---进入Action
function SwitchIndicator:OnEnter()
    if self.isEnable:GetValue() then
        local text = self.textId:GetValue()==0 and self.textStr:GetValue() or self.textId:GetValue()
        UICommonUtil.SetIndicatorEnable(self.indicatorType:GetValue(),true,text,self.showType:GetValue(),self.isBlur:GetValue(),self.isMask:GetValue())
    else
        UICommonUtil.SetIndicatorEnable(self.indicatorType:GetValue(),false)
    end
    self:Finish()
end

---被销毁
function SwitchIndicator:OnDestroy()
    UICommonUtil.SetIndicatorEnable(self.indicatorType:GetValue(),false)
end

return SwitchIndicator