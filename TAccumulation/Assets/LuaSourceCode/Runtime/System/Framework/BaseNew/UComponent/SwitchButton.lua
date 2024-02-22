﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/6/6 10:53
---
local Base = Framework.Parser.UComponentParser:GetComponent(UComponent.SetOrGetValue)
---按钮组件
---@class UComponent.SwitchButton:UComponent.SetOrGetValue
local SwitchButton = class("SwitchButton", Base)

---设置SwitchButton回调

---@param cb fun(type:GameObject,type:boolean)
function SwitchButton:SetListener(cb)
    local id = self:GetComponentID(self.UIEventType.SwitchButton)
    if cb ~= nil then
        self:_RegisterEventDelegate(id, self.UIEventType.SwitchButton, self.UIEventHandlerType.SwitchButton_OnValueChanged, cb)
    else
        self:_UnregisterEventDelegate(id, self.UIEventType.SwitchButton)
    end

end

---@return boolean
function SwitchButton:GetValue()
    local _, value = Base.GetValue(self)
    return value
end

return SwitchButton