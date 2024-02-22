﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/3/14 14:44
---@class GemCoreProxy  芯核Proxy
local GemCoreProxy = class("GemCoreProxy", BaseProxy)

---等级排序
---@param gemCoreData1 X3Data.GemCore
---@param gemCoreData2 X3Data.GemCore
---@return boolean
local function SortGemCoreListByLevel(gemCoreData1, gemCoreData2)
    ---芯核强化等级
    if gemCoreData1:GetLevel() ~= gemCoreData2:GetLevel() then
        return gemCoreData1:GetLevel() > gemCoreData2:GetLevel()
    end
    ---@type cfg.GemCoreBaseInfo
    local gemCoreBaseInfo1 = LuaCfgMgr.Get("GemCoreBaseInfo", gemCoreData1:GetTblID())
    ---@type cfg.GemCoreBaseInfo
    local gemCoreBaseInfo2 = LuaCfgMgr.Get("GemCoreBaseInfo", gemCoreData2:GetTblID())
    ---芯核品质
    if gemCoreBaseInfo1.Rare ~= gemCoreBaseInfo2.Rare then
        return gemCoreBaseInfo1.Rare > gemCoreBaseInfo2.Rare
    end
    ---芯核Tag
    if gemCoreBaseInfo1.FormationTag ~= gemCoreBaseInfo2.FormationTag then
        return gemCoreBaseInfo1.FormationTag < gemCoreBaseInfo2.FormationTag
    end
    if gemCoreBaseInfo1.ItemID ~= gemCoreBaseInfo2.ItemID then
        return gemCoreBaseInfo1.ItemID < gemCoreBaseInfo2.ItemID
    end
    return gemCoreData1:GetPrimaryValue() < gemCoreData2:GetPrimaryValue()
end

---品质排序
---@param gemCoreData1 X3Data.GemCore
---@param gemCoreData2 X3Data.GemCore
---@return boolean
local function SortGemCoreListByRare(gemCoreData1, gemCoreData2)
    ---@type cfg.GemCoreBaseInfo
    local gemCoreBaseInfo1 = LuaCfgMgr.Get("GemCoreBaseInfo", gemCoreData1:GetTblID())
    ---@type cfg.GemCoreBaseInfo
    local gemCoreBaseInfo2 = LuaCfgMgr.Get("GemCoreBaseInfo", gemCoreData2:GetTblID())
    ---芯核品质
    if gemCoreBaseInfo1.Rare ~= gemCoreBaseInfo2.Rare then
        return gemCoreBaseInfo1.Rare > gemCoreBaseInfo2.Rare
    end
    ---芯核强化等级
    if gemCoreData1:GetLevel() ~= gemCoreData2:GetLevel() then
        return gemCoreData1:GetLevel() > gemCoreData2:GetLevel()
    end
    ---芯核Tag
    if gemCoreBaseInfo1.FormationTag ~= gemCoreBaseInfo2.FormationTag then
        return gemCoreBaseInfo1.FormationTag < gemCoreBaseInfo2.FormationTag
    end
    if gemCoreBaseInfo1.ItemID ~= gemCoreBaseInfo2.ItemID then
        return gemCoreBaseInfo1.ItemID < gemCoreBaseInfo2.ItemID
    end
    return gemCoreData1:GetPrimaryValue() < gemCoreData2:GetPrimaryValue()
end

---@param gemCoreData pbcmessage.GemCore
local function GetGemCoreResolveExp(gemCoreData)
    local retExp = 0
    local gemCoreBaseInfoCfg = LuaCfgMgr.Get("GemCoreBaseInfo", gemCoreData.TblID)
    local gemRareCfg = LuaCfgMgr.Get("GemRare", gemCoreBaseInfoCfg.Rare)
    for i = gemCoreData.Level - 1, 0, -1 do
        local gemCoreLevelCfg = LuaCfgMgr.Get("GemCoreLevel", gemCoreBaseInfoCfg.Rare, i)
        if gemCoreLevelCfg then
            retExp = retExp + gemCoreLevelCfg.NextLvExp
        end
    end
    retExp = retExp + gemCoreData.Exp
    retExp = math.floor(retExp * gemRareCfg.ResolveExpRate / 1000)
    retExp = retExp + gemRareCfg.ResolveExp
    return retExp
