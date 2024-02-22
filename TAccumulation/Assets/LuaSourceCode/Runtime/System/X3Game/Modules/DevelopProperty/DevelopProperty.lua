﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2022/3/19 11:05
---
---@class DevelopProperty
local DevelopProperty = class("DevelopProperty")

---@class PropertyType
---@field PROPERTY_MAXHP number 最大生命值
---@field PROPERTY_PHYATTACK number 攻击
---@field PROPERTY_PHYDEFENCE number 防御
---@field PROPERTY_CRITVAL number 暴击
---@field PROPERTY_CRITRATE number 暴击率
---@field PROPERTY_CRITHURTADD number 暴击伤害
---@field PROPERTY_ELEMENTRATIO number 元素适应系数
---@field PROPERTY_HURTADD number 伤害加深
---@field PROPERTY_HURTDEC number 伤害减免
---@field PROPERTY_CUREADD number 治疗效果增强
---@field PROPERTY_CUREDADD number 受到治疗效果增强
---@field PROPERTY_CDDEC number 冷却缩减
---@field PROPERTY_ATTACKSKILLADD number 普攻伤害增加
---@field PROPERTY_ACTIVESKILLADD number 主动技伤害增加
---@field PROPERTY_COMBOSKILLADD number 连携伤害增加
---@field PROPERTY_ULTRASKILLADD number 爆发伤害增加
---@field PROPERTY_RIGIDPOINT number 刚性值（刚性破坏>刚性值时，打断idle）
---@field PROPERTY_MOVESPEED number 移动速度
---@field PROPERTY_TURNSPEED number 转向速度
---@field PROPERTY_FINALDMGADDRATE number 最终伤害修正
---@field PROPERTY_MAXHPSCALE number 养成系统-最大生命值万分比
---@field PROPERTY_PHYATTACKSCALE number 养成系统-物理攻击万分比
---@field PROPERTY_PHYDEFENCESCALE number 养成系统-物理防御万分比
---@field PROPERTY_CRITVALSCALE number 养成系统-暴击值万分比

function DevelopProperty:ctor()
    ---@type table<number,DevelopPropertyBase>
    self.propertys = {}
    ---@type DevelopPropertyBase[]
    self.propertysList = {}
    ---@type DevelopPropertyBase[]
    self.partPropertyBaseList = {}
    ---@type DevelopPropertyBase[]
    self.otherPropertyList = {}
end

---SetProperty
---@param propertyType number
---@param propertyValue number
function DevelopProperty:SetProperty(propertyType, propertyValue)
    self:UpdateProperty(propertyType, propertyValue)
end

---SetNextProperty
---@param propertyType number
---@param propertyValue number
function DevelopProperty:SetNextProperty(propertyType, propertyValue)
    ---@type DevelopPropertyBase
    local propertyData = self.propertys[propertyType]
    if not propertyData then
        return
    end
    propertyData:SetNextPropertyValue(propertyValue)
    self.propertys[propertyType] = propertyData
end

---SetNextPropertys
---@param property DevelopProperty
function DevelopProperty:SetNextPropertys(property)
    if not property then
        return
    end
    local propertys = property.propertys
    for k, v in pairs(propertys) do
        self:SetNextProperty(k, v:GetPropertyValue())
    end
end

---ResetProperty
function DevelopProperty:ResetProperty()
    for i, v in pairs(self.propertys) do
        v:SetPropertyValue(0)
    end
end

---UpdateProperty
---@param propertyType number
---@param propertyValue number
function DevelopProperty:UpdateProperty(propertyType, propertyValue)
    local propertyData = self.propertys[propertyType]
    if not propertyData then
        propertyData = require("Runtime.System.X3Game.Modules.DevelopProperty.DevelopPropertyBase").new(propertyType)
    end
    propertyData:SetPropertyValue(propertyValue)
    self.propertys[propertyType] = propertyData
end

---GetProperty
---@param propertyType number
---@return number
function DevelopProperty:GetPropertyValue(propertyType)
    local propertyData = self.propertys[propertyType]
    return propertyData and propertyData:GetPropertyValue() or 0
