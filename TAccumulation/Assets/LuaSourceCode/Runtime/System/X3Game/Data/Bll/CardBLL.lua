---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-14 15:58:26
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class CardBLL
local CardBLL = class("CardBLL", BaseBll)

function CardBLL:OnInit()
    EventMgr.AddListener("UnLockSystem", self.OnSysUnlock, self)
    EventMgr.AddListener("CoinUpdateReply", self.OnCoinUpdate, self)
    EventMgr.AddListener("ItemUpdateReply", self.OnItemUpdate, self)
    EventMgr.AddListener("EVENT_LEVEL_UP", self.OnPlayerLevelUp, self)
    EventMgr.AddListener(GameConst.CardEvent.CardAdd, self.OnCardAdd, self)
    EventMgr.AddListener(GameConst.CardEvent.CardRemove, self.OnCardRemove, self)
    EventMgr.AddListener(GameConst.CardEvent.CardLevelChanged, self.OnCardLevelChanged, self)
    EventMgr.AddListener(GameConst.CardEvent.CardPhaseLevelChanged, self.OnCardPhaseLevelChanged, self)
    EventMgr.AddListener(GameConst.CardEvent.CardStarLevelChanged, self.OnCardStarLevelChanged, self)
    EventMgr.AddListener(GameConst.CardEvent.CardAwakenLevelChanged, self.OnCardAwakenLevelChanged, self)
    EventMgr.AddListener(GameConst.CardEvent.CardQuestDataChanged, self.OnCardQuestDataChanged, self)
    EventMgr.AddListener(GameConst.CardEvent.CardSuitQuestDataChanged, self.OnCardSuitDataChanged, self)
    self:InitRelation()
end

function CardBLL:OnSysUnlock(systemId)
    if systemId == X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS then
        self:CheckCardAllRed()
    end
end

function CardBLL:OnCoinUpdate(data)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    local cardList = SelfProxyFactory.GetCardDataProxy():GetCardList()
    if not cardList or #cardList == 0 then
        return
    end
    for _, v in ipairs(cardList) do
        self:CheckStarUpRed(v:GetPrimaryValue())
        self:CheckAwakeRp(v:GetPrimaryValue())
    end
    self:CheckCardComposeRp()
end

function CardBLL:OnItemUpdate(data)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    local cardList = SelfProxyFactory.GetCardDataProxy():GetCardList()
    if not cardList or #cardList == 0 then
        return
    end
    for _, v in ipairs(cardList) do
        self:CheckStarUpRed(v:GetPrimaryValue())
        self:CheckAwakeRp(v:GetPrimaryValue())
        self:CheckPhaseUpRed(v:GetPrimaryValue())
    end
end

function CardBLL:OnPlayerLevelUp(level)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    local cardList = SelfProxyFactory.GetCardDataProxy():GetCardList()
    if not cardList or #cardList == 0 then
        return
    end
    for _, v in ipairs(cardList) do
        self:CheckStarUpRed(v:GetPrimaryValue())
    end
end

---@param cardList pbcmessage.Card[]
function CardBLL:OnCardAdd(cardList)
    if not cardList or #cardList == 0 then
        return
    end
    for i = 1, #cardList do
        self:CheckNewRed(cardList[i].Id)
        self:CheckStarUpRed(cardList[i].Id)
        self:CheckAwakeRp(cardList[i].Id)
        self:CheckPhaseUpRed(cardList[i].Id)
        ---清理已拥有的卡牌合成红点
        self:ClearCardComposeRp(cardList[i].Id)
    end
end

---@param cardList pbcmessage.Card[]
function CardBLL:OnCardRemove(cardList)
    if not cardList or #cardList == 0 then
        return
    end
    for i = 1, #cardList do
        self:ClearCardAllRed(cardList[i].Id)
    end
    self:CheckCardComposeRp()
end

function CardBLL:OnCardLevelChanged(cardId)
    self:CheckStarUpRed(cardId)
    self:CheckAwakeRp(cardId)
end

function CardBLL:OnCardStarLevelChanged(cardId)
    self:CheckStarUpRed(cardId)
    self:CheckAwakeRp(cardId)
end

function CardBLL:OnCardPhaseLevelChanged(cardId)
    self:CheckPhaseUpRed(cardId)
end

function CardBLL:OnCardAwakenLevelChanged(cardId)
    self:CheckStarUpRed(cardId)
    self:CheckAwakeRp(cardId)
end

function CardBLL:OnCardQuestDataChanged(cardId)
    self:CheckCardQuestRed(cardId)
end

function CardBLL:OnCardSuitDataChanged(suitId)
    local suitCardList = SelfProxyFactory.GetCardDataProxy():GetSuitCards(suitId)
    if suitCardList then
        for i = 1, #suitCardList do
            self:CheckSuitQuestRed(suitCardList[i])
        end
    end
end

--region 羁绊卡排序
function CardBLL:InitRelation()
    self.sortRelation = {}
    self.sortRelation[GameConst.CardSortType.Level] = handler(self, self.SortByLevel)
    self.sortRelation[GameConst.CardSortType.StarLevel] = handler(self, self.SortByStarLevel)
    self.sortRelation[GameConst.CardSortType.Quality] = handler(self, self.SortByQuality)
    self.sortRelation[GameConst.CardSortType.PhaseLevel] = handler(self, self.SortByPhaseLevel)
    self.sortRelation[GameConst.CardSortType.Awaken] = handler(self, self.SortByAwaken)
    self.sortRelation[GameConst.CardSortType.Suit] = handler(self, self.SortByIsSuit)
    self.sortRelation[GameConst.CardSortType.ID] = handler(self, self.SortByID)
    self.sortRelation[GameConst.CardSortType.SuitId] = handler(self, self.SortBySuitId)
    self.sortRelation[GameConst.CardSortType.CardId] = handler(self, self.SortByCardId)
    self.sortRelation[GameConst.CardSortType.RedPoint] = handler(self, self.SortByRedPoint)
    self.sortRelation[GameConst.CardSortType.Tag] = handler(self, self.SortByTag)
    self.sortRelation[GameConst.CardSortType.IsNew] = handler(self, self.SortByNew)
    self.sortRelation[GameConst.CardSortType.SuitLevel] = handler(self, self.SortBySuitLevel)
    self.sortRelation[GameConst.CardSortType.SuitCompose] = handler(self, self.SortBySuitCompose)
    self.sortRelation[GameConst.CardSortType.SuitAllLevel] = handler(self, self.SortSuitAllLevel)

    self.sortSequence = {}
    self.sortSequence[CardDevelopConst.SortPriority.Level] = { GameConst.CardSortType.Level, GameConst.CardSortType.StarLevel, GameConst.CardSortType.Quality, GameConst.CardSortType.PhaseLevel, GameConst.CardSortType.Suit, GameConst.CardSortType.SuitId, GameConst.CardSortType.ID, GameConst.CardSortType.CardId }
    self.sortSequence[CardDevelopConst.SortPriority.Quality] = { GameConst.CardSortType.Quality, GameConst.CardSortType.Level, GameConst.CardSortType.StarLevel, GameConst.CardSortType.PhaseLevel, GameConst.CardSortType.Suit, GameConst.CardSortType.SuitId, GameConst.CardSortType.ID, GameConst.CardSortType.CardId }
    self.sortSequence[CardDevelopConst.SortPriority.Suit] = { GameConst.CardSortType.Suit, GameConst.CardSortType.Quality, GameConst.CardSortType.SuitId, GameConst.CardSortType.Level, GameConst.CardSortType.StarLevel, GameConst.CardSortType.PhaseLevel, GameConst.CardSortType.ID, GameConst.CardSortType.CardId }
    self.sortSequence[CardDevelopConst.SortPriority.RedPoint] = { GameConst.CardSortType.RedPoint, GameConst.CardSortType.Level, GameConst.CardSortType.StarLevel, GameConst.CardSortType.Quality, GameConst.CardSortType.PhaseLevel, GameConst.CardSortType.Suit, GameConst.CardSortType.SuitId, GameConst.CardSortType.ID, GameConst.CardSortType.CardId }
    self.sortSequence[CardDevelopConst.SortPriority.Tag] = { GameConst.CardSortType.Tag, GameConst.CardSortType.Level, GameConst.CardSortType.StarLevel, GameConst.CardSortType.Quality, GameConst.CardSortType.PhaseLevel, GameConst.CardSortType.Suit, GameConst.CardSortType.SuitId, GameConst.CardSortType.ID, GameConst.CardSortType.CardId }
end
---等级排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByLevel(a, b)
    if a:GetLevel() == b:GetLevel() then
        return nil
    end
    return a:GetLevel() > b:GetLevel()
