---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-04-20 16:36:06
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BagBLL
local BagBLL = class("BagBLL", BaseBll)

local BAG_RED_POINT_PREFS
local BAG_TOP_ITEM_PREFS
local BAG_DISABLE_PACKAGE_PREFS

local m_bagItemDic = {}
local m_bagSpItemDic = {}

local m_topItemTag = {}
local m_disablePackage = {}

function BagBLL:Init()
    local uid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
    BAG_RED_POINT_PREFS = string.concat("BAG_RED_POINT_PREFS_", uid)
    BAG_TOP_ITEM_PREFS = string.concat("BAG_TOP_ITEM_PREFS_", uid)
    BAG_DISABLE_PACKAGE_PREFS = string.concat("BAG_DISABLE_PACKAGE_PREFS_", uid)

    EventMgr.AddListener(NoviceGuideDefine.Event.CLIENT_LEVEL_CHANGE, self.RefreshPackageOpenCheck, self)
end

function BagBLL:InitBagRP()
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_BAG_ITEM, BagBLL:GetBagRP() and 1 or 0)
end

function BagBLL:GetBagRP()
    local bagRP = PlayerPrefs.GetInt(BAG_RED_POINT_PREFS, -1)

    if bagRP == -1 then
        for _, v in pairs(BllMgr.Get("ItemBLL"):GetItemList()) do
            if BllMgr.GetItemBLL():IsPackageItem() then
                if BllMgr.GetItemBLL():CanOpenPackage(v.Id) then
                    bagRP = 1
                    self:SetTopItem(true, v.Id)
                else
                    self:SetDisablePackage(true, v.Id)
                end
            end
        end
    end

    return bagRP == 1
end

function BagBLL:SetBagRP(isActive)
    if isActive == true then
        PlayerPrefs.SetInt(BAG_RED_POINT_PREFS, 1)
    else
        PlayerPrefs.SetInt(BAG_RED_POINT_PREFS, 0)
    end

    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_BAG_ITEM, isActive and 1 or 0)
end

function BagBLL:RefreshPackageOpenCheck()
    for k, v in pairs(m_disablePackage) do
        if v == 1 and BllMgr.GetItemBLL():CanOpenPackage(k) then
            self:SetTopItem(true, k)
            self:SetDisablePackage(false, k)
            local item = BllMgr.GetItemBLL():GetItem(k)
            if item.Num > 0 then
                self:UpdateItemRp()
                self:SetBagRP(true)
            end
        end
    end
end

--region 道具置顶相关
function BagBLL:SetTopItem(isTop, id, spId)
    spId = spId == nil and 0 or spId
    local tag = string.concat(BAG_TOP_ITEM_PREFS, id, "_", spId)
    if isTop then
        PlayerPrefs.SetInt(tag, 1)
        m_topItemTag[tag] = 1
    else
        PlayerPrefs.SetInt(tag, 0)
    end
end

function BagBLL:ClearTopItem()
    for k, _ in pairs(m_topItemTag) do
        PlayerPrefs.SetInt(k, 0)
    end

    m_topItemTag = {}
end

function BagBLL:GetTopItem(id, spId)
    spId = spId == nil and 0 or spId
    local tag = string.concat(BAG_TOP_ITEM_PREFS, id, "_", spId)
    local TopFlag = PlayerPrefs.GetInt(tag, 0)
    m_topItemTag[tag] = TopFlag
    return TopFlag
end

function BagBLL:SetDisablePackage(disable, id)
    local tag = string.concat(BAG_DISABLE_PACKAGE_PREFS, id)
    if disable then
        PlayerPrefs.SetInt(tag, 1)
        m_disablePackage[id] = 1
    else
        PlayerPrefs.SetInt(tag, 0)
        m_disablePackage[id] = 0
    end
end

function BagBLL:GetDisablePackage(id)
    local tag = string.concat(BAG_DISABLE_PACKAGE_PREFS, id)
    local TopFlag = PlayerPrefs.GetInt(tag, 0)
    if TopFlag == 1 then
        m_disablePackage[id] = TopFlag
    end

    return TopFlag
end
--endregion

function BagBLL:InitData()
    m_bagItemDic = {}
    local bagItemData = BllMgr.GetItemBLL():GetItemList()
    for k, v in pairs(bagItemData) do
        self:AddItemToDic(v)
        self:GetDisablePackage(v.Id)
    end

    m_bagSpItemDic = {}
    local BagSpItemData = BllMgr.GetItemBLL():GetSpitemsByType(X3_CFG_CONST.ITEM_TYPE_STAMINAITEM)
    for i = 1, #BagSpItemData do
        BagBLL.AddItemToSpItemDic(BagSpItemData[i], i, X3_CFG_CONST.ITEM_TYPE_STAMINAITEM)
    end

    self:RefreshPackageOpenCheck()
