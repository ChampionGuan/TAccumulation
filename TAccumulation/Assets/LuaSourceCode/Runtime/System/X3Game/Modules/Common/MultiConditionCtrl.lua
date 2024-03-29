﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/9/18 17:17
---
---多条件控制，默认是栈（后进先出），可以通过SetIsQueue设置成队列（先进先出）
---@class MultiConditionCtrl
local MultiConditionCtrl = class("MultiConditionCtrl", nil, nil, true)

function MultiConditionCtrl:ctor()
    self:Init()
end


---设置running
---@param condition_type number 如果是nil或者是false，将清理当前所有条件
---@param is_running boolean 是否在running
---@vararg any
function MultiConditionCtrl:SetIsRunning(condition_type,is_running,...)
    if not condition_type then
        self:Clear()
        return
    end
    if is_running then
        self:_GetCondition(condition_type,true)
    end
    self:_SetIsRunning(condition_type,is_running,...)
end

---某个条件是否正在进行
---@param condition_type any
---@return boolean
function MultiConditionCtrl:IsRunning(condition_type)
    local condition
    if condition_type ~=nil then
        condition = self:_GetCondition(condition_type)
    else
        condition = self:GetTop()
    end
    return (condition and condition.is_running) or false
end

---获取当前条件的参数
---@param condition_type any
---@return any
function MultiConditionCtrl:GetParam(condition_type)
    local condition
    if condition_type then
        condition = self:_GetCondition(condition_type)
    end
    condition = condition or self:GetTop()
    if condition then
        return condition.param
    end
    return nil
end

---@return any
function MultiConditionCtrl:GetRunningType()
    local condition  = self:GetTop()
    return condition and condition.type or nil
end

function MultiConditionCtrl:GetTop()
    return #self.condition_list >0 and self.condition_list[#self.condition_list] or nil
end

---设置成队列
---@param is_queue boolean
function MultiConditionCtrl:SetIsQueue(is_queue)
    self.is_queue = is_queue
end

---@return boolean
function MultiConditionCtrl:IsQueue()
    return self.is_queue
end

function MultiConditionCtrl:Init()
    self.condition_list = {}
end


---获取condition
---@param condition_type string | number
---@param is_create boolean
---@return table
function MultiConditionCtrl:_GetCondition(condition_type,is_create)
    if  not condition_type then
        return nil
    end
    local condition
    for k, v in pairs(self.condition_list) do
        if v.type == condition_type then
            condition = v
            break
        end
    end
    if not condition and is_create then
        return self:_Add(condition_type)
    end
    return condition
end

---@param condition_type string | number
---@param is_running boolean
---@vararg any
function MultiConditionCtrl:_SetIsRunning(condition_type,is_running,...)
    local condition = self:_GetCondition(condition_type)
    if condition then
        if is_running then
            condition.is_running = is_running
            local count = select("#",...)
            if count >0 then
                condition.param = table.pack(...)
                if #condition.param == 0 then
                    condition.param = nil
                end
            else
                condition.param = nil
            end
            if condition~=self:GetTop() then
                self:_SetTop(condition_type)
            end
        else
            self:_Remove(condition_type)
        end
    end
end

function MultiConditionCtrl:Clear()
    for k,v in pairs(self.condition_list) do
        PoolUtil.ReleaseTable(v)
    end
    table.clear(self.condition_list)
end

---@param condition_type string | number
function MultiConditionCtrl:_Remove(condition_type)
    if condition_type then
        for k,v in pairs(self.condition_list) do
            if v.type == condition_type then
                table.remove(self.condition_list,k)
                PoolUtil.ReleaseTable(v)
            end
        end
    end
end

local function Add(self,condition)
    if self:IsQueue() then
        table.insert(self.condition_list,1,condition)
    else
        table.insert(self.condition_list,condition)
    end
end

function MultiConditionCtrl:_Add(condition_type)
    local condition = PoolUtil.GetTable()
    condition.type = condition_type
    Add(self,condition)
    return condition
end

---设置top位置
function MultiConditionCtrl:_SetTop(condition_type)
    local pos,condition
    for k,v in pairs(self.condition_list) do
        if v.type == condition_type then
            pos = k
            condition = v
            break
        end
    end
    if pos then
        table.remove(self.condition_list,pos)
        Add(self,condition)
    end
end

return MultiConditionCtrl