end

---属性的value转换
local function GetGemAttr(attr)
    local tblDropID = (attr >> 40) & 0xFFFFFF
    local randCount = (attr >> 32) & 0xFF
    local val = attr & 0xFFFFFFFF
    return tblDropID, randCount, val
end

---@param serverData pbcmessage.GemCore
---@param uid int playerUid
local function AddOrUpdateGemCore(serverData, uid)
    if uid == nil then
        serverData.ResolveAddExp = GetGemCoreResolveExp(serverData)
        ---@type X3Data.GemCore
        local gemCore = X3DataMgr.Get(X3DataConst.X3Data.GemCore, serverData.Id)
        if gemCore == nil then
            gemCore = X3DataMgr.AddByPrimary(X3DataConst.X3Data.GemCore, serverData, serverData.Id)
        else
            gemCore:DecodeByField(serverData)
        end
    else
        local condition = PoolUtil.GetTable()
        condition[X3DataConst.X3DataField.GemCore.Id] = serverData.Id
        condition[X3DataConst.X3DataField.GemCore.PlayerUid] = uid
        ---@type X3Data.GemCore
        local gemCore = X3DataMgr.GetByCondition(X3DataConst.X3Data.GemCore, condition)
        PoolUtil.ReleaseTable(condition)
        if gemCore == nil then
            gemCore = X3DataMgr.Add(X3DataConst.X3Data.GemCore, serverData)
            gemCore:SetPlayerUid(uid)
            gemCore:SetIsDisablePrimary(true)
        else
            gemCore:DecodeByField(serverData)
        end
    end
end

local function RemoveGemCore(gemCoreId, uid)
    if uid == nil then
        local removeSuccess = X3DataMgr.Remove(X3DataConst.X3Data.GemCore, gemCoreId)
        if not removeSuccess then
            Debug.LogError("RemoveGemCore is fail Id:", tostring(gemCoreId))
        end
    else
        local condition = PoolUtil.GetTable()
        condition[X3DataConst.X3DataField.GemCore.PlayerUid] = uid
        X3DataMgr.RemoveByCondition(X3DataConst.X3Data.GemCore, condition)
        PoolUtil.ReleaseTable(condition)
    end
end

---初始化
---@param owner ProxyFactory
function GemCoreProxy:OnInit(owner)
    self.super.OnInit(self, owner)
    ---@type X3Data.GemCoreData
    self.gemCoreOtherData = nil
    ---@type int 芯核升级最大槽位
    self.maxConstCoreLevelNum = 12

    BllMgr.GetGemCoreBLL()
    self:Subscribe()
end

function GemCoreProxy:OnClear()
    self:UnSubscribe()
    X3DataMgr.RemoveAll(X3DataConst.X3Data.SCore)
end

function GemCoreProxy:Subscribe()
    X3DataMgr.SubscribeWithChangeFlag(X3DataConst.X3Data.GemCore, self.OnGemCoreAdd, self, X3DataConst.X3DataChangeFlag.Add)
    X3DataMgr.SubscribeWithChangeFlag(X3DataConst.X3Data.GemCore, self.OnGemCoreRemove, self, X3DataConst.X3DataChangeFlag.Remove)
    X3DataMgr.Subscribe(X3DataConst.X3Data.GemCore, self.OnGemCoreLevelChanged, self, X3DataConst.X3DataField.GemCore.Level)
    X3DataMgr.Subscribe(X3DataConst.X3Data.GemCore, self.OnGemCoreExpChanged, self, X3DataConst.X3DataField.GemCore.Exp)
    X3DataMgr.Subscribe(X3DataConst.X3Data.GemCore, self.OnGemCoreAttrChanged, self, X3DataConst.X3DataField.GemCore.Attrs)
    X3DataMgr.Subscribe(X3DataConst.X3Data.GemCoreData, self.OnGemCoreLockChange, self, X3DataConst.X3DataField.GemCoreData.LockCore)
    X3DataMgr.Subscribe(X3DataConst.X3Data.GemCoreData, self.OnGemCoreBindCardChange, self, X3DataConst.X3DataField.GemCoreData.BindCard)
end