end
---星级排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByStarLevel(a, b)
    if a:GetStarLevel() == b:GetStarLevel() then
        return nil
    end
    return a:GetStarLevel() > b:GetStarLevel()
end
---品质排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByQuality(a, b)
    local cardBaseCfg1 = LuaCfgMgr.Get("CardBaseInfo", a:GetPrimaryValue())
    local cardBaseCfg2 = LuaCfgMgr.Get("CardBaseInfo", b:GetPrimaryValue())
    if cardBaseCfg1.Quality == cardBaseCfg2.Quality then
        return nil
    end
    return cardBaseCfg1.Quality > cardBaseCfg2.Quality
end
---品阶排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByPhaseLevel(a, b)
    if a:GetPhaseLevel() == b:GetPhaseLevel() then
        return nil
    end
    return a:GetPhaseLevel() > b:GetPhaseLevel()
end
---觉醒排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByAwaken(a, b)
    if a:GetAwaken() == b:GetAwaken() then
        return nil
    elseif a:GetAwaken() == X3DataConst.AwakenStatus.Awaken then
        return true
    else
        return false
    end
end
---是否是套装
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByIsSuit(a, b)
    local cardBaseCfg1 = LuaCfgMgr.Get("CardBaseInfo", a:GetPrimaryValue())
    local cardBaseCfg2 = LuaCfgMgr.Get("CardBaseInfo", b:GetPrimaryValue())
    local aSuit = 0
    if cardBaseCfg1.SuitID ~= 0 then
        aSuit = 1
    end
    local bSuit = 0
    if cardBaseCfg2.SuitID ~= 0 then
        bSuit = 1
    end
    if aSuit == bSuit then
        return nil
    end
    return aSuit > bSuit
end
---rank id排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByID(a, b)
    local cardBaseCfg1 = LuaCfgMgr.Get("CardBaseInfo", a:GetPrimaryValue())
    local cardBaseCfg2 = LuaCfgMgr.Get("CardBaseInfo", b:GetPrimaryValue())
    if cardBaseCfg1.Rank == cardBaseCfg2.Rank then
        return nil
    end
    return cardBaseCfg1.Rank > cardBaseCfg2.Rank
end
---套装id 排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortBySuitId(a, b)
    local cardBaseCfg1 = LuaCfgMgr.Get("CardBaseInfo", a:GetPrimaryValue())
    local cardBaseCfg2 = LuaCfgMgr.Get("CardBaseInfo", b:GetPrimaryValue())
    local aSuit = 0
    if cardBaseCfg1.SuitID ~= 0 then
        aSuit = cardBaseCfg1.SuitID
    end
    local bSuit = 0
    if cardBaseCfg2.SuitID ~= 0 then
        bSuit = cardBaseCfg2.SuitID
    end
    if aSuit == bSuit then
        return nil
    end
    return aSuit < bSuit
end
---羁绊卡配置id排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByCardId(a, b)
    return a:GetPrimaryValue() < b:GetPrimaryValue()
end

---羁绊卡Tag排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByTag(a, b)
    local cardBaseCfg1 = LuaCfgMgr.Get("CardBaseInfo", a:GetPrimaryValue())
    local cardBaseCfg2 = LuaCfgMgr.Get("CardBaseInfo", b:GetPrimaryValue())
    if cardBaseCfg1.FormationTag == cardBaseCfg2.FormationTag then
        return nil
    end
    return cardBaseCfg1.FormationTag < cardBaseCfg2.FormationTag
end

---红点类型排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByRedPoint(a, b)
    local aIsNew = RedPointMgr.GetCount(X3_CFG_CONST.RED_NEW_CARD_NEW, a:GetPrimaryValue())
    local bIsNew = RedPointMgr.GetCount(X3_CFG_CONST.RED_NEW_CARD_NEW, b:GetPrimaryValue())
    if aIsNew ~= bIsNew then
        return aIsNew > bIsNew
    end
    local aIsRedPoint = RedPointMgr.GetCount(X3_CFG_CONST.RED_CARD_LIST_RP, a:GetPrimaryValue())
    local bIsRedPoint = RedPointMgr.GetCount(X3_CFG_CONST.RED_CARD_LIST_RP, b:GetPrimaryValue())
    if aIsRedPoint ~= bIsRedPoint then
        return aIsRedPoint > bIsRedPoint
    end
    return nil
end

---新获得类型排序
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortByNew(a, b)
    local aIsNew = RedPointMgr.GetCount(X3_CFG_CONST.RED_NEW_CARD_NEW, a:GetPrimaryValue())
    local bIsNew = RedPointMgr.GetCount(X3_CFG_CONST.RED_NEW_CARD_NEW, b:GetPrimaryValue())
    if aIsNew ~= bIsNew then
        return aIsNew > bIsNew
    end
    return nil
end

---思念卡套装等级最大的排在前面
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:SortBySuitLevel(a,b)
    local function getSuitIdLevelMax(cardDataInfo)
        ---@type cfg.CardBaseInfo
        local cfg_CardBaseInfo = LuaCfgMgr.Get("CardBaseInfo", cardDataInfo:GetPrimaryValue())
        if cfg_CardBaseInfo.SuitID > 0 then
            local suitCardData = SelfProxyFactory.GetCardDataProxy():GetData(cfg_CardBaseInfo.SuitCardID)
            if suitCardData ~= nil then
                local currentCardLevel = cardDataInfo:GetLevel()
                local suitCardLevel = suitCardData:GetLevel()
                if currentCardLevel > suitCardLevel then
                    return currentCardLevel
                end
                return suitCardLevel
            end
            return 0
        end
        return 0
    end

    local aMaxLevel = getSuitIdLevelMax(a)
    local bMaxLevel = getSuitIdLevelMax(b)
    if aMaxLevel ~= bMaxLevel then
        return aMaxLevel > bMaxLevel
    end
    return nil
end

---思念卡套装等级总和排序
function CardBLL:SortSuitAllLevel(a, b)
    local function getSuitIdLevelWeight(cardDataInfo)
        ---@type cfg.CardBaseInfo
        local cfg_CardBaseInfo = LuaCfgMgr.Get("CardBaseInfo", cardDataInfo:GetPrimaryValue())
        if cfg_CardBaseInfo.SuitID > 0 then
            local suitCardData = SelfProxyFactory.GetCardDataProxy():GetData(cfg_CardBaseInfo.SuitCardID)
            if suitCardData ~= nil then
                local allLevel = cardDataInfo:GetLevel() + suitCardData:GetLevel()
                local currentCardLevel = cardDataInfo:GetLevel()
                local suitCardLevel = suitCardData:GetLevel()
                local maxLevel
                if currentCardLevel > suitCardLevel then
                    maxLevel = currentCardLevel
                else
                    maxLevel = suitCardLevel    
                end
                return allLevel, maxLevel
            end
            return 0, 0
        end
        return 0, 0
    end

    local aAllLevel, aMaxLevel = getSuitIdLevelWeight(a)
    local bAllLevel, bMaxLevel = getSuitIdLevelWeight(b)
    if aAllLevel ~= bAllLevel then
        return aAllLevel > bAllLevel
    end
    if aMaxLevel ~= bMaxLevel then
        return aMaxLevel > bMaxLevel
    end
    return nil
end

---思念卡组成套装排序
function CardBLL:SortBySuitCompose(a,b)
    local function getSuitComposeWeight(cardDataInfo)
        ---@type cfg.CardBaseInfo
        local cfg_CardBaseInfo = LuaCfgMgr.Get("CardBaseInfo", cardDataInfo:GetPrimaryValue())
        if cfg_CardBaseInfo.SuitID > 0 then
            local suitCardData = SelfProxyFactory.GetCardDataProxy():GetData(cfg_CardBaseInfo.SuitCardID)
            if suitCardData ~= nil then
                return 2
            end
            return 1
        end
        return 0
    end
    
    local aSuitCompose = getSuitComposeWeight(a)
    local bSuitCompose = getSuitComposeWeight(b)
    if aSuitCompose ~= bSuitCompose then
        return aSuitCompose > bSuitCompose
    end
    return nil
end

---羁绊卡排序
---@param sortType GameConst.CardSortType
---@param a X3Data.CardData
---@param b X3Data.CardData
function CardBLL:CardSortFunc(sortType, a, b)
    return self.sortRelation[sortType](a, b)
end

---不带培养的思念排序方法
---@param id_a number 思念Id
---@return bool
local function __commonSortFuncWithoutDevelop(id_a, id_b)
    local cfgA = LuaCfgMgr.Get("CardBaseInfo", id_a)
    local cfgB = LuaCfgMgr.Get("CardBaseInfo", id_b)
    if cfgA == nil or cfgB == nil then
        return false
    end
    return cfgA.Rank > cfgB.Rank
