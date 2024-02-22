--- X3@PapeGames
--- ShowMessageBox
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.ShowMessageBox:FSM.FSMAction
---@field isBlock FSM.FSMVar | boolean 是否阻断后续流程
---@field textId FSM.FSMVar | int 文本Id
---@field textStr FSM.FSMVar | string 文本内容
---@field okTextId FSM.FSMVar | int 确定按钮文本Id
---@field cancelTextId FSM.FSMVar | int 取消按钮文本Id
---@field okEvent FSM.FSMVar | string 点击确定之后触发的事件
---@field cancelEvent FSM.FSMVar | string 点击取消之后触发的事件
---@field isAutoClose FSM.FSMVar | boolean 是否允许点击空白关闭
---@field btnType FSM.FSMVar | int 点击空白之后触发的类型
local ShowMessageBox = class("ShowMessageBox", FSMAction)

---进入Action
function ShowMessageBox:OnEnter()
    local btnList = self.context:GetTable()
    ---@type _btn_param
    local okBtnParam = self.context:GetTable()
    okBtnParam.btn_text = self.okTextId:GetValue()
    okBtnParam.btn_type = GameConst.MessageBoxBtnType.CONFIRM
    okBtnParam.btn_call = handler(self, self.OnBtnOk)

    ---@type _btn_param
    local cancelBtnParam = self.context:GetTable()
    cancelBtnParam.btn_text = self.cancelTextId:GetValue()
    cancelBtnParam.btn_type = GameConst.MessageBoxBtnType.CANCEL
    cancelBtnParam.btn_call = handler(self, self.OnBtnCancel)

    table.insert(btnList, okBtnParam)
    table.insert(btnList, cancelBtnParam)

    local content = self.textId:GetValue() > 0 and self.textId:GetValue() or self.textStr:GetValue()
    UICommonUtil.ShowMessageBox(content, btnList, self.isAutoClose:GetValue() == true and AutoCloseMode.AutoClose or AutoCloseMode.None, self.btnType:GetValue())
    if self.isBlock:GetValue() == false then
        self:Finish()
    end
end

function ShowMessageBox:OnBtnOk()
    self.context:FireEvent(self.okEvent:GetValue(), true, true)
    if self.isBlock:GetValue() == true then
        self:Finish()
    end
end

function ShowMessageBox:OnBtnCancel()
    self.context:FireEvent(self.cancelEvent:GetValue(), true, true)
    if self.isBlock:GetValue() == true then
        self:Finish()
    end
end

return ShowMessageBox