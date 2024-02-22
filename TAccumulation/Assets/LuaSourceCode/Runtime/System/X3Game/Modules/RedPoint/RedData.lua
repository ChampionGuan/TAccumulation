﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2021/1/20 19:57
--- 红点数据结构

local RedConst = require("Runtime.System.X3Game.Modules.RedPoint.RedConst")
---@class RedData
local RedData = class("RedData")

function RedData:ctor()
    self.id = nil
    self.type = nil
    self.count = 0
    self.parents = nil
    self.children = nil
    self.identify_id = nil
    self.operationType = 0
    self.sysIds = nil
    ---@type RedDataCtrl
    self.owner = nil
    self.is_unlock = false
    self.lock_sys_id = 0
    ---@type string[]
    self.proto = nil
    ---@type BaseBll[]
    self.bll_list = nil
    self.time = 0
end

---更新红点数量
---@param count int
---@param force boolean 是否强制刷新
function RedData:UpdateCount(count, force)
    local pre_count = self.count
    self.count = count or pre_count
    if force or pre_count ~= self.count then
        self:CountChange()
        local parents = self:GetParents()
        if parents then
            local parent
            for k, v in ipairs(parents) do
                parent = self:GetData(v)
                if parent then
                    parent:CheckCount()
                end
            end
        end
    end
end

---检测是否是叶子节点
---@return boolean
function RedData:IsLeaf()
    return table.isnilorempty(self:GetChildren())
end

---获取id
---@return int
function RedData:GetId()
    return self.id
end

---是否有效
---@return boolean
function RedData:IsAlive(count)
    count = count or self:GetCount()
    return count > 0
end

---是否解锁
---@return boolean
function RedData:IsUnlock()
    if not self.is_unlock then
        self:CheckSysUnlock()
    end
    return self.is_unlock, self.lock_sys_id
end

---获取类型
---@return int
function RedData:GetType(identify_id)
    if not identify_id and self:IsLeaf() then
        return self.type
    end
    local count, _type = self:GetAliveCountType(identify_id)
    return _type
end

---获取数量
---@param is_view boolean
---@param identify_id string | number
---@return int
function RedData:GetCount(is_view, identify_id)
    if not self:IsUnlock() then
        return 0
    end
    if is_view then
        return self:GetAliveCountType(identify_id)
    end
    return self.count
end

---获取当前活跃的红点数量和类型
---@param identify_id string | number
---@return int,int
function RedData:GetAliveCountType(identify_id)
    if not self:IsAlive() then
        return 0, 0
    end

    if self:IsLeaf() then
        return self:GetCount(), self:GetType()
    end
    local children = self:GetChildren()
    local child, count, _type = 0, 0, nil
    local isOperationAnd = self.operationType == RedConst.OperationType.OPERATION_AND
    for k, v in ipairs(children) do
        child = self:GetData(v.id)
        if child and child:IsAlive() then
            count = RedPointMgr.GetViewCount(v.id, identify_id)
            if identify_id and not self:IsAlive(count) then
                if child:IsLeaf() then
                    if not self.owner:CheckInMap(v.id) then
                        count = RedPointMgr.GetViewCount(v.id)
                    end
                end
            end
            if self:IsAlive(count) then
                if not _type then
                    _type = v.type and v.type or RedPointMgr.GetRedType(v.id,identify_id)
                end
                if not _type then
                    _type = RedPointMgr.GetRedType(v.id)
                end
                if not isOperationAnd then
                    break
                end
            else
                if isOperationAnd then
                    break
                end
            end
        end
    end
    count = count or 0
    _type = _type or 0
    if self:IsAlive(count) then
        if self:IsNumType(_type) then
            count = self:GetAllAliveCount(identify_id, true)
        end
    end
    return count, _type
end

---检测是否是数字类型
---@param redType int
---@return boolean
function RedData:IsNumType(redType)
    return redType == RedConst.RedType.NUMBER or redType == RedConst.RedType.LARGE_NUM
end

---获取所有计数的红点信息
---@param identify_id string | number
---@param isNumber boolean
---@return int
function RedData:GetAllAliveCount(identify_id, isNumber)
    if self:IsLeaf() then
        return self:GetCount()
    end
    local children = self:GetChildren()
    local child, count, _count = 0, 0, 0
    if children then
        for k, v in ipairs(children) do
            child = self:GetData(v.id)
            if child and child:IsAlive() then
                if not isNumber or self:IsNumType((v.type and v.type or RedPointMgr.GetRedType(v.id, identify_id))) then
                    _count = RedPointMgr.GetViewCount(v.id, identify_id)
                    if identify_id and not self:IsAlive(count) then
                        if child:IsLeaf() then
                            if not self.owner:CheckInMap(v.id) then
                                count = RedPointMgr.GetViewCount(v.id)
                            end
                        end
                    end
                    if self:IsAlive(_count) then
                        count = count + _count
                    end
                end
            end
        end
    end
    return count
end

---数量变化
function RedData:CountChange()
    self:CheckType()
    self.owner:OnCountChange(self:GetId())
end

---@param id int
---@return RedData
function RedData:GetData(id)
    return self.owner:GetData(id)
end

---获取子节点信息
---@return table[]
function RedData:GetChildren()
    return self.children
end

---获取父类ids
---@return int[]
function RedData:GetParents()
    return self.parents
end

---获取系统解锁ids
---@return int[]
function RedData:GetSysIds()
    return self.sysIds
end