end

---不带培养的思念排序方法
---@param id_a number 思念Id
---@return bool
function CardBLL:CommonSortFuncWithoutDevelop(id_a, id_b)
    return __commonSortFuncWithoutDevelop(id_a, id_b)
end

---不带培养的思念排序
---@param cardIdList number[]
---@return number[]
function CardBLL:CommonSortWithoutDevelop(cardIdList)
    if table.isnilorempty(cardIdList) then
        return cardIdList
    end
    table.sort(cardIdList, __commonSortFuncWithoutDevelop)
    return cardIdList
end

---带培养的思念排序
---@param cardDataList X3Data.CardData[]
---@param sortPriority CardDevelopConst.SortPriority
---@param extraSortFunc function 额外的排序要求，会优先处理，如果此方法为空或者方法的返回值为nil，则进行内置的排序
---@return X3Data.CardData[]
function CardBLL:CommonSortWithDevelop(cardDataList, sortPriority, extraSortFunc)
    if table.isnilorempty(cardDataList) or self.sortSequence[sortPriority] == nil then
        return cardDataList
    end
    local sortList = self.sortSequence[sortPriority]
    table.sort(cardDataList, function(a, b)
        if extraSortFunc then
            local result = extraSortFunc(a, b)
            if nil ~= result then
                return result
            end
        end
        for i = 1, #sortList do
            local sortResult = self:CardSortFunc(sortList[i], a, b)
            if sortResult ~= nil then
                return sortResult
            end
        end
    end)
end

--endregion

---显示首次获得 羁绊卡界面
---@param cardList pbcmessage.Card[] 显示首次获得的card
function CardBLL:ShowFirstShowList(cardList)
    local showList = {}
    if cardList == nil then
        return
    end
    for i = 1, #cardList do
        local cardData = cardList[i]
        local cardOldData = SelfProxyFactory.GetCardDataProxy():GetData(cardData.Id)
        if cardOldData == nil then
            table.insert(showList, { Id = cardData.Id, Type = 51, isNew = true })
        else
            table.insert(showList, { Id = cardData.Id, Type = 51, isNew = false })
        end
    end
    if not UIMgr.IsVisible(UIConf.GachaMainWnd) then
        self:_AddFirstShowTips(showList) --显示首次获得
    end
end

---@return bool
function CardBLL:GM_GetSkipCardShow()
    return PlayerPrefs.GetBool("GM_SKIP_CARD_SCORE_SHOW", false)
end

---显示首次获得 羁绊卡界面
---@param showList table 显示首次获得的列表
function CardBLL:_AddFirstShowTips(showList)
    if self:GM_GetSkipCardShow() then
        return
    end
    for i = 1, #showList do
        local tempData = showList[i]
        local itemList = {}
        local itemTemp = {}
        itemTemp.Item = tempData
        itemTemp.IsNew = tempData.isNew
        table.insert(itemList, itemTemp)
        ErrandMgr.Add(X3_CFG_CONST.POPUP_COMMON_CARDSHOW, itemList, tempData.isNew)
    end
end

---读本地表
---获取等级表格数据
---@return cfg.CardLevelTemplate
function CardBLL:GetCardLevelTemplate(level)
    return LuaCfgMgr.Get("CardLevelTemplate", level)
end

---@return cfg.CardLevelTemplate
function CardBLL:GetCardStarTemplate(starLevel)
    return LuaCfgMgr.Get("CardStarTemplate", starLevel)
end

---@return cfg.CardAwakeTemplate
function CardBLL:GetCardAwakeTemplate(awakeLevel)
    return LuaCfgMgr.Get("CardAwakeTemplate", awakeLevel)
end

---@return cfg.CardLevelExp
function CardBLL:GetCardNextLvExp(expMode, level)
    local cardLevelExpCfg = LuaCfgMgr.Get("CardLevelExp", expMode, level)
    return cardLevelExpCfg
end

---获取Card星级表格数据
---@return cfg.CardStar
function CardBLL:GetCardStar(groupID, starlevel)
    return LuaCfgMgr.Get("CardStar", groupID, starlevel)
end

---@return cfg.CardPhase
function CardBLL:GetPhaseCfgData(cardPhaseMode, phaseLv)
    return LuaCfgMgr.Get("CardPhase", cardPhaseMode, phaseLv)
end

---@return cfg.CardTalent
function CardBLL:GetCardTalentCfgData(talentId)
    return LuaCfgMgr.Get("CardTalent", talentId)
end

--region 与服务器数据交互

