﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/12/15 20:54
---@class ShopProxy
local ShopProxy = class("ShopProxy", BaseProxy)
local ShopMallConst = require("Runtime.System.X3Game.GameConst.ShopMallConst")
function ShopProxy:OnInit()
    self:Subscribe()
    BllMgr.GetShopMallBLL()
end

---EnterGame 初始化数据
---@param shopData pbcmessage.ShopData
function ShopProxy:Init(shopData)
    if shopData == nil then
        return
    end
    ---@type X3Data.ShopData
    self.shopData = X3DataMgr.GetOrAdd(X3DataConst.X3Data.ShopData)
    self.shopData:DecodeByField(shopData)
    ---商店
    for k, v in pairs(shopData.Shops) do
        self:AddShop(v)
    end
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_RED_POINT_CHECK)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_DATA_INIT)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_START_RESET_NUM_TIME)
end

---@param reply pbcmessage.GetSomeShopDataReply
function ShopProxy:OnGetSomeShopDataCallBack(reply)
    for k, v in pairs(reply.Shops) do
        self:AddShop(v)
        EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_RED_POINT_CHECK, k)
    end
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_REFRESH_UPDATE)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_START_RESET_NUM_TIME)
end

---@param shopData pbcmessage.Shop
function ShopProxy:AddShop(shopData)
    if shopData == nil then
        return
    end
    ---@type X3Data.Shop
    local shop = X3DataMgr.Get(X3DataConst.X3Data.Shop, shopData.Id)
    if shop == nil then
        shop = X3DataMgr.Add(X3DataConst.X3Data.Shop)
    end
    shop:DecodeByField(shopData)
    local shopReSets = shop:GetReSets()
    if shopReSets then
        for k, v in pairs(shopReSets) do
            ---@type cfg.ShopGroup
            local shopGroupCfg = LuaCfgMgr.Get("ShopGroup", k)
            if shopGroupCfg and shopGroupCfg.ItemRefreshType ~= Define.DateRefreshType.None then
                local nextTime = TimeRefreshUtil.GetNextRefreshTime(v, shopGroupCfg.ItemRefreshType, shopGroupCfg.ItemRefreshTime)
                shop:AddOrUpdateReSetsValue(k, nextTime)
            end
        end
    end
end

---根据商店Id获取商店数据
---@return X3Data.Shop
function ShopProxy:GetShopData(shopId)
    local shop = X3DataMgr.Get(X3DataConst.X3Data.Shop, shopId)
    return shop
end

---获取当前所有商店
---@return table<X3Data.Shop>
function ShopProxy:GetAllShop()
    local ret = {}
    X3DataMgr.GetAll(X3DataConst.X3Data.Shop, ret)
    return ret
end

---@param request pbcmessage.HandResetRequest
---@param data pbcmessage.HandResetReply
function ShopProxy:OnHandResetCallBack(request, data)
    self:AddShop(data.Shop)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_REFRESH_UPDATE)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_RED_POINT_CHECK, data.Shop.Id)
end

function ShopProxy:Subscribe()
    X3DataMgr.Subscribe(X3DataConst.X3Data.Shop, ShopProxy.OnShopResetNumChange, ShopProxy,
            X3DataConst.X3DataField.Shop.HandReNum)
end

function ShopProxy:OnShopResetNumChange()
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_RESET_NUM_CHANGE)
end

---@param data pbcmessage.ShopBuyReply
---@param request pbcmessage.ShopBuyRequest
function ShopProxy:OnShopBuyCallBack(data)
    local refShopIdTab = {}
    for k, v in pairs(data.Buys) do
        local goodsId = k
        ---@type cfg.ShopGroup
        local shopGroupCfg = LuaCfgMgr.Get("ShopGroup", goodsId)
        ---@type X3Data.Shop
        local shop = X3DataMgr.Get(X3DataConst.X3Data.Shop, shopGroupCfg.ShopID)
        if shop == nil then
            shop = X3DataMgr.Add(X3DataConst.X3Data.Shop)
            shop:SetPrimaryValue(shopGroupCfg.ShopID)
        end
        if shop then
            shop:AddOrUpdateBuysValue(k, v)
        end
        if not table.containsvalue(refShopIdTab, shopGroupCfg.ShopID) then
            table.insert(refShopIdTab, shopGroupCfg.ShopID)
        end
    end
    for k, v in pairs(data.ReSets) do
        local goodsId = k
        ---@type cfg.ShopGroup
        local shopGroupCfg = LuaCfgMgr.Get("ShopGroup", goodsId)
        ---@type X3Data.Shop
        local shop = X3DataMgr.Get(X3DataConst.X3Data.Shop, shopGroupCfg.ShopID)
        if shop == nil then
            shop = X3DataMgr.Add(X3DataConst.X3Data.Shop)
            shop:SetPrimaryValue(shopGroupCfg.ShopID)
        end
        if shop then
            if shopGroupCfg and shopGroupCfg.ItemRefreshType ~= Define.DateRefreshType.None then
                local nextTime = TimeRefreshUtil.GetNextRefreshTime(v, shopGroupCfg.ItemRefreshType, shopGroupCfg.ItemRefreshTime)
                shop:AddOrUpdateReSetsValue(k, nextTime)
            else
                shop:AddOrUpdateReSetsValue(k, v)
            end
        end
    end
    for k, v in pairs(data.LastBuyTime) do
        local goodsId = k
        ---@type cfg.ShopGroup
        local shopGroupCfg = LuaCfgMgr.Get("ShopGroup", goodsId)
        ---@type X3Data.Shop
        local shop = X3DataMgr.Get(X3DataConst.X3Data.Shop, shopGroupCfg.ShopID)
        if shop == nil then
            shop = X3DataMgr.Add(X3DataConst.X3Data.Shop)
            shop:SetPrimaryValue(shopGroupCfg.ShopID)
        end
        if shop then
            shop:AddOrUpdateLastBuyTimeValue(k, v)
        end
    end
    for k, v in pairs(data.HisBuys) do
        self.shopData:AddOrUpdateHistoryBuysValue(k, v)
    end
    for i = 1, #refShopIdTab do
        local shopId = refShopIdTab[i]
        EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_RED_POINT_CHECK, shopId)
    end
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_BUY_NUM_CHANGE, data)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_START_RESET_NUM_TIME)
end