end

---GetPropertys
---@return table<PropertyType,DevelopPropertyBase>
function DevelopProperty:GetPropertys()
    return self.propertys
end

---ClonePropertys
---@param isList boolean
---@return table<PropertyType,DevelopPropertyBase>
function DevelopProperty:ClonePropertys(isList,ignoreZeroProperty)
    if isList == nil then
        isList = false
    end
    if ignoreZeroProperty == nil then
        ignoreZeroProperty = false
    end
    local tab = {}
    for propertyType, v in pairs(self.propertys) do
        local propertyValue = self:GetPropertyValue(propertyType)
        if isList then
            if not ignoreZeroProperty or propertyValue > 0 then
                table.insert(tab, table.clone(v))
            end
        else
            if not ignoreZeroProperty or propertyValue > 0 then
                tab[propertyType] = table.clone(v)
            end
        end
    end
    return tab
end

---GetPropertys
---@param ignoreZeroProperty boolean 是否忽略value=0
---@return DevelopPropertyBase[]
function DevelopProperty:GetPropertysList(ignoreZeroProperty)
    if ignoreZeroProperty == nil then
        ignoreZeroProperty = false
    end
    table.clear(self.propertysList)
    for propertyType, v in pairs(self.propertys) do
        local propertyValue = self:GetPropertyValue(propertyType)
        if not ignoreZeroProperty or propertyValue > 0 then
            table.insert(self.propertysList, v)
        end
    end
    return self.propertysList
end

---@param ignoreZeroProperty boolean 是否忽略value=0
---@return DevelopPropertyBase[]
function DevelopProperty:GetBasePropertyList(ignoreZeroProperty)
    local propertys = self:GetPropertyBaseListByTypes(ignoreZeroProperty, X3_CFG_CONST.PROPERTY_MAXHP,
            X3_CFG_CONST.PROPERTY_PHYATTACK,
            X3_CFG_CONST.PROPERTY_PHYDEFENCE,
            X3_CFG_CONST.PROPERTY_CRITVAL)
    return propertys
end

---@param ignoreZeroProperty boolean 是否忽略value=0
---@return DevelopPropertyBase[]
function DevelopProperty:GetDetailPropertyList(ignoreZeroProperty)
    local propertys = self:GetPropertyBaseListByTypes(ignoreZeroProperty, X3_CFG_CONST.PROPERTY_MAXHP,
            X3_CFG_CONST.PROPERTY_PHYATTACK,
            X3_CFG_CONST.PROPERTY_PHYDEFENCE,
            X3_CFG_CONST.PROPERTY_CRITVAL,
            X3_CFG_CONST.PROPERTY_CRITHURTADD)
    return propertys
end

---获取除基础属性外的其他属性
---@param ignoreZeroProperty boolean 是否忽略value=0
---@return DevelopPropertyBase[]
function DevelopProperty:GetOtherPropertyList(ignoreZeroProperty)
    local basePropertyTypes = { X3_CFG_CONST.PROPERTY_MAXHP,
                                X3_CFG_CONST.PROPERTY_PHYATTACK,
                                X3_CFG_CONST.PROPERTY_PHYDEFENCE,
                                X3_CFG_CONST.PROPERTY_CRITVAL }
    table.clear(self.otherPropertyList)
    if ignoreZeroProperty == nil then
        ignoreZeroProperty = false
    end
    for propertyType, v in pairs(self.propertys) do
        if not table.containsvalue(basePropertyTypes, propertyType) then
            local propertyValue = self:GetPropertyValue(propertyType)
            if not ignoreZeroProperty or propertyValue > 0 then
                table.insert(self.otherPropertyList, v)
            end
        end
    end
    return self.otherPropertyList
end