---请求升级
function CardBLL:CTS_SendCardLeveUp(cardId, costs)
    local messageBody = PoolUtil.GetTable()
    messageBody.Id = cardId
    messageBody.Costs = costs
    GrpcMgr.SendRequest(RpcDefines.CardAddExpRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

---请求突破
function CardBLL:CTS_SendCardStarLevelUp(cardId)
    local messageBody = PoolUtil.GetTable()
    messageBody.Id = cardId
    GrpcMgr.SendRequest(RpcDefines.CardStarUpRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

---请求觉醒
function CardBLL:CTS_SendCardAwaken(cardId)
    local messageBody = PoolUtil.GetTable()
    messageBody.Id = cardId
    GrpcMgr.SendRequest(RpcDefines.CardAwakenRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

--羁绊卡合成
function CardBLL:CTS_SendCardCompose(cardId)
    local messageBody = PoolUtil.GetTable()
    messageBody.Id = cardId
    GrpcMgr.SendRequest(RpcDefines.CardMergeRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

function CardBLL:STC_CardComposeCallBack(CardID)
    EventMgr.Dispatch(GameConst.CardEvent.CardComposeCallBack, CardID)
end

---请求进阶
function CardBLL:CTS_SendCardProgress(cardId)
    local messageBody = PoolUtil.GetTable()
    messageBody.Id = cardId
    GrpcMgr.SendRequest(RpcDefines.CardProgressRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

---请求装备芯核
---@param cardId number 卡ID
---@param gemCoreIds number[] 芯核ID列表,支持批量装备
function CardBLL:CTS_SendCardBindGemCore(cardId, gemCoreIds)
    local messageBody = PoolUtil.GetTable()
    messageBody.CardID = cardId
    messageBody.CoreID = gemCoreIds
    GrpcMgr.SendRequest(RpcDefines.CardPutOnGemCoreRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

---请求卸下芯核
---@param cardId number 卡ID
---@param gemCoreIds number[] 芯核ID列表,支持批量卸下
function CardBLL:CTS_SendCardUnBindGemCore(cardId, gemCoreIds)
    local messageBody = PoolUtil.GetTable()
    messageBody.CardID = cardId
    messageBody.CoreID = gemCoreIds
    GrpcMgr.SendRequest(RpcDefines.CardTakeOffGemCoreRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

---请求领取任务奖励
---@param cardId number 卡ID
---@param rewardId number 奖励ID
function CardBLL:CTS_SendCardGetReward(cardId, rewardIds)
    if table.isnilorempty(rewardIds) or cardId == nil or cardId <= 0 then
        return
    end
    local messageBody = PoolUtil.GetTable()
    messageBody.CardID = cardId
    messageBody.RewardIDs = rewardIds
    GrpcMgr.SendRequest(RpcDefines.CardGetRewardRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

---一键领取任务奖励
---@param cardId number 卡ID
---@param isSuitQuest boolean 是否套装任务
function CardBLL:CTS_SendCardGetRewardBatch(cardId, isSuitQuest)
    ---@type table<int,GameConst.CardQuestStatus>
    local questList
    if isSuitQuest then
        local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
        if cardCfg then
            questList = SelfProxyFactory.GetCardDataProxy():GetCardSuitQuestList(cardCfg.SuitID)
        end
    else
        questList = SelfProxyFactory.GetCardDataProxy():GetCardQuestList(cardId)
    end
    if table.isnilorempty(questList) then
        return
    end
    local rewardIds = PoolUtil.GetTable()
    for rewardId, questStatus in pairs(questList) do
        if questStatus == GameConst.CardQuestStatus.Finish then
            table.insert(rewardIds, rewardId)
        end
    end
    self:CTS_SendCardGetReward(cardId, rewardIds)
    PoolUtil.ReleaseTable(rewardIds)
end

--endregion

---此接口只会查找自己身上的卡
---@private
---@param callBack fun(cardData:X3Data.CardData)
function CardBLL:_SearchCardData(manType, callBack)
    local count = 0
    ---@type X3Data.CardData[]
    local cardsDatas = SelfProxyFactory.GetCardDataProxy():GetCardListByRoleId(manType)
    if cardsDatas == nil then
        return count
    end
    for k, v in pairs(cardsDatas) do
        if callBack ~= nil and callBack(v) then
            count = count + 1
        end
    end
    return count
end

function CardBLL:_GetCardByManTypeAndLevelRange(manType, minLevel, maxLevel)
    local amount = self:_SearchCardData(manType, function(cardData)
        return ConditionCheckUtil.IsInRange(cardData:GetLevel(), minLevel, maxLevel)
    end)
    return amount
end

function CardBLL:_GetCardByManTypeAndStarLevelRange(manType, minStarLevel, maxStarLevel)
    local amount = self:_SearchCardData(manType, function(cardData)
        return ConditionCheckUtil.IsInRange(cardData:GetStarLevel(), minStarLevel, maxStarLevel)
    end)
    return amount
end

function CardBLL:_GetCardByManTypeAndStarPhaseLevelRange(manType, minPhaseLevel, maxPhaseLevel)
    local amount = self:_SearchCardData(manType, function(cardData)
        return ConditionCheckUtil.IsInRange(cardData:GetPhaseLevel(), minPhaseLevel, maxPhaseLevel)
    end)
    return amount
end

function CardBLL:_GetCardByManTypeBySuitQuality(manType, suitQuality)
    ---@type X3Data.CardData[]
    local allCardList = SelfProxyFactory.GetCardDataProxy():GetCardListByRoleId(manType)
    local retNum = 0
    local cardSuitIdDic = {}
    for k, v in pairs(allCardList) do
        ---@type cfg.CardBaseInfo
        local cardBaseInfo = LuaCfgMgr.Get("CardBaseInfo", v:GetPrimaryValue())
        if cardBaseInfo and cardBaseInfo.SuitID ~= 0 then
            if cardSuitIdDic[cardBaseInfo.SuitID] == nil then
                cardSuitIdDic[cardBaseInfo.SuitID] = 0
            end
            cardSuitIdDic[cardBaseInfo.SuitID] = cardSuitIdDic[cardBaseInfo.SuitID] + 1
        end
    end
    for k, v in pairs(cardSuitIdDic) do
        ---@type cfg.CardSuit
        local cardSuitCfg = LuaCfgMgr.Get("CardSuit", k, 0)
        if cardSuitCfg and v >= cardSuitCfg.NumMax and (suitQuality == -1 or SelfProxyFactory.GetCardDataProxy():GetSuitQuality(k) == suitQuality) then
            retNum = retNum + 1
        end
    end
    return retNum
end

function CardBLL:_GetCardNumByManTypeAndQuality(manType, quality)
    local amount = self:_SearchCardData(manType, function(cardData)
        local cfg = LuaCfgMgr.Get("CardBaseInfo", cardData:GetPrimaryValue())
        return quality == -1 or (cfg and cfg.Quality >= quality)
    end)
    return amount
end

function CardBLL:_GetCardNumByManTypeAndQualityAndAwaken(manType, quality)
    local amount = self:_SearchCardData(manType, function(cardData)
        local cfg = LuaCfgMgr.Get("CardBaseInfo", cardData:GetPrimaryValue())
        return (quality == -1 or (cfg and cfg.Quality >= quality)) and (cardData:GetAwaken() == X3DataConst.AwakenStatus.Awaken)
    end)
    return amount
end

local function CardDataRewardStateEqual(cardData, rewardId, status)
    if not cardData then
        return false
    end
    local cardQuestList = SelfProxyFactory.GetCardDataProxy():GetCardQuestList(cardData:GetPrimaryValue())
    if cardQuestList and cardQuestList[rewardId] and cardQuestList[rewardId] == status then
        return true
    end
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardData:GetPrimaryValue())
    if cardCfg and cardCfg.SuitID > 0 then
        local cardSuitQuestList = SelfProxyFactory.GetCardDataProxy():GetCardSuitQuestList(cardCfg.SuitID)
        if cardSuitQuestList and cardSuitQuestList[rewardId] and cardSuitQuestList[rewardId] == status then
            return true
        end
    end
    return false
end

function CardBLL:_CardRewardStateEqual(cardId, rewardId, status)
    if cardId == -1 then
        local cardList = SelfProxyFactory.GetCardDataProxy():GetCardList()
        if not cardList or #cardList == 0 then
            return false
        end
        for _, v in pairs(cardList) do
            local equal = CardDataRewardStateEqual(v, rewardId, status)
            if equal then
                return true
            end
        end
        return false
    else
        return CardDataRewardStateEqual(SelfProxyFactory.GetCardDataProxy():GetData(cardId), rewardId, status)
    end
end

function CardBLL:_CardAwakeStatusEqual(cardId, awakeStatus)
    if (not cardId) then
        return false
    end
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardId)
    if not cardData then
        return false
    end
    return cardData:GetAwaken() == awakeStatus
end

---判断Card是否可满阶（已满阶也算可满阶）
---@return int 可满阶：1， 不可满阶：0
function CardBLL:CardCanPhaseFullUp(cardId)
    if (not cardId) then
        return 0
    end
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg then
        return 0
    end
    local cardMaxPhaseLevel = SelfProxyFactory.GetCardDataProxy():GetCardMaxPhaseLv()
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardId)
    if cardData and cardData:GetPhaseLevel() >= cardMaxPhaseLevel then
        return 1
    end
    local needFragmentNum = 0
    if not cardData then
        --未获得卡，需要先算上合成需求数量
        local cardRareCfg = LuaCfgMgr.Get("CardRare", cardCfg.Quality)
        needFragmentNum = needFragmentNum + (cardRareCfg and cardRareCfg.FragmentNum or 0)
    end
    local cardPhaseLevel = cardData and cardData:GetPhaseLevel() or 0
    for i = cardPhaseLevel + 1, cardMaxPhaseLevel do
        local cardPhaseCfg = LuaCfgMgr.Get("CardPhase", cardCfg.PhaseMode, i)
        needFragmentNum = needFragmentNum + (cardPhaseCfg and cardPhaseCfg.CostSelfNum or 0)
    end
    local cardFragmentId = cardCfg.FragmentID
    local curFragmentNum = BllMgr.GetItemBLL():GetItemNum(cardFragmentId)
    return curFragmentNum >= needFragmentNum and 1 or 0
end

function CardBLL:CheckCondition(id, params, iDataProvider)
    local retNum = 0
    local minNum = 0
    local maxNum = 0
    if id == X3_CFG_CONST.CONDITION_CARD_LEVEL then
        retNum = self:_GetCardByManTypeAndLevelRange(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]))
        minNum = tonumber(params[4])
        maxNum = tonumber(params[5])
    elseif id == X3_CFG_CONST.CONDITION_CARD_STAR then
        retNum = self:_GetCardByManTypeAndStarLevelRange(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]))
        minNum = tonumber(params[4])
        maxNum = tonumber(params[5])
    elseif id == X3_CFG_CONST.CONDITION_CARD_PHASE then
        retNum = self:_GetCardByManTypeAndStarPhaseLevelRange(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]))
        minNum = tonumber(params[4])
        maxNum = tonumber(params[5])
    elseif id == X3_CFG_CONST.CONDITION_CARD_HOLD then
        local cardData = SelfProxyFactory.GetCardDataProxy():GetData(tonumber(params[2]))
        local isHave = cardData and 1 or 0
        return isHave == tonumber(params[1]), retNum
    elseif id == X3_CFG_CONST.CONDITION_CARD_SUIT_HOLD then
        retNum = self:_GetCardByManTypeBySuitQuality(tonumber(params[1]), tonumber(params[2]))
        minNum = tonumber(params[3])
        maxNum = tonumber(params[4])
    elseif id == X3_CFG_CONST.CONDITION_CARD_LEVELALL then
        retNum = SelfProxyFactory.GetCardDataProxy():GetLevelMaxCardNum()
        local allCardMaxLevel = retNum >= SelfProxyFactory.GetCardDataProxy():GetCardCfgAllNum()
        if tonumber(params[1]) == 1 then
            return allCardMaxLevel
        else
            return not allCardMaxLevel
        end
    elseif id == X3_CFG_CONST.CONDITION_CARD_STARALL then
        retNum = SelfProxyFactory.GetCardDataProxy():GetStarLevelMaxCardNum()
        local allCardMaxStar = retNum >= SelfProxyFactory.GetCardDataProxy():GetCardCfgAllNum()
        if tonumber(params[1]) == 1 then
            return allCardMaxStar
        else
            return not allCardMaxStar
        end
    elseif id == X3_CFG_CONST.CONDITION_CARD_NUM then
        return self:_GetCardNumByManTypeAndQuality(tonumber(params[1]), tonumber(params[2])) >= tonumber(params[3])
    elseif id == X3_CFG_CONST.CONDITION_CARDREWARD_STATE then
        return self:_CardRewardStateEqual(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]) - 1)
    elseif id == X3_CFG_CONST.CONDITION_CARD_AWAKE then
        return self:_CardAwakeStatusEqual(tonumber(params[1]), tonumber(params[2]))
    elseif id == X3_CFG_CONST.CONDITION_CARD_AWAKE_NUM then
        retNum = self:_GetCardNumByManTypeAndQualityAndAwaken(tonumber(params[1]), tonumber(params[2]))
        minNum = tonumber(params[3])
        maxNum = tonumber(params[4])
    elseif id == X3_CFG_CONST.CONDITION_CARD_PHASE_STATE then
        local cardData = SelfProxyFactory.GetCardDataProxy():GetData(tonumber(params[1]))
        if not cardData then
            return false
        end
        retNum = cardData:GetPhaseLevel()
        minNum = tonumber(params[2])
        maxNum = tonumber(params[3])
    elseif id == X3_CFG_CONST.CONDITION_CARD_PHASE_STATE_FULLCHECK then
        local cardCanPhaseFullUp = self:CardCanPhaseFullUp(tonumber(params[1]))
        return cardCanPhaseFullUp == tonumber(params[2])
    end
    return ConditionCheckUtil.IsInRange(retNum, minNum, maxNum), retNum