function GemCoreProxy:UnSubscribe()
    X3DataMgr.UnsubscribeWithTarget(self)
end

---芯核id变更
---@param data X3Data.GemCore
---@param changeFlag X3DataConst.X3DataChangeFlag
function GemCoreProxy:OnGemCoreAdd(data, changeFlag)
    local gemCoreId = data:GetPrimaryValue()
    if data:GetPlayerUid() ~= 0 then
        return
    end
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_ADD, gemCoreId)
end

---芯核id变更
---@param data X3Data.GemCore
---@param changeFlag X3DataConst.X3DataChangeFlag
function GemCoreProxy:OnGemCoreRemove(data, changeFlag)
    local gemCoreId = data:GetPrimaryValue()
    if data:GetPlayerUid() ~= 0 then
        return
    end
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_REMOVE, gemCoreId)
end

---芯核Level等级变更
---@param data X3Data.GemCore
function GemCoreProxy:OnGemCoreLevelChanged(data)
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_LEVEL_CHANGE, data:GetPrimaryValue())
end

---芯核Exp经验变更
---@param data X3Data.GemCore
function GemCoreProxy:OnGemCoreExpChanged(data)
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_EXP_CHANGE)
end

---芯核属性变更
---@param data X3Data.GemCore
function GemCoreProxy:OnGemCoreAttrChanged(data)
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_ATTR_CHANGE)
end

---芯核锁定状态改变
---@param data X3Data.GemCoreData
function GemCoreProxy:OnGemCoreLockChange(data)
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_LOCK_CHANGE)
end

---芯核锁定状态改变
---@param data X3Data.GemCoreData
function GemCoreProxy:OnGemCoreBindCardChange(data)
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_BIND_CARD_CHANGE)
end

--region 服务器协议相关
---@param msg pbcmessage.GemCoreData
function GemCoreProxy:OnEnterGameReply(msg)
    self:SetGemCoreDataInfo(msg)
end

---@param reply pbcmessage.GetGemCoreDataReply
function GemCoreProxy:OnGetGemCoreDataReply(reply)
    self:SetGemCoreDataInfo(reply.Data)
end

---@param playerUid int 玩家uid
---@param serverCoreData pbcmessage.GemCore
function GemCoreProxy:InitOtherGemCoreData(playerUid, serverCoreData)
    AddOrUpdateGemCore(serverCoreData, playerUid)
end

---@param playerUid int 玩家uid
function GemCoreProxy:ClearOtherGemCoreData(playUid)
    RemoveGemCore(nil, playUid)
end

---分解芯核Reply
---@param reply pbcmessage.GemCoreBreakReply
function GemCoreProxy:OnGemCoreBreakReply(reply)
    for i = 1, #reply.CoreIDs do
        local gemCoreId = reply.CoreIDs[i]
        RemoveGemCore(gemCoreId)
    end
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_BREAK)
end

---芯核数据update
---@param reply  pbcmessage.GemCoreUpdateReply
function GemCoreProxy:OnGemCoreUpdateReply(reply)
    AddOrUpdateGemCore(reply.UpdatedCore)
end

---芯核升级
---@param msg pbcmessage.GemCoreLevelUpReply
function GemCoreProxy:OnCoreLevelUpReply(msg)
    ---@type X3Data.GemCore
    local oldGemCoreData = X3DataMgr.Get(X3DataConst.X3Data.GemCore, msg.UpdatedCore.Id)
    if oldGemCoreData then
        oldGemCoreData = oldGemCoreData:Clone()
    else
        Debug.LogError("OnCoreLevelUpReply error gemCoreData is nil Id:", tostring(msg.UpdatedCore.Id))
        return
    end
    AddOrUpdateGemCore(msg.UpdatedCore)
    for i = 1, #msg.CostCoreIDs do
        local gemCoreId = msg.CostCoreIDs[i]
        RemoveGemCore(gemCoreId)
    end
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_INTENSIFY, oldGemCoreData)
    local rewards = msg.Rewards
    local hadRewards = not table.isnilorempty(msg.Rewards)
    if oldGemCoreData:GetLevel() ~= msg.UpdatedCore.Level then
        EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_LEVEL_UP, oldGemCoreData,rewards)
    else
        if hadRewards then
            UICommonUtil.ShowRewardPopTips(rewards, 2,false,nil,nil,true)
        end
    end
