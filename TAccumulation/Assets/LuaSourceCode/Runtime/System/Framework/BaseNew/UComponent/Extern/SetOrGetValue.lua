﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/6/13 12:40
---
---SetOrGetValue类型组件,UIBaseEnum,Dropdown,TabMenu,Slider,Image,ToggleButtonGroup,NumericText
---@class UComponent.SetOrGetValue:UComponent.BaseComponent
local SetOrGetValue = class("SetOrGetValue", Framework.BaseComponent)

---@return int,boolean,float,string
function SetOrGetValue:GetValue()
    return self:_InvokeFunc("GetValue")
end

---@return float
function SetOrGetValue:GetBoolValue()
    local _, b = self:GetValue()
    return b
end

---@return string
function SetOrGetValue:GetStringValue()
    local _, _, _, s = self:GetValue()
    return s
end

---@return float
function SetOrGetValue:GetFloatValue()
    local _, _, f = self:GetValue()
    return f
end

---@param value int | boolean | float | string
function SetOrGetValue:SetValue(value)
    self:_InvokeFunc("SetValue", value, true)
end

---@param value int | boolean | float | string
function SetOrGetValue:SetValueWithoutNotify(value)
    self:_InvokeFunc("SetValue", value, false)
end

return SetOrGetValue