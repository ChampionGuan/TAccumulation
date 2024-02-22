﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2021/12/10 18:14
---@type MiaoGachaRegularData
local MiaoGachaRegularData = require "Runtime.System.X3Game.UI.UIView.MiaoGachaWnd.Data.MiaoGachaRegularData"
---@type MiaoGachaItemData
local MiaoGachaItemData = require "Runtime.System.X3Game.UI.UIView.MiaoGachaWnd.Data.MiaoGachaItemData"
---@type MiaoGachaConst
local MiaoGachaConst = require("Runtime.System.X3Game.GameConst.MiaoGachaConst")
---@class MiaoGachaData
local MiaoGachaData = class("MiaoGachaData")

function MiaoGachaData:ctor(role_id)
    self.role_id = role_id
    ---@type MiaoGachaRegularData[]
    self.gacha_pool = {}
    self.gachacoin_max_limit = 0  --日活跃喵呜币产出上限
    self.day_coin_id = 0 --日活跃喵呜币id
end

---初始化卡包数据
function MiaoGachaData:InitGacha()
    local regularChange = LuaCfgMgr.GetAll("MiaoGachaRegularChange")
    for i, v in pairs(regularChange) do
        if self.day_coin_id == 0 then
            self.day_coin_id, self.index = self:GetCostId(v.Consum)
        end
        self.gacha_pool[v.ID] = MiaoGachaRegularData.new(v.ID)
        self.gacha_pool[v.ID]:SetInfo(self.role_id, v, self.day_coin_id, self.index)
    end
    local itemCfg = LuaCfgMgr.Get("Item", self.day_coin_id)
    self.gachacoin_max_limit = itemCfg and itemCfg.MaxStackNum or 0
    self:RefreshRedPoint()
end

function MiaoGachaData:GetCostId(costData)
    if not costData then
        return 0, 0
    end
    local cost_id = 0
    local index = 0
    for k, v in pairs(costData) do
        if v.ID == self.role_id then
            cost_id = v.Num
            index = k
            break
        end
    end
    return cost_id, index
end

function MiaoGachaData:GetDayCoinId()
    return self.day_coin_id
end

---集齐卡包的数量
function MiaoGachaData:GetCollectFinishCount(pack_id)
    local count = 0
    if pack_id then
        local itemData = self:GetGachaItemDataBySeriesId(pack_id)
        if itemData and itemData:GetCollectFinishState() then
            return 1
        end
        return count
    end
    for _, v in pairs(self.gacha_pool) do
        for k = 1, #v do
            local itemData = v[k]
            if itemData and itemData:GetCollectFinishState() then
                count = count + 1
            end
        end
    end
    return count
end

--判断活动是否进行时
function MiaoGachaData:CheckActiveIsOn()
    for i, v in pairs(self.gacha_pool) do
        if v:GetGachaType() == MiaoGachaConst.EGachaType.Activity then
            if v:CheckHasOpen() then
                return true
            end
        end
    end
    return false
end

---@return table
---获取所有集卡数据
function MiaoGachaData:GetGachaList()
    ---@type MiaoGachaItemData[]
    local gacha_list = table.values(self:GetShowGacha())
    table.sort(gacha_list, function(a, b)
        return a:GetPriority() > b:GetPriority()
    end)
    return gacha_list
end

---@return MiaoGachaItemData[]
function MiaoGachaData:GetShowGacha()
    ---@type MiaoGachaItemData[]
    local gacha_list = {}
    for _, v in pairs(self.gacha_pool) do
        local list = v:GetPackList()
        if next(list) then
            for i, pack_item in ipairs(list) do
                if gacha_list[pack_item:GetId()] then
                    if v:CheckIsValid() then
                        --有在轮换期的优先有效的卡池
                        gacha_list[pack_item:GetId()] = pack_item
                    end
                else
                    gacha_list[pack_item:GetId()] = pack_item
                end
            end
        end
    end
    return gacha_list
end

---@param seriesid int
---@return MiaoGachaItemData
function MiaoGachaData:GetGachaItemDataBySeriesId(seriesid)
    local gacha_list = self:GetShowGacha()
    local itemData = gacha_list[seriesid]
    if not itemData then
        local groupType = self:GetGachaTypeByID(seriesid)
        if groupType ~= MiaoGachaConst.EGachaType.Change then
            for i, v in pairs(self.gacha_pool) do
                if v:GetGachaType() == groupType then
                    itemData = v:GetGachaItemByPackId(seriesid)
                end
            end
        end
    end
    return itemData
end

function MiaoGachaData:GetGachaTypeByID(seriesid)
    local cfg = LuaCfgMgr.Get("MiaoGachaPack", seriesid)
    return cfg and cfg.GroupID or 0
end

---获取满足条件的卡片需求数据
---@class MiaoGachaData.resultData
---@field itemData MiaoGachaInfoData
---@field series_data MiaoGachaItemData
---@return MiaoGachaData.resultData
function MiaoGachaData:CheckHasExistGacha(item_id, series_id)
    local resultData = {}
    ---@type MiaoGachaItemData
    local group_data = self:GetGachaItemDataBySeriesId(series_id)
    if group_data then
        local itemData = group_data:GetCollectDataByItemID(item_id)
        resultData = {
            itemData = itemData,
            series_data = group_data,
        }
    end
    return resultData
end

---@class MiaoGachaData.Series
---@field SId int
---@field Drops table<int,int>
---@field Progress table<int,int>
---更新卡池数量
---@param Series
function MiaoGachaData:UpdateGachaData(Series)
    if Series and next(Series) then
        for _, v in pairs(Series) do
            ---@type MiaoGachaItemData
            local item = self:GetGachaItemDataBySeriesId(v.SId)
            if item then
                item:SetCollectData()
                item:SetGachaPoolData(v.Drops)
            end
        end
    end
end

function MiaoGachaData:CheckIsCostItem(item_id)
    return self.day_coin_id == item_id
end

function MiaoGachaData:RefreshRedPoint()
    local activity_open = self:CheckActiveIsOn()
    local coin_num = BllMgr.Get("ItemBLL"):GetItemNum(self.day_coin_id)
    if activity_open then
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_DATE_MIAOGACHA, 0, self.role_id)
    else
        if self.gachacoin_max_limit > 0 then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_DATE_MIAOGACHA, coin_num == self.gachacoin_max_limit and 1 or 0, self.role_id)
        end
    end
end

return MiaoGachaData