end

---芯核解锁或锁定
---@param request pbcmessage.GemCoreLockRequest
function GemCoreProxy:OnGemCoreLockReply(request)
    self.gemCoreOtherData:AddOrUpdateLockCoreValue(request.CoreID, request.isLock)
    EventMgr.Dispatch(GemCoreConst.Event.UPDATE_LOCK, request.CoreID, request.isLock)
end

---装备芯核
---@param reply pbcmessage.CardPutOnGemCoreReply
function GemCoreProxy:OnCardPutOnGemCoreReply(reply, takeOffGemCoreIdList)
    if takeOffGemCoreIdList then
        for i = 1, #takeOffGemCoreIdList do
            local gemCoreId = takeOffGemCoreIdList[i]
            self.gemCoreOtherData:RemoveBindCardValue(gemCoreId)
        end
    end
    for i = 1, #reply.CoreID do
        local gemCoreId = reply.CoreID[i]
        self.gemCoreOtherData:AddOrUpdateBindCardValue(gemCoreId, reply.CardID)
    end
end

---卸下芯核
---@param reply pbcmessage.CardTakeOffGemCoreReply
function GemCoreProxy:OnCardTakeOffGemCoreReply(reply)
    for i = 1, #reply.CoreID do
        local gemCoreId = reply.CoreID[i]
        self.gemCoreOtherData:RemoveBindCardValue(gemCoreId)
    end
end

---初始化芯核数据
---@param  serverData pbcmessage.GemCoreData
function GemCoreProxy:SetGemCoreDataInfo(serverData)
    if serverData == nil then
        return
    end
    self.gemCoreOtherData = X3DataMgr.GetOrAdd(X3DataConst.X3Data.GemCoreData)
    if serverData.BindCard then
        for k, v in pairs(serverData.BindCard) do
            self.gemCoreOtherData:AddOrUpdateBindCardValue(k, v)
        end
    end
    if serverData.LockCore then
        for k, v in pairs(serverData.LockCore) do
            self.gemCoreOtherData:AddOrUpdateLockCoreValue(k, v)
        end
    end
    if serverData.Cores then
        for k, v in pairs(serverData.Cores) do
            AddOrUpdateGemCore(v)
        end
    end
end
--endregion

---@param gemCorId int 芯核实例id
---@return X3Data.GemCore
function GemCoreProxy:GetGemCoreDataByGemCoreId(gemCorId, uid)
    local gemCoreData = nil
    local isPlayer = SelfProxyFactory.GetPlayerInfoProxy():GetUid() == uid
    if uid == nil or isPlayer then
        ---@type X3Data.GemCore
        gemCoreData = X3DataMgr.Get(X3DataConst.X3Data.GemCore, gemCorId)
    else
        local condition = PoolUtil.GetTable()
        condition[X3DataConst.X3DataField.GemCore.Id] = gemCorId
        condition[X3DataConst.X3DataField.GemCore.PlayerUid] = uid
        ---@type X3Data.GemCore
        gemCoreData = X3DataMgr.GetByCondition(X3DataConst.X3Data.GemCore, condition)
        PoolUtil.ReleaseTable(condition)
    end
    return gemCoreData
end

---@param gemCorId int 芯核实例id
---@return cfg.GemCoreBaseInfo
function GemCoreProxy:GetGemCoreCfgById(gemCorId, playerUid)
    local gemCoreData = self:GetGemCoreDataByGemCoreId(gemCorId, playerUid)
    if gemCoreData then
        local gemCoreCfg = LuaCfgMgr.Get("GemCoreBaseInfo", gemCoreData:GetTblID())
        return gemCoreCfg
    end
    return nil
end

---@param gemCoreID int  芯核实例id
---@return  bool  是否锁定
function GemCoreProxy:GetGemCoreIsLock(gemCoreID)
    local lockCoreDic = self.gemCoreOtherData:GetLockCore()
    if lockCoreDic == nil then
        return false
    end
    if lockCoreDic[gemCoreID] ~= nil then
        return lockCoreDic[gemCoreID]
    end
    return false
end
---@return number 获取芯核数量
function GemCoreProxy:GetCurCoreNum()
    return X3DataMgr.Count(X3DataConst.X3Data.GemCore)
