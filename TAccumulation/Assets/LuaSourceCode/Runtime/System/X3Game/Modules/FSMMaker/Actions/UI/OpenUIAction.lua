---
--- Created by kaikai.
--- DateTime: 2023/9/27
--- 打开UI

---@class X3Game.OpenUIAction:FSM.FSMAction
---@field ViewTag FSM.FSMVar | string
---@field UseCustomSettings FSM.FSMVar | boolean
---@field PanelType FSM.FSMVar | int
---@field PanelOrder FSM.FSMVar | int
---@field AutoCloseMode FSM.FSMVar | int
---@field IsFullScreen FSM.FSMVar | boolean
---@field IsFocusable FSM.FSMVar | boolean
---@field MaskVisible FSM.FSMVar | boolean
---@field BlurType FSM.FSMVar | int
---@field WithAnim FSM.FSMVar | boolean
local OpenUIAction = class("OpenUIAction", FSMAction)

function OpenUIAction:OnEnter()
    if self.UseCustomSettings:GetValue() then
        UIMgr.OpenAs(self.ViewTag:GetValue(), self.PanelType:GetValue(), self.PanelOrder:GetValue(), self.AutoCloseMode:GetValue(), self.MaskVisible:GetValue(), self.IsFullScreen:GetValue(), self.IsFullScreen:GetValue(), self.IsFocusable:GetValue(), self.BlurType:GetValue(), self.WithAnim:GetValue())
    else
        UIMgr.OpenWithAnim(self.ViewTag:GetValue(), self.WithAnim:GetValue())
    end
    self:Finish()
end

return OpenUIAction