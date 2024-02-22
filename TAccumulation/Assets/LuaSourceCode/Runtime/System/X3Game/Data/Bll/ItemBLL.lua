---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-04-26 14:49:06
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class ItemBLL
local ItemBLL = class("ItemBLL", BaseBll)

---@class S3Int
---@field ID int
---@field Type int
---@field Num int

---@public
---构造函数
function ItemBLL:OnInit()
    ---@type table<pbcmessage.ItemTransUpdateReply>
    self.itemTransList = {}
    ---@type ItemProxy
    self.proxy = SelfProxyFactory.GetItemProxy()
    self.itemPool = {}
end

function ItemBLL:OnClear()
    table.clear(self.itemTransList)
    table.clear(self.itemPool)
    self.proxy = nil
end

---@public
---初始化
---@param items table 服务器下发道具列表
function ItemBLL:Init(items)
    self.proxy:InitData(items)
end

---@public
---增加道具
---@param item table 服务器下发单个道具数据
function ItemBLL:AddItem(item)
    self.proxy:AddItem(item)
end

---@public
---获取道具列表
function ItemBLL:GetItemList()
    local result = {}
    ---@type X3Data.Item[]
    local items = PoolUtil.GetTable()
    X3DataMgr.GetAll(X3DataConst.X3Data.Item, items)

    for k, v in pairs(items) do
        local item = {}
        v:Encode(item)
        table.insert(result, #result + 1, item)
    end

    PoolUtil.ReleaseTable(items)
    return result
end

---@public
---获取道具关联Id，主要用于羁绊卡score和其碎片的关联
function ItemBLL:GetItemRelatedID(itemID)
    local itemData = LuaCfgMgr.Get("Item", itemID);
    if (itemData == nil) then
        Debug.LogError("沒有找到itemID为：" .. itemID .. "的相关数据！！！");
        return 0;
    end

    if itemData.Type == X3_CFG_CONST.ITEM_TYPE_SCORE then
        return itemData.ID;
    elseif itemData.Type == X3_CFG_CONST.ITEM_TYPE_CARD then
        return itemData.ID;
    elseif itemData.Type == X3_CFG_CONST.ITEM_TYPE_CARDFRAGMENT then
        return itemData.ConnectID;
    elseif itemData.Type == X3_CFG_CONST.ITEM_TYPE_SCOREFRAGMENT then
        return itemData.ConnectID;
    elseif itemData.Type == X3_CFG_CONST.ITEM_TYPE_SKININVOKE then
        return itemData.ConnectID;
    end
    return 0;
end



---@class ItemData
---@field Id int
---@field Type int
---@field Num int

---获取单个道具服务器信息
---@param itemID int itemID
---@return ItemData
function ItemBLL:GetItem(itemID, roleId)
    local cfg = LuaCfgMgr.Get("Item", itemID)
    if cfg == nil then
        return nil
    end

    if self.itemPool[itemID] == nil then
        self.itemPool[itemID] = {}
    end
    local item = self.itemPool[itemID]
    local itemData = X3DataMgr.Get(X3DataConst.X3Data.Item, itemID)
    if itemData then
        itemData:Encode(item)
    else
        item.Id = itemID
        item.Type = cfg.Type
        item.Num = self:GetItemNum(itemID, cfg.Type, roleId)
    end
    return item
end

function ItemBLL:GetItemNum(id, type, roleId, includeReplace)
    if includeReplace then
        local num = self:GetItemNum(id, type, roleId)
        local replaceItems = LuaCfgMgr.Get("ReplaceItemList", id)
        if replaceItems then
            for i = 1, #replaceItems do
                num = num + self:GetItemNum(replaceItems[i], nil, roleId)
            end
        end
        return num
    else
        if type == nil then
            local cfg = LuaCfgMgr.Get("Item", id)
            type = (cfg or {}).Type
        end

        if type == nil then
            return 0
        end
        if type == 1 then
            return SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.Gold)
        elseif type == 2 then
            return SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.Jewel)
        elseif type == 3 then
            return SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.Power)
        elseif type == 4 then
            SelfProxyFactory.GetPlayerInfoProxy():GetExp()
        elseif type == 6 then
            return SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.StarJewel)
        elseif type == 7 then
            return SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.TestPoint)
        elseif type == 40 then
            local spItemList = self:GetSpItemsById(id)
            local number = 0
            for i = 1, #spItemList do
                number = number + spItemList[i].Num
            end
            return number
        elseif type == 50 then
            local scoreData = SelfProxyFactory.GetScoreProxy():GetScoreData(self:GetItemRelatedID(id))
            return scoreData and scoreData.Num or 0
        elseif type == 51 then
            local cardData = SelfProxyFactory.GetCardDataProxy():GetData(self:GetItemRelatedID(id))
            return cardData and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_FRAME then
            return SelfProxyFactory.GetPlayerInfoProxy():HasFrame(id) and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_TITLE then
            return SelfProxyFactory.GetPlayerInfoProxy():HasTitle(id) and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_COLLECTION then
            local targetRoleId = roleId or (LuaCfgMgr.Get("Item", id) or {}).Role
            if targetRoleId then
                local data = BllMgr.GetCollectionRoomBLL():GetCollectionDataByRole(id, targetRoleId)
                return data and data.Num or 0
            else
                local data = BllMgr.GetCollectionRoomBLL():GetCollectionItemData(id)
                return data and data:GetCount() or 0
            end
        elseif type == X3_CFG_CONST.ITEM_TYPE_PHOTO_ACTION or
                type == X3_CFG_CONST.ITEM_TYPE_PHOTO_STICKER or
                type == X3_CFG_CONST.ITEM_TYPE_PHOTO_WINDS or
                type == X3_CFG_CONST.ITEM_TYPE_PHOTO_FRAME or
                type == X3_CFG_CONST.ITEM_TYPE_PHOTO_FILTER then
            local itemUnlock = BllMgr.GetPhotoSystemBLL():GetItemInfo(id)
            return itemUnlock and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_MAINUI_SCENE then
            return SelfProxyFactory.GetMainInteractProxy():CheckUnLockScene(id) and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_MAINUI_BGM then
            return BllMgr.GetBGMBLL():IsUnlockBGM(id) and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_SKININVOKE then
            return BllMgr.GetFashionBLL():IsFashionUnlock(self:GetItemRelatedID(id)) and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_MSG_BUBBLE then
            return BllMgr.GetMobileContactBLL():IsUnLockBubble(id) and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_WEAPON then
            return BllMgr.GetWeaponBLL():GetServerWeapon(id) and 1 or 0
        elseif type == X3_CFG_CONST.ITEM_TYPE_DIYMODEL then
            return SelfProxyFactory.GetActivityHangUpProxy():CheckIfDIYModelItemOwned(id) and 1 or 0
        end
        
        local itemData = X3DataMgr.Get(X3DataConst.X3Data.Item, id)
        return itemData and itemData:GetNum() or 0
    end
