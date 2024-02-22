﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2021/1/20 20:44
--- 红点数据逻辑

local RedConst = require("Runtime.System.X3Game.Modules.RedPoint.RedConst")
---@type RedData
local RedData = require(RedConst.RED_DATA_PATH)
---@class RedDataCtrl
local RedDataCtrl = {}


---更新红点数量
---@param red_id number 红点id
---@param count number 红点数量
---@param identify_id number|string 主要用于同red_id列表区分
function RedDataCtrl:UpdateCount(red_id,count,identify_id)
    self:UpdateMapCount(red_id,count,identify_id)
end

---根据id获取红点类型
---@param red_id number 红点id
---@param identify_id number | string
---@return int
function RedDataCtrl:GetRedType(red_id,identify_id)
    local red_type = 0
    local data = self:GetData(red_id)
    if not data then return red_type end
    if data:IsLeaf()  then
        red_type = data:IsAlive() and data:GetType() or 0
    else
        red_type = data:IsAlive() and data:GetType(identify_id) or 0
    end
    return red_type
end

---获取红点数量
---@param red_id number 红点id
---@param identify_id @see RedDataCtrl:UpdateCount
---@return int
function RedDataCtrl:GetCount(red_id,identify_id)
    if not red_id then return 0 end
    if not self:IsRedUnlock(red_id) then
        return 0
    end
    local data = self:GetData(red_id)
    if data then
        if not identify_id then
            return data:GetCount()
        else
            if not data:IsLeaf() then
                return data:GetCount(true,identify_id)
            end
        end
    end
    local map = self.red_count_map[red_id]
    if map and identify_id then
        return map[identify_id] or 0
    end
    return 0
end

---获取要显示的红点数量
---@param red_id number 红点id
---@param identify_id @see RedDataCtrl:UpdateCount
---@return int
function RedDataCtrl:GetViewCount(red_id,identify_id)
    if not self:IsRedUnlock(red_id) then
        return 0,0
    end
    if not identify_id then
        local data = self:GetData(red_id)
        return data and data:GetCount(true) or 0
    end
    return self:GetCount(red_id,identify_id)
end

---判断红点是否解锁
---@return boolean | int
function RedDataCtrl:IsRedUnlock(red_id)
    local red_data = self:GetData(red_id)
    if red_data then
        return red_data:IsUnlock()
    end
    return false,0
end

---检测系统解锁
---@return boolean
function RedDataCtrl:IsSysUnLock(sysId)
    return self.is_sys_unlock_func and self.is_sys_unlock_func(sysId)
end

---更新红点数量
---@param red_id number 红点id
---@param count number 更新红点数量
---@param identify_id string | number
function RedDataCtrl:UpdateMapCount(red_id,count,identify_id)
    if not red_id then
        return
    end
    count = (count and count>0) and count or 0
    if identify_id then
        local map = self.red_count_map[red_id]
        if not map then
            map = PoolUtil.GetTable()
            self.red_count_map[red_id] = map
        end
        if count >0 then
            map[identify_id] = count
        else
            if map[identify_id] then
                map[identify_id] = nil
            end
        end
        count = 0
        for k,v in pairs(map) do
            count = count + v
        end
    else
        if count == 0 and self.red_count_map[red_id] then
            local map = self.red_count_map[red_id]
            PoolUtil.ReleaseTable(map)
            self.red_count_map[red_id] = nil
        end
    end
    local data = self:GetData(red_id)
    if data then
        data:UpdateCount(count)
    end
end

function RedDataCtrl:GetRedCountMap()
    return self.red_count_map
end

---系统解锁更新
---@param sysId
function RedDataCtrl:SysUnlockUpdate(sysId)
    if not sysId then
        return
    end
    local red_list = self:GetSysRedIdsList(sysId)
    if red_list then
        for _,red_id in pairs(red_list) do
            local data = self:GetData(red_id)
            if data then
                data:CheckSysUnlock(true)
            end
        end
    end
end

---数量变化
---@param red_id int
function RedDataCtrl:OnCountChange(red_id)
    if self.on_count_change then
        self.on_count_change(red_id)
    end
end

---根据id获取红点数据
---@param red_id number 红点id
---@param is_create boolean 如果不存在是否需要创建
---@return RedData
function RedDataCtrl:GetData(red_id,is_create)
    if not red_id then return nil end
    local data = self.data_map[red_id]
    if not data and is_create then
        data = RedData.new()
        data:SetId(red_id)
        data:SetOwner(self)
        self.data_map[red_id] = data
    end
    return data
end

---@return RedData[]
function RedDataCtrl:GetDataMap()
   return self.data_map 
end

---检测是否在map中
---@param red_id int
---@return boolean 是否在map中
function RedDataCtrl:CheckInMap(red_id)
    if not red_id then return false end
    local map = self.red_count_map[red_id]
    if map then
        for k,v in pairs(map) do
            return true
        end
    end
    return false
end

---获取系统解锁关联的红点数据
---@param sysId int
---@param isCreate boolean
---@return int[]
function RedDataCtrl:GetSysRedIdsList(sysId,isCreate)
    if not sysId then
        return
    end
    local data = self.sys_map[sysId]
    if not data and isCreate then
        data = PoolUtil.GetTable()
        self.sys_map[sysId] = data
    end
    return data
end

---生成红点树
function RedDataCtrl:GenRedTree()
    local cfg = LuaCfgMgr.GetAll(RedConst.CFG_NAME)
    ---@type RedData
    local data
    local child,id,childs,child_id
    for k,v in pairs(cfg) do
        id = v.ID
        data = self:GetData(id,true)
        data:SetOperationType(v.OperationType)
        data:SetSysIds(v.SysIds)
        data:SetProto(v.Proto)
        data:SetBll(v.BLL)
        childs = v.Childs
        if childs then
            for m,n in ipairs(childs) do
                child_id = n.ID
                child = self:GetData(child_id,true)
                child:SetParent(id)
                data:SetChild(child_id,n.Num)
            end
        else
            data:SetType(v.Type)
        end
    end
    LuaCfgMgr.UnLoad(RedConst.CFG_NAME)
end

function RedDataCtrl:InitSys()
    ---@type RedData
    local data
    for redId,v in pairs(self.data_map) do
        data = v
        local sysIds = data:GetSysIds()
        if sysIds then
            for _,sysId in ipairs(sysIds) do
                local list = self:GetSysRedIdsList(sysId,true)
                if not table.containsvalue(list,sysId) then
                    table.insert(list,redId)
                end
            end
        end
    end
end

---检测所有红点bll
function RedDataCtrl:CheckAllRed()
    for redId,v in pairs(self.data_map) do
        v:RedCheckBll()
    end
end

---清理所有红点数据
function RedDataCtrl:Clear()
    for k,v in pairs(self.data_map) do
        v:Clear()
    end
    table.clear(self.red_count_map)
end

function RedDataCtrl:Init(on_count_change,is_sys_unlock_func)
    self.red_count_map = {}
    self.on_count_change = on_count_change
    self.is_sys_unlock_func = is_sys_unlock_func
    ---@type table<int,RedData>
    self.data_map = {}
    self.sys_map ={}
    self:GenRedTree()
    self:InitSys()
end

return RedDataCtrl