end

---卡是否能升阶
function CardBLL:CardCanPhaseUp(cardID)
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardID)
    if cardData == nil then
        return false
    end
    local cardInfo = LuaCfgMgr.Get("CardBaseInfo", cardID)
    if cardInfo == nil then
        return false
    end
    local nextCardPhase = self:GetPhaseCfgData(cardInfo.PhaseMode, cardData:GetPhaseLevel() + 1)
    if nextCardPhase == nil then
        return false
    end
    if BllMgr.GetPlayerBLL():GetPlayerCoin().Gold < nextCardPhase.GoldCost then
        return false
    end
    if nextCardPhase.CostItem ~= nil then
        for i = 1, #nextCardPhase.CostItem do
            local curItemnum = BllMgr.GetItemBLL():GetItemNum(nextCardPhase.CostItem[i].ID)
            if curItemnum < nextCardPhase.CostItem[i].Num then
                return false
            end
        end
    end
    local CommonCardList = LuaCfgMgr.Get("CardRare", cardInfo.Quality).CommonCard
    local CommonCardNum = 0
    if CommonCardList then
        for k, v in pairs(CommonCardList) do
            local itemData = BllMgr.GetItemBLL():GetItem(v.ID)
            if itemData ~= nil then
                CommonCardNum = CommonCardNum + itemData.Num
            end
        end
    end
    local cardFragmentId = cardInfo.FragmentID
    local curFragmentNum = BllMgr.GetItemBLL():GetItemNum(cardFragmentId)
    if curFragmentNum < nextCardPhase.CostSelfNum then
        return false
    end
    return true
end

---是否能突破
---@param withErrorMsg boolean 不能觉醒时是否有业务提示（数据错误不会有弹窗提示，只有金币不足、材料不足等正常情况才会弹提示）
function CardBLL:CardCanBreak(cardId, withErrorMsg)
    withErrorMsg = withErrorMsg == nil and false or withErrorMsg
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardId)
    if cardData == nil then
        return false
    end
    local cardInfoCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if cardInfoCfg == nil then
        return false
    end
    local nowLv = cardData:GetLevel()
    local cardStarCfg = self:GetCardStar(cardInfoCfg.StarID, cardData:GetStarLevel())
    local maxLv = cardStarCfg.LevelLimit
    if cardStarCfg == nil or nowLv < maxLv then
        return false
    end
    if cardData:GetStarLevel() >= SelfProxyFactory.GetCardDataProxy():GetCardStarMaxNum(cardId) then
        return false
    end
    local price = cardStarCfg.GoldCost
    local curPrice = BllMgr.GetPlayerBLL():GetPlayerCoin().Gold
    local coinEnough = curPrice >= price
    if not coinEnough then
        if withErrorMsg then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_8156)
        end
        return false
    end
    local levelEnough = cardData:GetLevel() >= cardStarCfg.LevelLimit
    if not levelEnough then
        if withErrorMsg then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_8136, cardStarCfg.LevelLimit)
        end
        return false
    end
    local playerLevelEnough = SelfProxyFactory.GetPlayerInfoProxy():GetLevel() >= cardStarCfg.PlayerLevel
    if not playerLevelEnough then
        if withErrorMsg then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_8137, cardStarCfg.PlayerLevel)
        end
        return false
    end
    local starUpItemIDList = cardStarCfg.ItemCost
    local itemEnough = true
    for i = 1, #starUpItemIDList do
        local tempS3Int = starUpItemIDList[i]
        local haveNum = BllMgr.GetItemBLL():GetItemNum(tempS3Int.ID)
        if haveNum < tempS3Int.Num then
            itemEnough = false
            break
        end
    end
    if not itemEnough then
        if withErrorMsg then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_8140)
        end
        return false
    end
    return true
end

---是否能觉醒
---@param withErrorMsg boolean 不能觉醒时是否有业务提示（数据错误不会有弹窗提示，只有金币不足、材料不足等正常情况才会弹提示）
function CardBLL:CardCanAwaken(cardId, withErrorMsg)
    withErrorMsg = withErrorMsg == nil and false or withErrorMsg
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardId)
    if cardData == nil then
        return false
    end
    if cardData:GetAwaken() == X3DataConst.AwakenStatus.Awaken then
        return false
    end
    local cardInfoCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if cardInfoCfg == nil then
        return false
    end
    local cardAwakeCfg = LuaCfgMgr.Get("CardAwake", cardInfoCfg.AwakeID)
    if not cardAwakeCfg then
        return false
    end
    if cardData:GetLevel() < cardAwakeCfg.AwakeNeedLv then
        return false
    end
    local price = cardAwakeCfg.NeedGold
    local curPrice = BllMgr.GetPlayerBLL():GetPlayerCoin().Gold
    local coinEnough = curPrice >= price
    if not coinEnough then
        if withErrorMsg then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_8604)
        end
        return false
    end
    local awakeItemIDList = cardAwakeCfg.NeedItem
    local itemEnough = true
    for i = 1, #awakeItemIDList do
        local tempS3Int = awakeItemIDList[i]
        local haveNum = BllMgr.GetItemBLL():GetItemNum(tempS3Int.ID)
        if haveNum < tempS3Int.Num then
            itemEnough = false
            break
        end
    end
    if not itemEnough then
        if withErrorMsg then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_8141)
        end
        return false
    end
    return true
end

function CardBLL:IsHaveCard(cardId)
    return SelfProxyFactory.GetCardDataProxy():GetData(cardId) ~= nil
end

function CardBLL:HasCard()
    local _, cnt = SelfProxyFactory.GetCardDataProxy():GetCardList()
    return cnt > 0
end

---获取卡指定品阶的被动技能描述
---@param phaseLevel number 品阶
---@return string
function CardBLL:GetCardPassiveSkillDesc(cardId, phaseLevel)
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg then
        return nil
    end
    if not phaseLevel then
        return nil
    end
    local skillId = nil
    local defaultSkillLevel = nil
    if cardCfg.CardMaleSkill and #cardCfg.CardMaleSkill > 0 then
        skillId = cardCfg.CardMaleSkill[1].ID
        defaultSkillLevel = cardCfg.CardMaleSkill[1].Num
    elseif cardCfg.CardFemaleSkill and #cardCfg.CardFemaleSkill > 0 then
        skillId = cardCfg.CardFemaleSkill[1].ID
        defaultSkillLevel = cardCfg.CardFemaleSkill[1].Num
    end
    if not skillId or not defaultSkillLevel then
        return nil
    end
    if phaseLevel == 0 then
        local phase0Skill = BattleForSystem.GetSkillLevelConfig(skillId, defaultSkillLevel)
        return phase0Skill and UITextHelper.GetUIText(phase0Skill.DetailDesc) or nil
    end
    local cardPhaseCfg = LuaCfgMgr.Get("CardPhase", cardCfg.PhaseMode, phaseLevel)
    if cardPhaseCfg then
        local skill = BattleForSystem.GetSkillLevelConfig(skillId, cardPhaseCfg.CardEffectLevel)
        if skill then
            return UITextHelper.GetUIText(skill.DetailDesc)
        end
    end
    return nil
end