end
---获取芯核全量数据
---@param siteId int 槽位id
---@param formationTag int FormationTag
---@param sortType GemCoreConst.GemCoreSortType 排序类型
---@param filterFunc function 筛选的条件function
---@param sortOrderType boolean  True:正序 false:倒序
---@return table<X3Data.GemCore>
function GemCoreProxy:GetCoreDataList(siteId, formationTag, sortType, filterFunc, sortOrderType)
    if siteId == nil then
        siteId = 0
    end
    if formationTag == nil then
        formationTag = 0
    end
    if sortOrderType == nil then
        sortOrderType = true
    end
    local ret = {}
    local sortFunction = SortGemCoreListByLevel
    if sortType == GemCoreConst.GemCoreSortType.Rare then
        sortFunction = SortGemCoreListByRare
    end
    X3DataMgr.GetAll(X3DataConst.X3Data.GemCore, ret, function(gemCoreData)
        local gemCoreCfgId = gemCoreData:GetTblID()
        ---@type cfg.GemCoreBaseInfo
        local gemCoreBaseInfoCfg = LuaCfgMgr.Get("GemCoreBaseInfo", gemCoreCfgId)
        if siteId ~= 0 and gemCoreBaseInfoCfg.SiteID ~= siteId then
            return false
        end
        if formationTag ~= 0 and gemCoreBaseInfoCfg.FormationTag ~= formationTag then
            return false
        end
        if filterFunc and not filterFunc(gemCoreData) then
            return false
        end
        return true
    end, sortFunction)
    if not sortOrderType then
        ret = table.reverse_table(ret)
    end
    return ret
end

---芯核列表排序
---@param gemCoreList table<X3Data.GemCore>
---@param sortType GemCoreConst.GemCoreSortType
function GemCoreProxy:SortGemCoreBySortType(gemCoreList, sortType)
    if sortType == GemCoreConst.GemCoreSortType.Level then
        table.sort(gemCoreList, SortGemCoreListByLevel)
    elseif sortType == GemCoreConst.GemCoreSortType.Rare then
        table.sort(gemCoreList, SortGemCoreListByRare)
    end
end

---芯核升级的最大槽位
---@return int
function GemCoreProxy:GetMaxConstCoreNum()
    return self.maxConstCoreLevelNum
end

---判断当前芯核是否已装备（已装备的话会返回装备的cardId）
---@param gemCoreId int 芯核实例id
---@return GemCoreConst.GemCoreSetType
function GemCoreProxy:GetGemCoreIsSet(gemCoreId)
    local bindCardDic = self.gemCoreOtherData:GetBindCard()
    if bindCardDic == nil then
        return GemCoreConst.GemCoreSetType.None
    end
    local bindCardId = bindCardDic[gemCoreId]
    if bindCardId == nil or bindCardId == 0 then
        return GemCoreConst.GemCoreSetType.None
    end
    return GemCoreConst.GemCoreSetType.EquipType, bindCardId
end

---获取芯核全部属性
---@param gemCoreId int 芯核实例id
---@param attrType  GemCoreConst.GemCoreAttrType
---@return table<int,int> attrId,attrValue
function GemCoreProxy:GetGemCoreAllAttr(gemCoreId, uid, attrType)
    local gemCoreData = self:GetGemCoreDataByGemCoreId(gemCoreId, uid)
    return self:GetGemCoreAllAttrByData(gemCoreData, attrType)
end