end

---@public
---获取一种类型的道具配置
function ItemBLL:GetLocalItemByType(type)
    local allItems = LuaCfgMgr.GetAll("Item")
    local items = {}

    for k, v in pairs(allItems) do
        if v.Type == type then
            table.insert(items, v)
        end
    end

    table.sort(items, function(a, b)
        return a.ID < b.ID
    end)

    return items
end

---@public
---获取单个物品配置信息
function ItemBLL:GetLocalItem(itemID)
    return LuaCfgMgr.Get("Item", itemID)
end
--region 通用限时功能
----获取道具过期控制属性
function ItemBLL:GetItemLeftTime(cfgId)
    local itemConfig = LuaCfgMgr.Get("Item", cfgId)
    if (itemConfig.TimeType ~= 0) then
        if (string.isnilorempty(itemConfig.TimePara)) then
            Debug.LogError("道具过期配置不完整 ", itemConfig.ID)
            return -1;
        end
        --具体时效过期(起始时间，过期时间)
        if (itemConfig.TimeType == 1) then
            local timeStringList = string.split(itemConfig.TimePara, "|")
            if (#timeStringList == 2) then
                --GrpcMgr.GetServerTime()
                local startTime = timeStringList[1] == "0" and 0 or  GameHelper.GetDateByStr(timeStringList[1])
                local endTime = timeStringList[2] == "0" and 0 or GameHelper.GetDateByStr(timeStringList[2])
                return startTime, endTime, true
            end
        elseif (itemConfig.TimeType == 2) then

        end
    end
    --无过期属性
    return nil, nil, false;
end

---获取常规item剩余时间文本
function ItemBLL:GetCommonItemEndTime(curTime)
    local retStr = PlayerUtil.GetNormalTime(curTime)
    local isGreaterHours = false
    local hours = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.STAMINATIMEICON) or 168

    if curTime/3600 >= hours then
        isGreaterHours = true
    end

    return retStr, isGreaterHours