---@return DevelopPropertyBase[]
function DevelopProperty:GetPropertyBaseListByTypes(ignoreZeroProperty, ...)
    table.clear(self.partPropertyBaseList)
    local propertyTypes = { ... }
    if ignoreZeroProperty == nil then
        ignoreZeroProperty = false
    end
    for i = 1, #propertyTypes do
        ---因为有些的属性没有,所以这里重新更新一下
        local propertyType = propertyTypes[i]
        local propertyValue = self:GetPropertyValue(propertyType)
        if not ignoreZeroProperty or propertyValue > 0 then
            self:UpdateProperty(propertyType, propertyValue)
            table.insert(self.partPropertyBaseList, self.propertys[propertyType])
        end
    end
    return self.partPropertyBaseList
end

---HasProperty
---@param propertyType number
function DevelopProperty:HasProperty(propertyType)
    local propertyData = self.propertys[propertyType]
    return propertyData and true or false
end

---AddProperty
---@param propertyType number
---@param propertyValue number
function DevelopProperty:AddProperty(propertyType, propertyValue)
    propertyValue = propertyValue and propertyValue or 0
    local value = self:GetPropertyValue(propertyType)
    value = value + propertyValue
    self:UpdateProperty(propertyType, value)
end

---GetPropertyValueWithPercent
---@param percentType number
---@param percent number
function DevelopProperty:GetPropertyValueWithPercent(percentType, percent, isFloor)
    percent = percent and percent or 0
    if isFloor == nil then
        isFloor = false
    end
    local isPercentType, propertyType = self:TryGetPropertyTypeByPercentType(percentType)
    local value = self:GetPropertyValue(propertyType)
    if isPercentType then
        ---如是是基础属性加成,这里需要乘以基础属性
        value = value * (percent / 1000)
        if isFloor then
            value = math.floor(value)
        end
        return propertyType, value
    else
        ---如果不是加成,直接返回一开始的属性值
        if isFloor then
            percent = math.floor(percent)
        end
        return propertyType, percent
    end
end

function DevelopProperty:TryGetPropertyTypeByPercentType(percentType)
    if percentType == X3_CFG_CONST.PROPERTY_MAXHPSCALE then
        return true, X3_CFG_CONST.PROPERTY_MAXHP
    end
    if percentType == X3_CFG_CONST.PROPERTY_PHYATTACKSCALE then
        return true, X3_CFG_CONST.PROPERTY_PHYATTACK
    end
    if percentType == X3_CFG_CONST.PROPERTY_PHYDEFENCESCALE then
        return true, X3_CFG_CONST.PROPERTY_PHYDEFENCE
    end
    return false, percentType
end

---AddPropertys
---@param property DevelopProperty
function DevelopProperty:AddPropertys(property)
    if not property then
        return
    end
    local propertys = property.propertys
    for k, v in pairs(propertys) do
        self:AddProperty(k, v:GetPropertyValue())
    end
end

---SubProperty
---@param propertyType number
---@param propertyValue number
function DevelopProperty:SubProperty(propertyType, propertyValue)
    local value = self:GetProperty(propertyType)
    value = value - propertyValue
    self:UpdateProperty(propertyValue, value)
end

---MulProperty
---@param propertyType number
---@param propertyValue number
function DevelopProperty:MulProperty(propertyType, propertyValue)
    local value = self:GetProperty(propertyType)
    value = value * propertyValue
    self:UpdateProperty(propertyValue, value)
end

---向下取整属性值
function DevelopProperty:FloorProperty()
    for k, v in pairs(self.propertys) do
        local tempPropertyValue = math.floor(v:GetPropertyValue())
        v:SetPropertyValue(tempPropertyValue)
    end
end

---@return table<int,int>
function DevelopProperty:GetPropertyMap()
    local result = {}
    for type, propertyBase in pairs(self.propertys) do
        result[type] = propertyBase:GetPropertyValue()
    end
    return result
end

---使用PropertyMap初始化
---@param propertyMap table<int,int>
function DevelopProperty:InitByPropertyMap(propertyMap)
    self:ClearProperties()
    for type, value in pairs(propertyMap) do
        self:AddProperty(type, value)
    end
end

function DevelopProperty:ClearProperties()
    table.clear(self.propertys)
end

return DevelopProperty