---@param  gemCoreData X3Data.GemCore
---@param attrType  GemCoreConst.GemCoreAttrType
---@return table<int,int> attrId,attrValue
function GemCoreProxy:GetGemCoreAllAttrByData(gemCoreData, attrType)
    local retAttrDic = {}
    local attrList = gemCoreData:GetAttrs()
    if attrList == nil then
        return retAttrDic
    end
    for i = 1, #attrList do
        local tblDropID, randCount, val = GetGemAttr(attrList[i])
        local gemCoreAttrDropCfg = LuaCfgMgr.Get("GemCoreAttrDrop", tblDropID)
        if gemCoreAttrDropCfg then
            ---@type table<cfg.GemCoreAttr>
            local gemCoreAttrCfgList = LuaCfgMgr.Get("GemCoreAttrByAttrID", gemCoreAttrDropCfg.AttrID)
            if #gemCoreAttrCfgList > 0 then
                if attrType == GemCoreConst.GemCoreAttrType.All or gemCoreAttrCfgList[1].AttrType == attrType then
                    if retAttrDic[gemCoreAttrDropCfg.Attr] == nil then
                        retAttrDic[gemCoreAttrDropCfg.Attr] = val
                    else
                        retAttrDic[gemCoreAttrDropCfg.Attr] = retAttrDic[gemCoreAttrDropCfg.Attr] + val
                    end
                end
            end
        else
            Debug.LogWarning("GetGemCoreAllAttrByData", "gemCoreDataId:", gemCoreData:GetPrimaryValue(), "GemCoreAttrDrop 配置没找到一般是服务器和客户端配置不一致")
        end
    end
    return retAttrDic
end

---根据配置id获取芯核数据
---@param cfgId int ItemId
---@return X3Data.GemCore
function GemCoreProxy:GetGemCoreDataByCfgId(cfgId)
    local condition = PoolUtil.GetTable()
    condition[X3DataConst.X3DataField.GemCore.TblID] = cfgId
    ---@type X3Data.GemCore
    local gemCoreData = X3DataMgr.GetByCondition(X3DataConst.X3Data.GemCore, condition)
    PoolUtil.ReleaseTable(condition)
    return gemCoreData
end

---获取芯核主属性 升级后的属性值 只有主属性在升级时会提升
---@param gemCoreId int gemCoreId
---@param attrId int attrId
---@param addLevel int 提升的等级
---@return int attrVale
function GemCoreProxy:GetGemCoreNextAttrValue(gemCoreId, attrId, addLevel)
    local gemCoreData = self:GetGemCoreDataByGemCoreId(gemCoreId)
    if gemCoreData == nil then
        return 0
    end
    local gemCoreAttrList = gemCoreData:GetAttrs()
    local attrValue = nil
    local randCount = nil
    local gemCoreAttrCfgList = nil
    for i = 1, #gemCoreAttrList do
        local attrDropId, localRandCount, val = GetGemAttr(gemCoreAttrList[i])
        local gemCoreAttrDropCfg = LuaCfgMgr.Get("GemCoreAttrDrop", attrDropId)
        if gemCoreAttrDropCfg then
            ---@type table<cfg.GemCoreAttr>
            local tempGemCoreAttrCfgList = LuaCfgMgr.Get("GemCoreAttrByAttrID", gemCoreAttrDropCfg.AttrID)
            if #tempGemCoreAttrCfgList > 0 and tempGemCoreAttrCfgList[1].AttrType == GemCoreConst.GemCoreAttrType.Main and attrId == gemCoreAttrDropCfg.Attr then
                gemCoreAttrCfgList = tempGemCoreAttrCfgList
                attrValue = val
                randCount = localRandCount
                break
            end
        end
    end
    if gemCoreAttrCfgList == nil then
        return 0
    end
    local curAddNum = 0
    for i = 1, addLevel do
        for j = 1, #gemCoreAttrCfgList do
            local gemCoreAttrCfg = gemCoreAttrCfgList[j]
            if randCount + i >= gemCoreAttrCfg.CountMin and randCount + i <= gemCoreAttrCfg.CountMax then
                curAddNum = curAddNum + gemCoreAttrCfg.AttrMin
                break
            end
        end
    end
    return attrValue + curAddNum
end

---@param gemCoreId int gemCoreId
---@return boolean
function GemCoreProxy:GemCoreIsLevelMax(gemCoreId, level, playerUid)
    if level == nil then
        local gemCoreData = self:GetGemCoreDataByGemCoreId(gemCoreId, playerUid)
        level = gemCoreData:GetLevel()
    end
    local gemCoreBaseInfo = self:GetGemCoreCfgById(gemCoreId, playerUid)
    if gemCoreBaseInfo then
        ---@type cfg.GemRare
        local gemCoreRareCfg = LuaCfgMgr.Get("GemRare", gemCoreBaseInfo.Rare)
        return level >= gemCoreRareCfg.MaxLevel
    end
    return false
end

return GemCoreProxy