end

---清理过期的道具
function ItemBLL:SendRemoveCommonItemReq(itemID)
    local messageBody = {}
    messageBody.ExpireList = {}
    table.insert(messageBody.ExpireList, itemID)
    --Debug.LogError("SendRemoveCommonItemReq ", itemID)
    --Debug.LogErrorTable(messageBody)
    GrpcMgr.SendRequest(RpcDefines.CheckItemExpireRequest, messageBody)
end

---清理过期道具的Response
function ItemBLL:OnRemoveCommonItemResponse(data)
    local removedList = data.ExpireList
    if (removedList) then
        for i = 1, #removedList do
            X3DataMgr.Remove(X3DataConst.X3Data.Item, removedList[i])
        end
    end
end

--endregion

---@public
---检查是否有足够的物品(一组)
---@param costList S3Int[] 消耗物品数量
---@return boolean
function ItemBLL:HasEnoughCost(costList)
    local costs = GameHelper.ToTable(costList)

    for _, v in pairs(costs) do
        if not self:SingleItemHasEnoughCost(v) then
            return false
        end
    end

    return true
end

---@public
---检查是否有足够的物品（单个）
---@param cost S3Int 消耗物品数量
---@return boolean
function ItemBLL:SingleItemHasEnoughCost(cost)
    local num = self:GetItemNum(cost.ID, nil, nil, true)
    return num >= cost.Num
end

---@public
---检查是否有足够的物品（单个）
---@param id int 物品id
---@param type int 物品类型
---@param num int 物品数量
---@return boolean
function ItemBLL:HasEnough(id, type, num)
    local cost = {}
    cost.ID = id
    cost.Type = type
    cost.Num = num
    return self:SingleItemHasEnoughCost(cost)
end

---@public
---增加限时道具
function ItemBLL:AddSpItem(spItem)
    self.proxy:AddSpItem(spItem)
end

---@public
---根据道具Id获取限时道具信息
function ItemBLL:GetSpItemsById(itemCfgId)
    ---@type X3Data.SpItem[]
    local spItems = PoolUtil.GetTable()
    X3DataMgr.GetAll(X3DataConst.X3Data.SpItem, spItems)

    local result = {}
    for _, v in pairs(spItems) do
        local spItem = {}
        v:Encode(spItem)
        if spItem.Mid == itemCfgId and self:GetSpItemOverTime(spItem).TotalSeconds ~= 0 then
            table.insert(result, spItem)
        end
    end
    PoolUtil.ReleaseTable(spItems)
    return result
end

---@public
---根据道具类型获取限时道具信息
function ItemBLL:GetSpitemsByType(type)
    local spItemList = {}

    ---@type X3Data.SpItem[]
    local spItems = PoolUtil.GetTable()
    X3DataMgr.GetAll(X3DataConst.X3Data.SpItem, spItems)

    for k, v in pairs(spItems) do
        local spItem = {}
        v:Encode(spItem)

        local itemCfg = LuaCfgMgr.Get("Item", spItem.Mid)
        if itemCfg ~= nil then
            if itemCfg.Type == type and self:GetSpItemOverTime(spItem).TotalSeconds ~= 0 then
                table.insert(spItemList, #spItemList + 1, spItem)
            end
        else
            Debug.Log("itemCfg is null   itemCfgid: " .. spItem.Mid);
        end
    end

    table.sort(spItemList, function(a, b)
        if a.ExpTime == b.ExpTime then
            return a.Mid < b.Mid
        else
            return a.ExpTime < b.ExpTime
        end
    end)

    return spItemList
end

---@public
---获取限时道具剩余时间显示
function ItemBLL:GetSpItemEndTime(spItem)
    if spItem.ExpTime >= math.maxinteger then
        return nil, false, false, true
    end
    ---@type System.TimeSpan
    local currTime = self:GetSpItemOverTime(spItem)
    local retStr = ""
    local isGreaterHours = false
    local isEnd = false
    if currTime == nil then
        return retStr, isGreaterHours
    end

    if currTime.Days >= 1 then
        retStr = UITextHelper.GetUIText(UITextConst.UI_TEXT_5504, currTime.Days)
    elseif currTime.Hours >= 1 then
        retStr = UITextHelper.GetUIText(UITextConst.UI_TEXT_5505, currTime.Hours)
    elseif currTime.Minutes >= 1 then
        retStr = UITextHelper.GetUIText(UITextConst.UI_TEXT_5506, currTime.Minutes)
    elseif currTime.Seconds >= 1 then
        retStr = UITextHelper.GetUIText(UITextConst.UI_TEXT_5507, currTime.Seconds)
    else
        retStr = ""
        isEnd = true
    end

    local hours = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.STAMINATIMEICON) or 168

    if currTime.TotalHours >= hours then
        isGreaterHours = true
    end

    return retStr, isGreaterHours, isEnd, false