function RedData:SetChild(child_id, red_type)
    if not child_id then
        return
    end
    if not self.children then
        self.children = {}
    end
    if not self:HasChild(child_id) then
        local data = { id = child_id }
        if red_type and red_type ~= 0 then
            data.type = red_type
        end
        table.insert(self.children, data)
    end
end

---设置父节点
---@param parent_id int
function RedData:SetParent(parent_id)
    if not parent_id then
        return
    end
    if not self.parents then
        self.parents = {}
    end
    if not self:HasParent(parent_id) then
        table.insert(self.parents, parent_id)
    end
end

---检测是否存在子节点
---@param child_id int
---@return boolean
function RedData:HasChild(child_id)
    if child_id and not self:IsLeaf() then
        local children = self:GetChildren()
        for k, v in pairs(children) do
            if v.id == child_id then
                return true
            end
        end
    end
    return false
end

---检测是否存在父节点
---@param parent_id
---@return boolean
function RedData:HasParent(parent_id)
    if parent_id then
        local parents = self:GetParents()
        if not table.isnilorempty(parents) then
            for k, v in pairs(parents) do
                if v == parent_id then
                    return true
                end
            end
        end
    end
    return false
end

---检测数量
function RedData:CheckCount()
    if not self:IsLeaf() then
        local children = self:GetChildren()
        local child
        local count = 0
        local isOperationAnd = self.operationType == RedConst.OperationType.OPERATION_AND
        for k, v in ipairs(children) do
            child = self:GetData(v.id)
            if child then
                if child:IsAlive() then
                    count = count + child:GetCount()
                else
                    if isOperationAnd then
                        count = 0
                        break
                    end
                end
            end
        end
        self:UpdateCount(count)
    end
end

---检测类型
function RedData:CheckType()
    if not self:IsAlive() then
        return
    end
    local pre_type = self:GetType()
    local cur_type = pre_type
    local children = self:GetChildren()
    if not table.isnilorempty(children) then
        local child, idx
        if self.operationType == RedConst.OperationType.OPERATION_AND then
            idx = 1
        else
            for k, v in ipairs(children) do
                child = self:GetData(v.id)
                if child then
                    if child:IsAlive() then
                        idx = k
                        break
                    end
                end
            end
        end
        if idx then
            local childConf = children[idx]
            if childConf.type then
                cur_type = childConf.type
            else
                child = child and child or self:GetData(childConf.id)
                if child then
                    cur_type = child:GetType()
                end
            end
        end
    end
    if pre_type ~= cur_type then
        self.type = cur_type
    end
end

---设置id
---@param id int
function RedData:SetId(id)
    self.id = id
end

---设置类型
---@param type int
function RedData:SetType(type)
    self.type = type
end

---@param proto string[] 协议列表
function RedData:SetProto(proto)
    self.proto = proto
end

---@param bll string[] bll列表
function RedData:SetBll(bll)
    if not bll then
        return
    end
    self.bll_list = {}
    for _, v in pairs(bll) do
        table.insert(self.bll_list, v)
    end
end

---通知bll层刷新红点
function RedData:RedCheckBll()
    if not self.bll_list then
        return
    end
    if not self:IsLeaf() then
        return
    end
    for i, v in pairs(self.bll_list) do
        local bll = BllMgr.Get(v)
        if bll and bll.OnRedPointCheck then
            bll:OnRedPointCheck(self.id)
        end
    end
end

---@param proto_name  string 协议名称
---@return bool 是否包含该协议
function RedData:CheckProtoIn(proto_name)
    if not self.proto then
        return false
    end
    return table.containsvalue(self.proto, proto_name)
end

---设置所属
---@param owner table
function RedData:SetOwner(owner)
    self.owner = owner
end

---设置操作类型
---@param operationType int
function RedData:SetOperationType(operationType)
    self.operationType = operationType and operationType or 0
end

---设置系统id
---@param sysId int
function RedData:SetSysId(sysId)
    if not self.sysIds then
        self.sysIds = {}
    end
    if not table.containsvalue(self.sysIds, sysId) then
        table.insert(self.sysIds, sysId)
    end
end

---设置系统id列表
---@param sysIds table
function RedData:SetSysIds(sysIds)
    self.sysIds = sysIds
end

---计算解锁逻辑
---@param isRefreshView boolean 是否刷新view
function RedData:CheckSysUnlock(isRefreshView)
    if self.is_unlock then
        return
    end
    local pre = self.is_unlock
    ---优先计算自身解锁条件
    self.is_unlock = true
    local sysIds = self:GetSysIds()
    if sysIds then
        for _, sysId in ipairs(sysIds) do
            if not self.owner:IsSysUnLock(sysId) then
                self.is_unlock = false
                self.lock_sys_id = sysId
                break
            end
        end
    end
    if self.is_unlock then
        ---复合节点计算
        if not self:IsLeaf() then
            ---复合类型
            local children = self:GetChildren()
            if children then
                local isOperationAnd = self.operationType == RedConst.OperationType.OPERATION_AND
                for _, v in ipairs(children) do
                    local child = self:GetData(v.id)
                    if child then
                        local is_unlock, sys_id = child:IsUnlock()
                        if isOperationAnd then
                            if not is_unlock then
                                self.is_unlock = false
                                self.lock_sys_id = sys_id
                                break
                            end
                        else
                            if is_unlock then
                                self.lock_sys_id = sys_id
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    if isRefreshView and self.is_unlock ~= pre then
        self:UpdateCount(self:GetCount(), true)
    end
end

function RedData:Clear()
    self.count = 0
    self.identify_id = nil
    self.is_unlock = false
end

return RedData