---获取卡所有品阶的被动技能描述
---@return table<int,string> key:品阶,value:描述
function CardBLL:GetCardAllPassiveSkillDesc(cardId)
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg then
        return nil
    end
    local skillId = nil
    local defaultSkillLevel = nil
    if cardCfg.CardMaleSkill and #cardCfg.CardMaleSkill > 0 then
        skillId = cardCfg.CardMaleSkill[1].ID
        defaultSkillLevel = cardCfg.CardMaleSkill[1].Num
    elseif cardCfg.CardFemaleSkill and #cardCfg.CardFemaleSkill > 0 then
        skillId = cardCfg.CardFemaleSkill[1].ID
        defaultSkillLevel = cardCfg.CardFemaleSkill[1].Num
    end
    if not skillId or not defaultSkillLevel then
        return nil
    end
    local maxPhaseLv = SelfProxyFactory.GetCardDataProxy():GetCardMaxPhaseLv()
    local result = {}
    local phase0Skill = BattleForSystem.GetSkillLevelConfig(skillId, defaultSkillLevel)
    if phase0Skill then
        result[0] = UITextHelper.GetUIText(phase0Skill.DetailDesc)
    end
    for i = 1, maxPhaseLv do
        local cardPhaseCfg = LuaCfgMgr.Get("CardPhase", cardCfg.PhaseMode, i)
        if cardPhaseCfg then
            local skill = BattleForSystem.GetSkillLevelConfig(skillId, cardPhaseCfg.CardEffectLevel)
            if skill then
                result[i] = UITextHelper.GetUIText(skill.DetailDesc)
            end
        end
    end
    return result
end

---获取卡套装指定品阶的被动技能描述
---@param phaseLevel number 品阶
---@return string
function CardBLL:GetCardSuitPassiveSkillDesc(cardId, phaseLevel)
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg then
        return nil
    end
    if cardCfg.SuitID <= 0 then
        return nil
    end
    local cardSuitCfg = LuaCfgMgr.Get("CardSuit", cardCfg.SuitID, phaseLevel)
    if cardSuitCfg then
        return UITextHelper.GetUIText(cardSuitCfg.Desc)
    end
    return nil
end

---获取卡套装的所有被动技能描述
---@return table<int,string> key:品阶,value:描述
function CardBLL:GetCardSuitAllPassiveSkillDesc(cardId)
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg then
        return nil
    end
    if cardCfg.SuitID <= 0 then
        return nil
    end
    local maxPhaseLv = SelfProxyFactory.GetCardDataProxy():GetCardMaxPhaseLv()
    local result = {}
    for i = 0, maxPhaseLv do
        local cardSuitCfg = LuaCfgMgr.Get("CardSuit", cardCfg.SuitID, i)
        if cardSuitCfg then
            result[i] = UITextHelper.GetUIText(cardSuitCfg.Desc)
        end
    end
    return result
end

---获取天赋加成描述
---@param talentProperties table<int,int> 天赋加成属性
function CardBLL:GetCardTalentDesc(cardId, talentProperties)
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg then
        return nil
    end
    local talentCfg = self:GetCardTalentCfgData(cardCfg.TalentID)
    if not talentCfg then
        return nil
    end
    local retStr = nil
    if talentProperties then
        local cardTalentProperties = DevelopPropertyUtil.GetPropertyList(talentProperties)
        local curAddNum = ""
        if talentCfg.IncreaseEffect and #talentCfg.IncreaseEffect > 0 then
            curAddNum = DevelopHelper.GetPropertyValueShowText(talentCfg.IncreaseEffect[1].ID, 0)
        end
        if #cardTalentProperties > 0 then
            curAddNum = DevelopHelper.GetPropertyValueShowText(cardTalentProperties[1].propertyType, cardTalentProperties[1].propertyValue)
        end
        retStr = string.concat(UITextHelper.GetUIText(talentCfg.Desc), UITextHelper.GetUIText(UITextConst.UI_TEXT_8107, curAddNum))
    else
        retStr=UITextHelper.GetUIText(talentCfg.Desc)
    end
    return retStr
end

--region 任务相关

---@class CardQuestListItem
---@field RewardId number 任务奖励ID
---@field Status GameConst.CardQuestStatus 任务状态
---@field Desc string 任务描述
---@field Cfg cfg.CardReward Reward配置
---@field CurVal number 当前值
---@field TarVal number 目标值

---@param a CardQuestListItem
---@param b CardQuestListItem
local function QuestSort(a, b)
    if a.Status == b.Status then
        return a.Cfg.Sort < b.Cfg.Sort
    else
        return GameConst.CardQuestStatusOrder[a.Status] > GameConst.CardQuestStatusOrder[b.Status]
    end
end

---@param cfg cfg.CardReward
---@return string
local function GetQuestDesc(cardId, cfg)
    if cfg.Type == GameConst.CardRewardType.LevelReach
            or cfg.Type == GameConst.CardRewardType.PhaseLevelReach
            or cfg.Type == GameConst.CardRewardType.AwakenReach
            or cfg.Type == GameConst.CardRewardType.StarLevelReach then
        return UITextHelper.GetUIText(cfg.Desc, cfg.Param[1])
    elseif cfg.Type == GameConst.CardRewardType.StarSuitPhaseLevelReach then
        local cardBaseCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
        if cardBaseCfg and cardBaseCfg.SuitID > 0 then
            local suitCards = SelfProxyFactory.GetCardDataProxy():GetSuitCards(cardBaseCfg.SuitID)
            if not table.isnilorempty(suitCards) then
                local t = PoolUtil.GetTable()
                for _, v in ipairs(suitCards) do
                    table.insert(t, UITextHelper.GetUIText(LuaCfgMgr.Get("CardBaseInfo", v).Name))
                end
                table.insert(t, cfg.Param[1])
                local desc = UITextHelper.GetUIText(cfg.Desc, table.unpack(t))
                PoolUtil.ReleaseTable(t)
                return desc
            end
        end
    end
    return UITextHelper.GetUIText(cfg.Desc)
end

---获取任务当前值和期望值
---@param cfg cfg.CardReward
---@return int, int
local function GetQuestVal(cardId, cfg)
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardId)
    local curVal = 0
    local tarVal = 0
    if cfg.Type == GameConst.CardRewardType.LevelReach then
        curVal = cardData:GetLevel()
        tarVal = cfg.Param[1]
    elseif cfg.Type == GameConst.CardRewardType.PhaseLevelReach then
        curVal = cardData:GetPhaseLevel()
        tarVal = cfg.Param[1]
    elseif cfg.Type == GameConst.CardRewardType.AwakenReach then
        curVal = cardData:GetAwaken()
        tarVal = cfg.Param[1]
    elseif cfg.Type == GameConst.CardRewardType.StarLevelReach then
        curVal = cardData:GetStarLevel()
        tarVal = cfg.Param[1]
    elseif cfg.Type == GameConst.CardRewardType.StarSuitPhaseLevelReach then
        local suitPhaseLevel = SelfProxyFactory.GetCardDataProxy():GetSuitPhaseLevelByCard(cardId)
        if cfg.Param[1] == 0 then
            --0代表套装解锁，其他数值代表套装培养到指定品阶
            curVal = suitPhaseLevel >= 0 and 1 or 0
            tarVal = 1
        else
            curVal = suitPhaseLevel >= 0 and suitPhaseLevel or 0
            tarVal = cfg.Param[1]
        end
    end
    if curVal > tarVal then
        curVal = tarVal
    end
    return curVal, tarVal
end

---@return CardQuestListItem[]
function CardBLL:GetCardQuestList(cardId)
    local questList = SelfProxyFactory.GetCardDataProxy():GetCardQuestList(cardId)
    if table.isnilorempty(questList) then
        return nil
    end
    local questListItems = {}
    for rewardId, status in pairs(questList) do
        repeat
            local cfg = LuaCfgMgr.Get("CardReward", rewardId)
            if not cfg then
                break
            end
            if cfg.FrontRewardID > 0 and questList[cfg.FrontRewardID] and questList[cfg.FrontRewardID] ~= GameConst.CardQuestStatus.Rewarded then
                --有前置任务且前置任务未领奖，不显示
                break
            end
            ---@type CardQuestListItem
            local item = {}
            item.RewardId = rewardId
            item.Status = status
            item.Cfg = cfg
            item.Desc = GetQuestDesc(cardId, cfg)
            item.CurVal, item.TarVal = GetQuestVal(cardId, cfg)
            table.insert(questListItems, item)
        until true
    end
    table.sort(questListItems, QuestSort)
    return questListItems
end