end

---@public
---获取限时道具剩余时间 {Days, Hours, Minutes, Seconds, TotalSeconds, TotalHours}
---@return table
function ItemBLL:GetSpItemOverTime(spItem)
    --local endTime = CS.System.DateTimeOffset.FromUnixTimeSeconds(spItem.ExpTime):AddSeconds(1)
    --local curTime = endTime - GrpcMgr.GetServerTime()
    --return curTime

    if spItem.ExpTime >= math.maxinteger then
        return { TotalSeconds = -1 }
    end

    --TODO 这里以前就有+1需求不明
    local endTimeStamp = spItem.ExpTime + 1
    local curTimeStamp = TimerMgr.GetCurTimeSeconds()
    local totalSec = endTimeStamp - curTimeStamp
    local d, h, m, s = GameHelper.GetDateBySeconds(totalSec)
    return { Days = d, Hours = h, Minutes = m, Seconds = s, TotalSeconds = math.max(totalSec, 0), TotalHours = totalSec // 3600 }
end

---@public
---获取道具数量格式化显示
function ItemBLL:SetItemNumShow(mSelf, itemId, itemType, roleId, haveNumText, haveOrNotText)
    ---@type cfg.Item
    local itemCfg
    ---@type cfg.ItemType
    local typeCfg

    if itemType then
        itemCfg = self:GetItemShowCfg(itemId, itemType)
        typeCfg = LuaCfgMgr.Get("ItemType", itemType)
    else
        itemCfg = LuaCfgMgr.Get("Item", itemId)
        typeCfg = LuaCfgMgr.Get("ItemType", (itemCfg or {}).Type)
    end

    if itemCfg == nil or typeCfg == nil then
        return
    end

    local haveNum = self:GetItemNum(itemId, itemType, roleId)

    if typeCfg.TipsShowType == 1 then
        mSelf:SetActive(haveNumText, true)
        mSelf:SetActive(haveOrNotText, false)
        ---暂时不拆ItemBLL
        if BllMgr.GetOthersBLL():IsMainPlayer() then
            mSelf:SetText(haveNumText, UITextConst.UI_TEXT_5708, haveNum)
        else
            mSelf:SetActive(haveNumText, false)
        end
    elseif typeCfg.TipsShowType == 2 then
        mSelf:SetActive(haveNumText, false)
        mSelf:SetActive(haveOrNotText, true)
        local haveItem = false

        if itemCfg.Type == 60 then
            haveItem = BllMgr.GetWeaponBLL():GetServerWeapon(itemCfg.ID) ~= nil
        elseif itemCfg.Type == 101 then
            ---LYDJS-27152 去除限时道具 皮肤激活道具 IntExtra1 改为 ConnectID -jianxin
            local skinState = BllMgr.GetFashionBLL():GetFashionIsUnlock(itemCfg.ConnectID)
            haveItem = skinState == 1
        elseif itemCfg.Type == 103 then
            haveItem = BllMgr.GetCollectionRoomBLL():IsObtain(itemCfg.ID, roleId, false)
        elseif itemCfg.Type == 104 then
            haveItem = BllMgr.GetCollectionRoomBLL():IsObtain(itemCfg.ID, roleId, true)
        elseif itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_PHOTO_BACKGROUND then
            local item = BllMgr.GetPhotoSystemBLL():GetItemInfo(itemCfg.ID)
            haveItem = item ~= nil
        elseif itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_HEADICON then
            haveItem = SelfProxyFactory.GetPlayerInfoProxy():CheckIfHeadItemOwned(itemCfg.ID)
        else
            haveItem = haveNum > 0
        end

        if haveItem then
            mSelf:SetText(haveOrNotText, UITextConst.UI_TEXT_5739)
        else
            mSelf:SetText(haveOrNotText, UITextConst.UI_TEXT_5740)
        end
        mSelf:SetValue(haveOrNotText, haveItem)
    else
        mSelf:SetActive(haveNumText, false)
        mSelf:SetActive(haveOrNotText, false)
    end
end

---@public
---获取道具显示名字
function ItemBLL:GetItemShowName(itemId, itemType)
    ---@type cfg.ItemType
    local typeCfg = LuaCfgMgr.Get("ItemType", itemType or 0)
    if typeCfg ~= nil and not string.isnilorempty(typeCfg.ConnectTable) then
        local cfg = LuaCfgMgr.Get(typeCfg.ConnectTable, itemId)
        if cfg and cfg[typeCfg.OverrideName] ~= nil and cfg[typeCfg.OverrideName] ~= 0 then
            return cfg[typeCfg.OverrideName]
        end
    end

    return (LuaCfgMgr.Get("Item", itemId or 0) or {}).Name
end

---@public
---获取道具显示图标
---@return cfg.Item
function ItemBLL:GetItemShowCfg(itemId, itemType)
    ---@type cfg.ItemType
    local typeCfg = LuaCfgMgr.Get("ItemType", itemType or 0)
    if typeCfg ~= nil and not string.isnilorempty(typeCfg.ConnectTable) then
        local cfg = LuaCfgMgr.Get(typeCfg.ConnectTable, itemId)
        if cfg and cfg[typeCfg.ConnectItem] ~= nil and cfg[typeCfg.ConnectItem] ~= 0 then
            return LuaCfgMgr.Get("Item", cfg[typeCfg.ConnectItem])
        end
    end

    return LuaCfgMgr.Get("Item", itemId or 0)
end

---@public
---发送体力道具使用协议
function ItemBLL:CTS_UsePowerSpItem(spItemList)
    local messageBody = {}
    messageBody.SpList = spItemList
    GrpcMgr.SendRequest(RpcDefines.UsePowerSpItemRequest, messageBody)
end

function ItemBLL:IsPackageItem(itemType)
    return itemType == X3_CFG_CONST.ITEM_TYPE_PACKAGE_MANUAL or
            itemType == X3_CFG_CONST.ITEM_TYPE_PACKAGE_AUTOMATIC
end

function ItemBLL:CanOpenPackage(itemId)
    local packageCfg = LuaCfgMgr.Get("ItemTreasure", itemId)
    return packageCfg ~= nil and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(packageCfg.Condition)
end

---@param rewards pbcmessage.S3Int[]
function ItemBLL:OnAddItemOverLimit(rewards)
    if rewards == nil or #rewards == 0 then
        return
    end

    for i = 1, #rewards do
        ---@type cfg.Item
        local cfg = LuaCfgMgr.Get("Item", rewards[i].Id)
        ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_SPECIALTYPE_OVERGETTIPS, function()
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5804, UITextHelper.GetUIText(cfg.Name))
            ErrandMgr.End(X3_CFG_CONST.POPUP_SPECIALTYPE_OVERGETTIPS)
        end)
    end