end

function BagBLL:AddItemToDic(itemData)
    local itemID = itemData.Id
    local itemInfo = LuaCfgMgr.Get("Item", itemID)

    if itemInfo == nil then
        return
    end

    local itemTypeData = LuaCfgMgr.Get("ItemType", itemInfo.Type)
    if itemTypeData == nil then
        return
    end

    local isTopItem = self:GetTopItem(itemID)

    if itemTypeData.InBag == 1 and itemTypeData.PageID ~= 0 then
        local bagPage = itemTypeData.PageID

        if m_bagItemDic[bagPage] == nil then
            m_bagItemDic[bagPage] = {}
        end

        if m_bagItemDic[0] == nil then
            m_bagItemDic[0] = {}
        end

        if m_bagItemDic[bagPage][itemID] == nil then
            if itemData.Num ~= 0 then
                m_bagItemDic[bagPage][itemID] = { Data = itemData, Info = itemInfo, Type = itemTypeData, SpecialIndex = -1, isTop = isTopItem }
            end

        else
            m_bagItemDic[bagPage][itemID].Num = m_bagItemDic[bagPage][itemData.Id].Data.Num + itemData.Num
            if m_bagItemDic[bagPage][itemID].Data.Num + itemData.Num == 0 then
                m_bagItemDic[bagPage][itemID] = nil
            else
                m_bagItemDic[bagPage][itemID].isTop = isTopItem
            end
        end

        if m_bagItemDic[0][itemData.Id] == nil then
            if itemData.Num ~= 0 then
                m_bagItemDic[0][itemID] = { Data = itemData, Info = itemInfo, Type = itemTypeData, SpecialIndex = -1, isTop = isTopItem }
            end

        else
            m_bagItemDic[0][itemID].Num = m_bagItemDic[bagPage][itemID].Data.Num + itemData.Num
            if m_bagItemDic[0][itemID].Data.Num + itemData.Num == 0 then
                m_bagItemDic[0][itemID] = nil
            else
                m_bagItemDic[bagPage][itemID].isTop = isTopItem
            end
        end
    end

end

function BagBLL.AddItemToSpItemDic(ItemData, Index, Type)
    local ItemID = ItemData.Mid
    local ItemInfo = LuaCfgMgr.Get("Item", ItemID)

    if ItemInfo == nil then
        return
    end

    local ItemTypeData = LuaCfgMgr.Get("ItemType", ItemInfo.Type)
    if ItemTypeData == nil then
        return
    end

    local isTopItem = BagBLL:GetTopItem(ItemData.Mid, ItemID)

    if ItemTypeData.InBag == 1 and ItemTypeData.PageID ~= 0 and ItemData.Num ~= 0 then
        local BagPage = ItemTypeData.PageID

        if m_bagItemDic[BagPage] == nil then
            m_bagItemDic[BagPage] = {}
        end

        if m_bagItemDic[0] == nil then
            m_bagItemDic[0] = {}
        end

        table.insert(m_bagItemDic[0], #m_bagItemDic[0] + 1, { Data = ItemData, Info = ItemInfo, Type = ItemTypeData, SpecialIndex = Index + 1, isTop = isTopItem })
        table.insert(m_bagItemDic[BagPage], #m_bagItemDic[BagPage] + 1, { Data = ItemData, Info = ItemInfo, Type = ItemTypeData, SpecialIndex = Index + 1, isTop = isTopItem })
    end
end

function BagBLL.GetListByPage(pageID)
    local itemList = table.dictoarray(m_bagItemDic[pageID]) or { }
    table.insertto(itemList, m_bagSpItemDic[pageID])

    table.sort(itemList, function(a, b)
        if a.isTop == b.isTop then
            if a.Type.Order == b.Type.Order then
                if a.SpecialIndex == b.SpecialIndex then
                    if a.Info.Order == b.Info.Order then
                        if a.Info.Quality == b.Info.Quality then
                            return a.Info.ID < b.Info.ID
                        else
                            return a.Info.Quality > b.Info.Quality
                        end
                    else
                        return a.Info.Order < b.Info.Order
                    end
                else
                    return a.SpecialIndex < b.SpecialIndex
                end

            else
                return a.Type.Order > b.Type.Order
            end
        else
            return a.isTop > b.isTop
        end
    end)

    return itemList
end

-------------------背包红点相关-----------------
function BagBLL:UpdateItemRp(id, num)
    if id then
        if id then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_BAG_ITEM_GIFT, (BllMgr.GetItemBLL():CanOpenPackage(id) and num > 0) and 1 or 0, id)
        end
    else
        for k, v in pairs(BllMgr.Get("ItemBLL"):GetItemList()) do
            BagBLL:UpdateItemRp(v)
        end
    end
end

return BagBLL