---@return CardQuestListItem[]
function CardBLL:GetCardSuitQuestList(cardId)
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg or cardCfg.SuitID <= 0 then
        return nil
    end
    local questList = SelfProxyFactory.GetCardDataProxy():GetCardSuitQuestList(cardCfg.SuitID)
    if table.isnilorempty(questList) then
        return nil
    end
    local questListItems = {}
    for rewardId, status in pairs(questList) do
        repeat
            local cfg = LuaCfgMgr.Get("CardReward", rewardId)
            if not cfg then
                break
            end
            if cfg.FrontRewardID > 0 and questList[cfg.FrontRewardID] and questList[cfg.FrontRewardID] ~= GameConst.CardQuestStatus.Rewarded then
                --有前置任务且前置任务未领奖，不显示
                break
            end
            ---@type CardQuestListItem
            local item = {}
            item.RewardId = rewardId
            item.Status = status
            item.Cfg = cfg
            item.Desc = GetQuestDesc(cardId, cfg)
            item.CurVal, item.TarVal = GetQuestVal(cardId, cfg)
            table.insert(questListItems, item)
        until true
    end
    table.sort(questListItems, QuestSort)
    return questListItems
end
---单卡任务是否可领取
---@param cardId number
---@return bool
function CardBLL:CardQuestCanGet(cardId)
    local questList = SelfProxyFactory.GetCardDataProxy():GetCardQuestList(cardId)
    if table.isnilorempty(questList) then
        return false
    end
    for _, status in pairs(questList) do
        if status == GameConst.CardQuestStatus.Finish then
            return true
        end
    end
    return false
end

---套装任务是否可领取
---@param cardId number
---@return bool
function CardBLL:SuitQuestCanGet(cardId)
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg or cardCfg.SuitID <= 0 then
        return false
    end
    local questList = SelfProxyFactory.GetCardDataProxy():GetCardSuitQuestList(cardCfg.SuitID)
    if table.isnilorempty(questList) then
        return false
    end
    for _, status in pairs(questList) do
        if status == GameConst.CardQuestStatus.Finish then
            return true
        end
    end
    return false
end

--endregion


--region  红点相关

---红点刷新检测
---@param redId number 红点配置id
function CardBLL:OnRedPointCheck(redId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    local cardList = SelfProxyFactory.GetCardDataProxy():GetCardList()
    if not cardList or #cardList == 0 then
        return
    end
    if redId == X3_CFG_CONST.RED_NEW_CARD_NEW then
        --新获得,此阶段
        for _, v in ipairs(cardList) do
            self:CheckNewRed(v:GetPrimaryValue())
        end
    elseif redId == X3_CFG_CONST.RED_NEW_CARD_BREAK then
        --可突破
        for _, v in ipairs(cardList) do
            self:CheckStarUpRed(v:GetPrimaryValue())
        end
    elseif redId == X3_CFG_CONST.RED_CARD_AWAKE then
        --可觉醒
        for _, v in ipairs(cardList) do
            self:CheckAwakeRp(v:GetPrimaryValue())
        end
    elseif redId == X3_CFG_CONST.RED_CARD_ADVANCE then
        --可升阶
        for _, v in ipairs(cardList) do
            self:CheckPhaseUpRed(v:GetPrimaryValue())
        end
    elseif redId == X3_CFG_CONST.RED_CHIP_COMPOSE then
        --可合成
        for _, v in ipairs(cardList) do
            self:ClearCardComposeRp(v:GetPrimaryValue())
        end
    elseif redId == X3_CFG_CONST.RED_SUIT_TAB1_REWARD then
        --单卡任务可领取
        for _, v in ipairs(cardList) do
            self:CheckCardQuestRed(v:GetPrimaryValue())
        end
    elseif redId == X3_CFG_CONST.RED_SUIT_TAB2_REWARD then
        --套卡任务可领取
        for _, v in ipairs(cardList) do
            self:CheckSuitQuestRed(v:GetPrimaryValue())
        end
    end
end

function CardBLL:CheckCardAllRed(card_id)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not card_id then
        local cardList = SelfProxyFactory.GetCardDataProxy():GetCardList()
        for _, v in pairs(cardList) do
            self:CheckCardAllRed(v:GetPrimaryValue())
        end
        return
    end
    self:CheckNewRed(card_id)
    self:CheckPhaseUpRed(card_id)
    self:CheckStarUpRed(card_id)
    self:CheckAwakeRp(card_id)
    self:CheckCardQuestRed(card_id)
    self:CheckSuitQuestRed(card_id)
    if self:HasCard(card_id) then
        self:ClearCardComposeRp(card_id)
    end
end

function CardBLL:ClearCardAllRed(cardId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not cardId then
        local cardList = SelfProxyFactory.GetCardDataProxy():GetCardList()
        for _, v in pairs(cardList) do
            self:CheckCardAllRed(v:GetPrimaryValue())
        end
        return
    end
    RedPointMgr.Save(0, X3_CFG_CONST.RED_NEW_CARD_NEW, cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_CARD_NEW, 0, cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_CARD_ADVANCE, 0, cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_CARD_BREAK, 0, cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_CARD_AWAKE, 0, cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SUIT_TAB1_REWARD, 0, cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SUIT_TAB2_REWARD, 0, cardId)
end

---新获得红点
function CardBLL:CardIsNew(cardID)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_NEW_CARD_NEW, cardID)
    return redValue == 0
end

---清除新获得红点
function CardBLL:ClearCardNewRp(cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_CARD_NEW, 0, cardId)
    RedPointMgr.Save(1, X3_CFG_CONST.RED_NEW_CARD_NEW, cardId)
end

---清除所有新获得红点
function CardBLL:ClearAllCardNewFlag()
    local allCardMap = SelfProxyFactory.GetCardDataProxy():GetCardList()
    for _, v in pairs(allCardMap) do
        local id = v:GetPrimaryValue()
        if self:CardIsNew(id) then
            self:ClearCardNewRp(id)
        end
    end
end

--新获得红点
function CardBLL:CheckNewRed(cardId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not cardId then
        return
    end
    if RedPointMgr.IsInit() then
        RedPointMgr.Save(1, X3_CFG_CONST.RED_NEW_CARD_NEW, cardId)
    else
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_CARD_NEW, self:CardIsNew(cardId) and 1 or 0, cardId)
    end
end

--突破红点
function CardBLL:CheckStarUpRed(cardId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not cardId then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_CARD_BREAK, self:CardCanBreak(cardId) and 1 or 0, cardId)
end

--升阶红点
function CardBLL:CheckPhaseUpRed(cardId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not cardId then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_CARD_ADVANCE, self:CardCanPhaseUp(cardId) and 1 or 0, cardId)
end

--觉醒红点
function CardBLL:CheckAwakeRp(cardId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not cardId then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_CARD_AWAKE, self:CardCanAwaken(cardId) and 1 or 0, cardId)
end

--单卡任务红点
function CardBLL:CheckCardQuestRed(cardId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not cardId then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SUIT_TAB1_REWARD, self:CardQuestCanGet(cardId) and 1 or 0, cardId)
end

--套卡任务红点
function CardBLL:CheckSuitQuestRed(cardId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_FETTERS) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not cardId then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SUIT_TAB2_REWARD, self:SuitQuestCanGet(cardId) and 1 or 0, cardId)
end

---清除碎片可合成红点
function CardBLL:ClearCardComposeRp(cardId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_CHIP_COMPOSE, 0, cardId)
end

---羁绊卡碎片红点
function CardBLL:CheckCardComposeRp(itemId)
    if itemId then
        self:CheckCardComposeRpByItemId(itemId)
    else
        local itemList = BllMgr.GetItemBLL():GetLocalItemByType(X3_CFG_CONST.ITEM_TYPE_CARDFRAGMENT)
        for i = 1, #itemList do
            self:CheckCardComposeRpByItemId(itemList[i].ID)
        end
    end
end

function CardBLL:CheckCardComposeRpByItemId(itemId)
    ---@type cfg.Item
    local itemCfg = LuaCfgMgr.Get("Item", itemId)
    if itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_CARDFRAGMENT then
        local itemNum = BllMgr.GetItemBLL():GetItemNum(itemId)
        local cardId = itemCfg.ConnectID
        local cardBaseInfoCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
        local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardId)
        if cardBaseInfoCfg ~= nil then
            if cardData == nil then
                local cardRareInfo = LuaCfgMgr.Get("CardRare", cardBaseInfoCfg.Quality)
                local gold = BllMgr.GetPlayerBLL():GetPlayerCoin().Gold
                local canCompose = gold >= cardRareInfo.ComposeMoneyCost and itemNum >= cardRareInfo.FragmentNum
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_CHIP_COMPOSE, canCompose and 1 or 0, cardId)
            else
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_CHIP_COMPOSE, 0, cardId)
            end
        else
            Debug.LogError("card 碎片未找到关联cardBaseInfo 配置问题 itemId", itemId)
        end
    end
end

--endregion

---是否是动卡
function CardBLL:IsDynamicCard(cardId)
    if not cardId then
        return false
    end
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardCfg then
        return false
    end
    return cardCfg.IsDynamic == 1
end

--region 高光时刻

