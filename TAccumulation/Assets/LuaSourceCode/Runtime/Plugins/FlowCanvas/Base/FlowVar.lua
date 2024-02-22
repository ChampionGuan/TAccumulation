﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/2/11 16:28
---@class FlowVar
---@field private name string 变量名称
---@field private value any 变量值
---@private bool isList 是否是数组
local FlowVar = class("FlowVar")

---@param value any
function FlowVar:SetValue(value)
    self.value = value
end

---@return any
function FlowVar:GetValue()
    return self.value
end

---@return string
function FlowVar:GetName()
    return self.name
end

---@param name string
function FlowVar:SetName(name)
    self.name = name
end

---@param flowArg X3Game.FlowArg
function FlowVar:Parse(flowArg)
    self.isList = flowArg:IsList()
    self:SetName(flowArg.Name)
    local pre = self.value
    local cur = flowArg.Value
    if self:IsList() then
        pre = pre or PoolUtil.GetTable()
        table.clear(pre)
        if cur~=nil then
            for k = 0,cur.Count-1 do
                table.insert(pre,cur[k])
            end
            cur = pre
        end
    end
    self:SetValue(cur)
end

---@private
---@return boolean
function FlowVar:IsList()
    return self.isList
end

function FlowVar:Clear()
    self.value = nil
    self.name = nil
end

return FlowVar