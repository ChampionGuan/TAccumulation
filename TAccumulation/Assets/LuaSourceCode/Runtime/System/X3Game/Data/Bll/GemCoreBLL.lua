﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/3/14 15:08
---@class GemCoreBLL
local GemCoreBLL = class("GemCoreBLL", BaseBll)
---@type GemCoreProxy
local proxy = SelfProxyFactory.GetGemCoreProxy()

function GemCoreBLL:OnInit()
    proxy = SelfProxyFactory.GetGemCoreProxy()

    self.gemCoreRareRp = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.GEMCOREREDPOINTRARE)
    EventMgr.AddListener("OnGemCoreDataUpdate", self.OnGemCoreDataUpdate, self)
    EventMgr.AddListener(GemCoreConst.Event.GEM_CORE_LEVEL_UP, self.OnOpenCoreLevelTips, self)
    EventMgr.AddListener(GemCoreConst.Event.GEM_CORE_ADD, self.OnGemCoreAddCallBack, self)
    EventMgr.AddListener(GemCoreConst.Event.GEM_CORE_REMOVE, self.OnGemCoreRemoveCallBack, self)
end

---芯核背槽位数据
---@return  table<cfg.GemCoreSite>
function GemCoreBLL:GetAllGemCoreSetList(isHaveAll)
    if isHaveAll == nil then
        isHaveAll = true
    end
    local allGemCoreSetCfg = LuaCfgMgr.GetAll("GemCoreSite")
    local retTab = {}
    if isHaveAll then
        ---第一位塞一个全部的
        retTab[1] = {
            SiteIcon = 0, ---控制UI Index
            ID = 0, ---位置ID
            SiteID = 0,
        }
    end
    for k, v in pairs(allGemCoreSetCfg) do
        table.insert(retTab, v)
    end
    return retTab
end

---@param cardId int
---@return table<cfg.GemCoreSite>
function GemCoreBLL:GetAllGemCoreSetListByCardId(cardId)
    local cardBaseInfo = LuaCfgMgr.Get("CardBaseInfo", cardId)
    local ret = {}
    if cardBaseInfo then
        local cardPosTypeCfg = LuaCfgMgr.Get("CardPosType", cardBaseInfo.PosType)
        if cardPosTypeCfg and cardPosTypeCfg.GemCoreSiteID then
            for i = 1, #cardPosTypeCfg.GemCoreSiteID do
                local gemCoreSiteCfg = LuaCfgMgr.Get("GemCoreSite", cardPosTypeCfg.GemCoreSiteID[i])
                if gemCoreSiteCfg then
                    table.insert(ret, gemCoreSiteCfg)
                end
            end
        end
    end
    return ret
end

---@return table<cfg.FormationTag>  返回页签
function GemCoreBLL:GetAllFormationDataList()
    local retTab = {}
    local temp = {}
    local allGemCoreSuit = LuaCfgMgr.GetAll("FormationTag")
    for k, v in pairs(allGemCoreSuit) do
        table.insert(retTab, v)
    end
    table.sort(retTab, function(a, b)
        return a.FormationTag < b.FormationTag
    end)
    table.insert(retTab, 1, temp)
    return retTab
end

---@public 芯核背包排序
---@param gemCoreList table
---@param sortType GemCoreConst.GemCoreSortType
---@param sortOrderType bool True:正序 false:倒序
---@return table
function GemCoreBLL:SortGemCoreList(gemCoreList, sortType, sortOrderType)
    if sortOrderType ~= false then
        ---默认正序
        sortOrderType = true
    end
    table.sort(gemCoreList, function(a, b)
        local coreIsBind1 = 0
        if SelfProxyFactory.GetGemCoreProxy():GetGemCoreIsSet(a:GetPrimaryValue()) == GemCoreConst.GemCoreSetType.EquipType then
            coreIsBind1 = 1
        end
        local coreIsBind2 = 0
        if SelfProxyFactory.GetGemCoreProxy():GetGemCoreIsSet(b:GetPrimaryValue()) == GemCoreConst.GemCoreSetType.EquipType then
            coreIsBind2 = 1
        end
        if coreIsBind1 ~= coreIsBind2 then
            return coreIsBind1 > coreIsBind2
        end
    end)
    if sortType == GemCoreConst.GemCoreSortType.Level then
        proxy:SortGemCoreBySortType(gemCoreList, sortType)
    elseif sortType == GemCoreConst.GemCoreSortType.Rare then
        proxy:SortGemCoreBySortType(gemCoreList, sortType)
    end
    if not sortOrderType then
        gemCoreList = table.reverse_table(gemCoreList)
    end
    return gemCoreList