--- 检查是否配置了高光时刻的剧情
function CardBLL:CheckHighLightDialogueEnable(cardId)
    local cardBaseCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if not cardBaseCfg then
        return false
    end
    local dialogueId = cardBaseCfg.DialogueID or -1
    if dialogueId ~= nil and dialogueId > 0 then
        return true
    end
    return false
end

---获取关联的传说ID(等于ScoreId)
function CardBLL:GetLinkStoryInfo(cardId)
    local scoreId = SelfProxyFactory.GetScoreProxy():GetScoreIdByCardId(cardId)
    if not scoreId then
        return nil
    end
    local legendStoryInfo = LuaCfgMgr.Get("LegendStoryInfo", scoreId)
    return legendStoryInfo
end

---获取关联的AVGID
function CardBLL:GetLinkAvgInfo(cardId)
    local specialDateEntry = SelfProxyFactory.GetSpecialDateProxy():GetValidSpecialDateCfg(cardId)
    return specialDateEntry
end

---获取思念关联的下载资源
---@return Define.SubPackageType,number
function CardBLL:GetCardLinkSubPack(cardId)
    local subPackageType, subPackageId
    local linkStoryInfo = self:GetLinkStoryInfo(cardId)
    local linkAvgInfo = self:GetLinkAvgInfo(cardId)
    if linkStoryInfo then
        subPackageType = Define.SubPackageType.Legend
        subPackageId = linkStoryInfo.SCoreID
    elseif linkAvgInfo then
        subPackageType = Define.SubPackageType.CardDate
        subPackageId = linkAvgInfo.ID
    else
        Debug.LogFormatWithTag(GameConst.LogTag.DynamicCard, "思念[%s]未关联传说约会或思念约会。", tostring(cardId))
    end
    return subPackageType, subPackageId
end

---判断动卡资源是否下载了
function CardBLL:CheckDynamicCardDownloaded(cardId)
    if not cardId then
        return false
    end
    local subPackageType, subPackageId = BllMgr.GetCardBLL():GetCardLinkSubPack(cardId)
    if subPackageType == nil then
        return false
    end
    local havSubPackage = SubPackageUtil.IsHaveSubPackage(subPackageType, Define.SupPackageSubType.DEFAULT, subPackageId)
    return havSubPackage
end

---判断动卡本地资源是否存在
function CardBLL:CheckDynamicCardResExist(cardId)
    if not cardId then
        return false
    end
    ---@type table<int, cfg.CardDynamic>
    local cardDynamicCfgs = LuaCfgMgr.Get("CardDynamic", cardId)
    if not cardDynamicCfgs then
        return false
    end
    for _, cardDynamicCfg in pairs(cardDynamicCfgs) do
        local sceneCfg = LuaCfgMgr.Get("SceneInfo", cardDynamicCfg.SceneName)
        if not sceneCfg then
            Debug.LogFormatWithTag(GameConst.LogTag.DynamicCard, "获取场景配置失败：%s", tostring(cardDynamicCfg.SceneName))
            return false
        end
        if not Res.IsAssetFileExist(sceneCfg.ScenePath) then
            Debug.LogFormatWithTag(GameConst.LogTag.DynamicCard, "场景资源本地不存在：%s", tostring(sceneCfg.ScenePath))
            return false
        end
        local ctsPath = CutSceneMgr.GetCTSPath(cardDynamicCfg.CutSceneName)
        if not Res.IsAssetFileExist(ctsPath) then
            Debug.LogFormatWithTag(GameConst.LogTag.DynamicCard, "CTS资源本地不存在：%s", tostring(ctsPath))
            return false
        end
    end
    return true
end

---获取思念横卡图片资源
---@return string
function CardBLL:GetCardFullImg(cardId)
    if not cardId or cardId <= 0 then
        return nil
    end
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    if cardCfg == nil or string.isnilorempty(cardCfg.CardFullImage) then
        return nil
    end
    return cardCfg.CardFullImage
end

---判断思念横卡是否可用，没有横卡、横卡未下载都是false
---@return boolean
function CardBLL:CheckCardFullImgValid(cardId)
    if not cardId or cardId <= 0 then
        return false
    end
    local cardFullImg = self:GetCardFullImg(cardId)
    if string.isnilorempty(cardFullImg) then
        return false
    end
    local downloaded = SubPackageUtil.IsHaveSubPackage(Define.SubPackageType.DevelopCard, Define.SupPackageSubType.DEFAULT, cardId)
    return downloaded
end

--开启高光时刻
function CardBLL:TryEnterHighLight(cardId)
    if not self:CheckHighLightDialogueEnable(cardId) then
        return
    end
    local subPackageType, subPackageId = self:GetCardLinkSubPack(cardId)
    if subPackageType == nil then
        return
    end
    SubPackageUtil.EnterSystem(subPackageType, Define.SupPackageSubType.DEFAULT, subPackageId, function()
        UICommonUtil.ThreeStageMotionIn(GameConst.FullScreenMotionKey.OCX_HighLight_in, function()
            GameStateMgr.Switch(GameState.CardHighLight, cardId)
        end)
    end)
end

--endregion

--region 动卡生成静态图
---@class GenCardInfo
---@field cardId int
---@field name string
---@field screenShotSize Vector2
---@field iconW int
---@field iconH int
---@field offset Vector2
---@field height int
---@field needSetClothBias bool

---@param genImgList GenCardInfo[]
---@param cardData X3Data.CardData
function CardBLL:GetGenImgList(cardData, genImgList, forceUpdate)
    local cardId =  cardData:GetPrimaryValue()
    local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
    local cardDynamic = LuaCfgMgr.Get("CardDynamic", cardId, 1)
    local needGen = false

    if cardDynamic == nil or cardDynamic.IsNeedFemale ~= 1 or not self:CheckDynamicCardDownloaded(cardId) then
        return needGen
    end

    local cardImgData = X3DataMgr.Get(X3DataConst.X3Data.CardLocalImgInfo, cardId)
    local cardFaceVersion = cardImgData and cardImgData:GetFaceVersion() or -1
    local curFaceVersion = BllMgr.GetFaceBLL():GetFaceVersion()

    local largeSize = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.BIGCARDIMGSIZE)
    local midSize = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MIDDLECARDIMGSIZE)
    local smallSize = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.SMALLCARDIMGSIZE)

    local uid = PlayerUtil.GetUid()
    local largeCardName = UrlImgMgr.GetLocalImgName(cardCfg.CardImage, uid)
    local middleCardName = UrlImgMgr.GetLocalImgName(cardCfg.CardMiddleImage, uid)
    local smallCardName = UrlImgMgr.GetLocalImgName(cardCfg.CardSmallImage, uid)
    local screenSize = CS.X3Game.CameraUtility.GetScreenSize()
    if cardFaceVersion ~= curFaceVersion or not UrlImgMgr.CheckFile(largeCardName, UrlImgMgr.BizType.DynamicCard) or forceUpdate then
        needGen = true

        if genImgList then
            local info = {}
            info.cardId = cardId
            info.name = largeCardName
            info.screenShotSize =  largeSize
            info.iconW = largeSize.x
            info.iconH = largeSize.y
            info.offset = Vector2(0,0)
            info.height = largeSize.y
            info.needSetClothBias = false
            table.insert(genImgList, info)
        end
    end

    if cardDynamic.MiddleCardScreenshotHeight ~= 0 and cardDynamic.MiddleCardOffset and
            (cardFaceVersion ~= curFaceVersion or not UrlImgMgr.CheckFile(middleCardName, UrlImgMgr.BizType.DynamicCard) or forceUpdate) then
        needGen = true

        if genImgList then
            local info = {}
            info.cardId = cardId
            info.name = middleCardName
            info.screenShotSize = largeSize
            info.iconW = midSize.x
            info.iconH = midSize.y
            info.offset = cardDynamic.MiddleCardOffset
            info.height = cardDynamic.MiddleCardScreenshotHeight
            info.needSetClothBias = true
            table.insert(genImgList, info)
        end
    end

    if cardDynamic.SmallCardScreenshotHeight ~= 0 and cardDynamic.SmallCardOffset and
            (cardFaceVersion ~= curFaceVersion or not UrlImgMgr.CheckFile(smallCardName, UrlImgMgr.BizType.DynamicCard)  or forceUpdate) then
        needGen = true

        if genImgList then
            local info = {}
            info.cardId = cardId
            info.name = smallCardName
            info.screenShotSize = largeSize
            info.iconW = smallSize.x
            info.iconH = smallSize.y
            info.offset = cardDynamic.SmallCardOffset
            info.height = cardDynamic.SmallCardScreenshotHeight
            info.needSetClothBias = true
            table.insert(genImgList, info)
        end
    end
    return needGen
end

--endregion
return CardBLL

