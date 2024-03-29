﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/6/6 11:11
---
---长按组件
---@class UComponent.LongPressHandler:UComponent.MultiListener
local LongPressHandler = class("LongPressHandler", Framework.Parser.UComponentParser:GetComponent(UComponent.MultiListener))

---@param cb fun(type:GameObject,type:number)
function LongPressHandler:SetListener(cb)
    local id = self:GetComponentID(key_or_path, self.UIEventType.LongPressHandler)
    if cb ~= nil then
        self:_RegisterEventDelegate(id, self.UIEventType.LongPressHandler, self.UIEventHandlerType.LongPressHandler_OnLongPress, cb)
    else
        self:_UnregisterEventDelegate(id, self.UIEventType.LongPressHandler)
    end

end

return LongPressHandler