end

---@param reply pbcmessage.ItemTransUpdateReply
function ItemBLL:OnItemTransUpdateCallBack(reply)
    if self.itemTransList and reply.OpReason ~= X3_CFG_CONST.REASON_GM and reply.OpReason ~= X3_CFG_CONST.REASON_CMS_GM and reply.OpReason ~= X3_CFG_CONST.REASON_FIX_DATA then
        table.insert(self.itemTransList, reply)
    end
end

---@param rewardList pbcmessage.S3Int[]
---@param transDataList pbcmessage.ItemTrans[]
---@return pbcmessage.S3Int[],table<string,pbcmessage.S3Int[]>
function ItemBLL:GetShowRewardAndTransReward(rewardList, transDataList)
    if #self.itemTransList <= 0 and (not transDataList or #transDataList <= 0) then
        return rewardList, nil
    end

    local itemTransList = PoolUtil.GetTable()
    for i = 1, #self.itemTransList do
        table.insert(itemTransList, self.itemTransList[i])
    end
    table.clear(self.itemTransList)

    if transDataList then
        for i = 1, #transDataList do
            table.insert(itemTransList, transDataList[i])
        end
    end

    local transRewardDic = {}
    local removeIdxTab = {}
    for i = 1, #itemTransList do
        ---@type pbcmessage.ItemTransUpdateReply
        local transData = itemTransList[i]
        local key = self:GetTransItemKey(transData.TransFrom.Id, transData.TransFrom.Type, transData.TransFrom.Num)
        table.clear(removeIdxTab)
        for j = 1, #transData.TransAdded do
            local reward = transData.TransAdded[j]
            local removeIdx = self:GetRemoveIdx(rewardList, reward)
            if transRewardDic[key] ~= nil then
                table.insert(transRewardDic[key], reward)
            end
            if removeIdx then
                table.remove(rewardList, removeIdx)
                table.insert(removeIdxTab, removeIdx)
            end
        end
        if transRewardDic[key] == nil then
            transRewardDic[key] = transData.TransAdded
        end
        transData.TransFrom._isTrans = true
        if #removeIdxTab > 0 then
            table.insert(rewardList, removeIdxTab[1], transData.TransFrom)
        end
    end
    PoolUtil.ReleaseTable(itemTransList)

    return rewardList, transRewardDic