end

function GemCoreBLL:GetCoreExpGoldenNum()
    return LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.GEMCOREEXPGOLDEN)
end

function GemCoreBLL:OnOpenCoreLevelTips(oldData,rewards)
    UIMgr.Open(UIConf.DevelopCoreLevelUpTipsWnd, oldData,rewards)
end

function GemCoreBLL:OnGemCoreAddCallBack(gemCoreId)
    if RedPointMgr.IsInit() then
        self:ClearGemCoreNewRp(gemCoreId)
        return
    end
    local gemCoreBaseInfoCfg = proxy:GetGemCoreCfgById(gemCoreId)
    if gemCoreBaseInfoCfg == nil or not table.containsvalue(self.gemCoreRareRp, gemCoreBaseInfoCfg.Rare) then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_CORE_NEW, self:CheckGemCoreIsNew(gemCoreId) and 1 or 0, gemCoreId)
end

function GemCoreBLL:OnGemCoreRemoveCallBack(gemCoreId)
    self:ClearGemCoreNewRp(gemCoreId, true)
end

function GemCoreBLL:GetCoreExpItemDataList(reTab)
    if reTab == nil then
        reTab = {}
    end
    local itemIdList = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.GEMCOREEXPITEM)
    for i = #itemIdList, 1, -1 do
        local itemId = itemIdList[i]
        local itemData = BllMgr.GetItemBLL():GetItem(itemId)
        if itemData.Type == 0 then
            local cfg = LuaCfgMgr.Get("Item", itemId)
            itemData.Type = cfg.Type
        end
        if itemData and itemData.Num and itemData.Num > 0 then
            table.insert(reTab, 1, {
                Id = itemData.Id,
                Type = itemData.Type,
                Num = itemData.Num,
                CurSelectNum = 0,
            })
        end
    end
    return reTab
end

---获取当前芯核数量
function GemCoreBLL:GetCurCoreNum()
   return proxy:GetCurCoreNum()
end

---消除New红点用
function GemCoreBLL:ClearGemCoreNewRp(coreId, isRemove)
    if not isRemove then
        RedPointMgr.Save(1, X3_CFG_CONST.RED_NEW_CORE_NEW, coreId)
    else
        RedPointMgr.Remove(X3_CFG_CONST.RED_NEW_CORE_NEW, coreId)
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_CORE_NEW, 0, coreId)
end

--region 服务器消息相关

---芯核升级
function GemCoreBLL:CTS_GemCoreLevelUp(coreId, constItem)
    local temReq = PoolUtil.GetTable()
    temReq.CoreID = coreId
    temReq.Materials = constItem
    GrpcMgr.SendRequest(RpcDefines.GemCoreLevelUpRequest, temReq)
    PoolUtil.ReleaseTable(temReq)
end

---@param coreID number 芯核唯一ID
---@param lock bool 是否锁定
function GemCoreBLL:GemCoreLockRequest(coreID, lock)
    local temReq = PoolUtil.GetTable()
    temReq.CoreID = coreID
    temReq.isLock = lock
    GrpcMgr.SendRequest(RpcDefines.GemCoreLockRequest, temReq, true)
    PoolUtil.ReleaseTable(temReq)
end

---分解芯核
function GemCoreBLL:GemCoreBreakRequest(CoreIDs)
    local temReq = PoolUtil.GetTable()
    temReq.CoreIDs = CoreIDs
    GrpcMgr.SendRequest(RpcDefines.GemCoreBreakRequest, temReq, true)
    PoolUtil.ReleaseTable(temReq)
end

--endregion

---判断芯核是否满级
---@param coreId int 芯核id
---@return boolean true满级 false 没满级
function GemCoreBLL:CoreLevelIsMax(coreId)
    local coreData = SelfProxyFactory.GetGemCoreProxy():GetGemCoreDataByGemCoreId(coreId)
    if coreData == nil then
        return false
    end
    local gemCoreBaseInfo = LuaCfgMgr.Get("GemCoreBaseInfo", coreData:GetTblID())
    local gemCoreRare = LuaCfgMgr.Get("GemRare", gemCoreBaseInfo.Rare)
    return coreData.level >= gemCoreRare.MaxLevel
end

function GemCoreBLL:CheckCondition(conditionType, params, iDataProvider)
    local ret = false
    local retNum = 0
    if conditionType == X3_CFG_CONST.CONDITION_CARD_GEMCORENUM then
        retNum = self:GetCoreListBySiteIdAndLevel(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]), tonumber(params[4]))
        ret = tonumber(params[5]) == -1 or retNum >= tonumber(params[5])
    end
    return ret, retNum
