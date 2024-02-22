--- X3@PapeGames
--- SwitchLoading
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.SwitchLoading:FSM.FSMAction
---@field isEnable FSM.FSMVar | boolean 是否开启
---@field loadingType FSM.FSMVar | int loading类型
---@field isMoveIn FSM.FSMVar | boolean 是否播放moveIn
---@field isMoveOut FSM.FSMVar | boolean 是否播放moveOut
---@field moveInEvent FSM.FSMVar | string moveIn结束之后事件
---@field moveOutEvent FSM.FSMVar | string moveOut结束之后事件
local SwitchLoading = class("SwitchLoading", FSMAction)

---进入Action
function SwitchLoading:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    if self.isEnable:GetValue() == true then
        if self.isMoveIn:GetValue() == true or self.isMoveOut:GetValue() == true then
            ---@type _ViewInfo
            local openParam = self.context:GetTable()
            openParam.IsPlayMoveIn = self.isMoveIn:GetValue()
            openParam.IsPlayMoveOut = self.isMoveOut:GetValue()
            openParam.MoveInCallBack = handler(self, self.OnMoveInComplete)
            openParam.MoveOutCallBack = handler(self, self.OnMoveOutComplete)
            UICommonUtil.SetLoadingEnableWithOpenParam()
        else
            UICommonUtil.SetLoadingEnable(self.loadingType:GetValue(), self.isEnable:GetValue())
        end
    else
        UICommonUtil.SetLoadingEnable(self.loadingType:GetValue(), self.isEnable:GetValue())
    end
    self:Finish()
end

function SwitchLoading:OnMoveInComplete()
    self.context:FireEvent(self.moveInEvent:GetValue(), true, true)
end

function SwitchLoading:OnMoveOutComplete()
    self.context:FireEvent(self.moveOutEvent:GetValue(), true, true)
end

return SwitchLoading