end

---@param rewardList pbcmessage.S3Int[]
---@param removeReward pbcmessage.S3Int
function ItemBLL:GetRemoveIdx(rewardList, removeReward)
    local removeIdx = nil
    for i = 1, #rewardList do
        local reward = rewardList[i]
        if reward.Id == removeReward.Id and reward.Type == removeReward.Type and reward.Num == removeReward.Num then
            removeIdx = i
            break
        end
    end
    return removeIdx
end

---@param transRewardDic table<string,pbcmessage.S3Int[]>
---@param transItem  pbcmessage.S3Int 转换前的道具
---@return pbcmessage.S3Int[]
function ItemBLL:GetTransItemList(transRewardDic, transItem)
    if transRewardDic == nil then
        return nil
    end
    if transItem._isTrans then
        local key = self:GetTransItemKey(transItem.Id, transItem.Type, transItem.Num)
        if transRewardDic[key] ~= nil then
            return transRewardDic[key]
        end
    end
    return nil
end

---@param id int ID
---@param itemType int itemType
---@param itemNum int itemNum
---@return string TransItemKey
function ItemBLL:GetTransItemKey(id, itemType, itemNum)
    local key = string.format("%d_%d_%d", id, itemType, itemNum)
    return key
end

---@param itemId int 宝箱ID
---@return table<cfg.s3int> 其中新增isMust 字段代表必定掉落的奖励
function ItemBLL:GetPackItemRewardList(itemId)
    local result = LuaCfgMgr.Get("ItemTreasureDropList", itemId)
    if not result then
        result = {}
        Debug.LogError("ItemTreasureDropList Cfg is nil , Id => ", itemId)
    end
    return result
end

---@param itemId int 宝箱ID
---@return string|nil 概率公示文本，如果没有则不显示概率公示
function ItemBLL:GetPRDetail(itemId)
    local result
    local ratioText
    local packageCfg = LuaCfgMgr.Get("ItemTreasure", itemId)
    if not packageCfg then
        return result, ratioText
    end
    if packageCfg.PRDetail == 1 then
        if packageCfg.PRDetailShow ~= 0 then
            result = UITextHelper.GetUIText(packageCfg.PRDetailShow)
        else
            local showItemList = self:GetPackItemRewardList(itemId)
            if showItemList then
                result = ""
                ratioText = ""
                for i, v in ipairs(showItemList) do
                    result = string.concat(result, UITextHelper.GetUIText(UITextConst.UI_TEXT_5792, UITextHelper.GetUIText(BllMgr.GetItemBLL():GetItemShowName(v.ID, v.Type)), v.Num), "\n")
                    local num = v.DroppingProbability * 100
                    local formattedNum = (num == math.floor(num)) and string.format("%.0f", num) or string.format("%.1f", num)
                    ratioText = string.concat(ratioText, formattedNum, "%\n")
                end
            end
        end
    end
    return result, ratioText
end

return ItemBLL