end

function GemCoreBLL:GetCoreListBySiteIdAndLevel(suiId, rare, minLevel, maxLevel)
    if suiId == -1 then
        suiId = 0
    end
    local gemDataList = proxy:GetCoreDataList(suiId)
    local retNum = 0
    for i = 1, #gemDataList do
        local coreData = gemDataList[i]
        local gemCoreBaseInfo = LuaCfgMgr.Get("GemCoreBaseInfo", coreData:GetTblID())
        if gemCoreBaseInfo and (rare == -1 or gemCoreBaseInfo.Rare >= rare) and ConditionCheckUtil.IsInRange(coreData:GetLevel(), minLevel, maxLevel) then
            retNum = retNum + 1
        end
    end
    return retNum
end

function GemCoreBLL:CheckGemCoreIsNew(gemCoreId)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_NEW_CORE_NEW, gemCoreId)
    return redValue == 0
end

---获取芯核最大等级
---@param coreId int  芯核实例id
---@return  int  最大等级
function GemCoreBLL:GetCoreMaxLevel(coreId)
    local coreData = SelfProxyFactory.GetGemCoreProxy():GetGemCoreDataByGemCoreId(coreId)
    if coreData == nil then
        return false
    end
    local gemCoreBaseInfo = LuaCfgMgr.Get("GemCoreBaseInfo", coreData:GetTblID())
    local gemCoreRare = LuaCfgMgr.Get("GemRare", gemCoreBaseInfo.Rare)
    return gemCoreRare.MaxLevel
end

---获取芯核升级道具Item
---@return table<int>  itemId List
function GemCoreBLL:GetGemCoreItemArray()
    if not self.gemCoreItemArray then
        local gemCoreItemArray = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.GEMCOREEXPITEM)
        ---@type table<int> 芯核经验道具ID列表
        self.gemCoreItemArray = {}
        for i, v in ipairs(gemCoreItemArray) do
            local data = BllMgr.GetItemBLL():GetLocalItem(v)
            table.insert(self.gemCoreItemArray, data)
        end
        table.sort(self.gemCoreItemArray, function(a, b)
            return a.IntExtra1 > b.IntExtra1
        end)
    end
    return self.gemCoreItemArray
end

---@public 传入一组唯一ID，返回可以分解的东西
function GemCoreBLL:GetResolveRewards(IDs)
    local gold = 0
    local exp = 0
    local goldExp = 0
    local result = {}
    local tempResult = {}
    local resolveExp = 0
    for i, v in ipairs(IDs) do
        local dataConfig = proxy:GetGemCoreDataByGemCoreId(v)
        exp = dataConfig:GetResolveAddExp() + exp
        local gemCoreBaseInfo = LuaCfgMgr.Get("GemCoreBaseInfo", dataConfig:GetTblID())
        local gemRareCfg = LuaCfgMgr.Get("GemRare", gemCoreBaseInfo.Rare)
        resolveExp = resolveExp + gemRareCfg.ResolveExp
    end
    goldExp = exp - resolveExp
    local tempExp = exp
    local gemCoreItemArray = self:GetGemCoreItemArray()
    for i = 1, #gemCoreItemArray do
        if gemCoreItemArray[i].IntExtra1 <= tempExp then
            local num, leftExp = math.modf(tempExp / gemCoreItemArray[i].IntExtra1)
            tempExp = math.floor(leftExp * gemCoreItemArray[i].IntExtra1 + 0.5)--四舍五入
            if tempResult[gemCoreItemArray[i].ID] == nil then
                tempResult[gemCoreItemArray[i].ID] = { ID = gemCoreItemArray[i].ID, Num = 0, Type = 0, exp = gemCoreItemArray[i].IntExtra1 }
            end
            tempResult[gemCoreItemArray[i].ID].Num = tempResult[gemCoreItemArray[i].ID].Num + num
        end
    end
    gold = goldExp * self:GetCoreExpGoldenNum()
    for k, v in pairs(tempResult) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return a.exp > b.exp
    end)
    if gold > 0 then
        table.insert(result, { ID = 1, Num = gold, Type = 0 })
    end
    return result
end
---@public 芯核是否在大螺旋中有装备
---@param Id number 芯核实例ID
function GemCoreBLL:GetIsUsedInHunter(Id)
    local hunterCores = BllMgr.GetHunterContestBLL():GetAllUseGemCore()
    for i, v in ipairs(hunterCores) do
        if v == Id then
            return true
        end
    end
    return false
end

--endregion
return GemCoreBLL