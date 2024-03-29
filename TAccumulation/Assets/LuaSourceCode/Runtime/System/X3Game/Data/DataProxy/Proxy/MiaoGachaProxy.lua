﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2021/12/10 11:44
--- 喵牌集卡数据
---@type MiaoGachaData
local MiaoGachaData = require "Runtime.System.X3Game.Data.DataProxy.Data.MiaoGachaData"
---@class MiaoGachaProxy
local MiaoGachaProxy = class("MiaoGachaProxy", BaseProxy)

function MiaoGachaProxy:OnInit()
    ---@type MiaoGachaData[]
    self.gachaGroup = {}
    self.selectGroupCache = {}
    --初始化卡牌数据
    --self:GetGachaData()
end

---@return MiaoGachaData
function MiaoGachaProxy:GetGachaData(role_id)
    if not role_id then
        role_id = BllMgr.GetMiaoGachaBLL():GetCurRole()
    end
    if self.gachaGroup[role_id] then
        return self.gachaGroup[role_id]
    end
end

---@return MiaoGachaItemData[]
function MiaoGachaProxy:GetGachaList(role_id)
    if not role_id then
        role_id = BllMgr.GetMiaoGachaBLL():GetCurRole()
    end
    if self.gachaGroup[role_id] then
        return self.gachaGroup[role_id]:GetGachaList()
    end
end

function MiaoGachaProxy:UpdateGachaGroup(gachaGroup)
    local roleList = BllMgr.GetRoleBLL():GetRoleCfgList()
    for i, v in pairs(roleList) do
        if not self.gachaGroup[v.ID] then
            self.gachaGroup[v.ID] = MiaoGachaData.new(v.ID)
            self.gachaGroup[v.ID]:InitGacha()
        end
        self.gachaGroup[v.ID]:UpdateGachaData(gachaGroup[v.ID] and gachaGroup[v.ID].Series)
    end
end

function MiaoGachaProxy:UpdateGachaData(msg)
    if self.gachaGroup[msg.RoleId] then
        self.gachaGroup[msg.RoleId]:UpdateGachaData(msg.Series)
    end
end

---@return MiaoGachaData.resultData
function MiaoGachaProxy:CheckHasExistGacha(data, series_id, role_id)
    if not role_id then
        role_id = BllMgr.GetMiaoGachaBLL():GetCurRole()
    end
    if self.gachaGroup[role_id] then
        return self.gachaGroup[role_id]:CheckHasExistGacha(data, series_id)
    end
end

function MiaoGachaProxy:GetGachaDataBySeriesID(series_id, role_id)
    if not role_id then
        role_id = BllMgr.GetMiaoGachaBLL():GetCurRole()
    end
    if self.gachaGroup[role_id] then
        return self.gachaGroup[role_id]:GetGachaItemDataBySeriesId(series_id)
    end
end

function MiaoGachaProxy:CheckIsCostItem(item_id)
    for role_id, v in pairs(self.gachaGroup) do
        if v:CheckIsCostItem(item_id) then
            return true, role_id
        end
    end
    return false
end

function MiaoGachaProxy:RefreshRedPoint(role_id)
    if not role_id then
        role_id = BllMgr.GetMiaoGachaBLL():GetCurRole()
    end
    if self.gachaGroup[role_id] then
        self.gachaGroup[role_id]:RefreshRedPoint()
    end
end

function MiaoGachaProxy:GetDayCoinId(role_id)
    if not role_id then
        role_id = BllMgr.GetMiaoGachaBLL():GetCurRole()
    end
    if self.gachaGroup[role_id] then
        return self.gachaGroup[role_id]:GetDayCoinId()
    end
end

function MiaoGachaProxy:GetCollectAmountByRoleId(role_id, pack_id)
    if role_id == -1 then
        local roleList = BllMgr.GetRoleBLL():GetUnlockedRoleCfg()
        local amount = 0
        for i, v in pairs(roleList) do
            if self.gachaGroup[v.ID] then
                local count = self.gachaGroup[v.ID]:GetCollectFinishCount(pack_id)
                amount = amount + count
            end
        end
        return amount
    else
        if self.gachaGroup[role_id] then
            return self.gachaGroup[role_id]:GetCollectFinishCount(pack_id)
        end
    end
    return 0
end

---设置当前购买的卡包
---@param groupId  int 卡包id
function MiaoGachaProxy:SetSelectGroupID(groupId, roleId)
    self.selectGroupCache[roleId] = groupId
end

---@param roleId int 男主id
---@param isCheck bool 是否检测开放状态
---@return int 卡包id
function MiaoGachaProxy:GetSelectGroupID(roleId, isCheck)
    local selectId = self.selectGroupCache[roleId]
    if isCheck then
        if selectId then
            local itemData = self:GetGachaDataBySeriesID(selectId, roleId)
            if itemData then
                local isOpen, _ = itemData:CheckInOpenTime()
                if isOpen then  --只有开放状态的卡包才可被默认选中
                    return selectId
                end
            end
        end
    else
        return selectId
    end
end

return MiaoGachaProxy