---@param data pbcmessage.ShopUpdateBuysReply
function ShopProxy:OnShopUpdateBuysCallBack(data)
    local goodsId = data.GoodId
    ---@type cfg.ShopGroup
    local shopGroupCfg = LuaCfgMgr.Get("ShopGroup", goodsId)
    ---@type X3Data.Shop
    local shop = X3DataMgr.Get(X3DataConst.X3Data.Shop, shopGroupCfg.ShopID)
    if shop == nil then
        shop = X3DataMgr.Add(X3DataConst.X3Data.Shop)
        shop:SetPrimaryValue(shopGroupCfg.ShopID)
    end
    if shop then
        shop:AddOrUpdateBuysValue(goodsId, data.BuyNum)
        if shopGroupCfg and shopGroupCfg.ItemRefreshType ~= Define.DateRefreshType.None then
            local nextTime = TimeRefreshUtil.GetNextRefreshTime(data.ReSetTime, shopGroupCfg.ItemRefreshType, shopGroupCfg.ItemRefreshTime)
            shop:AddOrUpdateReSetsValue(goodsId, nextTime)
        else
            shop:AddOrUpdateReSetsValue(goodsId, data.ReSetTime)
        end
        shop:AddOrUpdateLastBuyTimeValue(goodsId, data.LastBuyTime)
    end
    self.shopData:AddOrUpdateHistoryBuysValue(goodsId, data.HisBuyNum)
    EventMgr.DispatchAsync(ShopMallConst.ShopEvent.SHOP_RED_POINT_CHECK, shopGroupCfg.ShopID)
    local eventData = {}
    eventData.Buys = {}
    eventData.Buys[goodsId] = data.BuyNum
    EventMgr.DispatchAsync(ShopMallConst.ShopEvent.SHOP_BUY_NUM_CHANGE, eventData)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_START_RESET_NUM_TIME)
end

---@return table<int,int>
function ShopProxy:GetHistoryBuys()
    return self.shopData:GetHistoryBuys()
end

---更新商品下次刷新时间
function ShopProxy:AddOrUpdateShopGoodsNextRefTime(shopGroupId, nextRefTime)
    self.shopData:AddOrUpdateShopGoodsNextRefTimeValue(shopGroupId, nextRefTime)
end

---获取商品下次刷新时间
function ShopProxy:GetShopGoodsNextRefTime(shopGroupId)
    local nextRefTimeMap = self.shopData:GetShopGoodsNextRefTime()
    if nextRefTimeMap and table.containskey(nextRefTimeMap, shopGroupId) then
        return nextRefTimeMap[shopGroupId]
    end
    return 0
end

---商品次数充值刷新
function ShopProxy:ShopBuyNumRest(restShopGoodsIdList)
    local refShopIdTab = {}
    for i = 1, #restShopGoodsIdList do
        local shopGoodsId = restShopGoodsIdList[i]
        ---@type cfg.ShopGroup
        local shopGroup = LuaCfgMgr.Get("ShopGroup", shopGoodsId)
        if shopGroup then
            ---@type cfg.ShopAll
            local shopCfg = LuaCfgMgr.Get("ShopAll", shopGroup.ShopID)
            if shopCfg then
                local shopData = self:GetShopData(shopCfg.ID)
                shopData:RemoveBuysValue(shopGoodsId)
                shopData:RemoveReSetsValue(shopGoodsId)
                if not table.containsvalue(refShopIdTab, shopCfg.ID) then
                    table.insert(refShopIdTab, shopCfg.ID)
                end
            end
        end
    end
    for i = 1, #refShopIdTab do
        local shopId = refShopIdTab[i]
        EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_RED_POINT_CHECK, shopId)
    end
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_START_RESET_NUM_TIME)
    EventMgr.Dispatch(ShopMallConst.ShopEvent.SHOP_REFRESH_UPDATE)
end

return ShopProxy