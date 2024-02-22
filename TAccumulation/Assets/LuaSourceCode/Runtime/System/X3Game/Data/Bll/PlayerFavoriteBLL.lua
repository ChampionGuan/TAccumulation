﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2022/3/3 11:03
---@class PlayerFavoriteBLL:BaseBll
local PlayerFavoriteBLL = class("PlayerFavoriteBLL", BaseBll)

function PlayerFavoriteBLL:OnInit()
    ---@type table<string, int>
    self._randomTagDict = {}
    ---@type table<int, table<int, bool>>
    self._randomFilter = {}

    local resetTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.COMMONDAILYRESETTIME)
    local sp = string.split(resetTime,":")
    ---固定每日刷新时间
    ---@type int
    self.daily_reset_hour = tonumber(sp and sp[1] or 0)

    EventMgr.AddListener("PLAYERTAG_TAG_CHOOSE_RESULT", self.OnTagChooseResultBack, self)
end

function PlayerFavoriteBLL:OnClear()
    EventMgr.RemoveListenerByTarget( self)
end

function PlayerFavoriteBLL:OnTagChooseResultBack(arg)
    if arg.params == nil then
        return
    end

    local roleId = tonumber(arg.params[4])
    local tagId = self:GetTagId(tonumber(arg.params[2]), roleId)
    local addScores = { [tagId] = tonumber(arg.params[3]) }
    local chooseIds = tonumber(arg.params[5]) == 1 and { tagId } or {}
    local appearIds = { tagId }

    BllMgr.GetPlayerFavoriteBLL():SendPlayerTagChooseRequest(roleId, chooseIds, appearIds, addScores)
end

function PlayerFavoriteBLL:GetTagId(inputId, roleId, dialogueCtrl)
    if inputId == -1  then
        return BllMgr.GetPlayerFavoriteBLL():GetRandomTag("DailyRecipeFoodName") or -1
    elseif inputId == -2 then
        return dialogueCtrl and dialogueCtrl:GetVariableState(1) or -2
    elseif inputId == -3 then
        return self:GetWeeklyFavoriteFoodId(roleId) or -3
    end

    return inputId
end

function PlayerFavoriteBLL:ResetRandomKey(key)
    self._randomTagDict[key] = nil
end

function PlayerFavoriteBLL:GetRandomTag(key)
    return self._randomTagDict[key]
end

function PlayerFavoriteBLL:AddRandomFilter(roleId, tagId)
    if roleId == nil then
        return
    end

    if self._randomFilter[roleId] == nil then
        self._randomFilter[roleId] = {}
    end

    self._randomFilter[roleId][tagId] = true
end

function PlayerFavoriteBLL:ClearRandomFilter(roleId)
    if roleId then
        self._randomFilter[roleId] = nil
    else
        self._randomFilter = {}
    end
end

---random
------@param tagType int
-----@param feature int[]
-----@param level int[]
-----@param useWeight bool
-----@param roleId int
function PlayerFavoriteBLL:TagRandom(key, tagType, feature, level, useWeight, roleId)
    local rst = self:_InternalTagRandom(tagType, feature, level, useWeight, roleId)
    if key ~= nil then
        self._randomTagDict[key] = rst
    end

    if not rst then
        Debug.Log("!!!")
    end

    return rst
end
---@param tagType int
---@param feature int[]
---@param levels int[]
---@param useWeight bool
---@param roleId int
function PlayerFavoriteBLL:_InternalTagRandom(tagType, feature, levels, useWeight, roleId)
    ---@type table<int, cfg.PlayerTag>
    local allTags = LuaCfgMgr.GetAll("PlayerTag")
    ---@class randomInfo
    ---@field id int
    ---@field weight int

    ---@type table<int, randomInfo>
    local randomTagsRaw = {}
    local totalWeight = 0
    local totalCount = 0
    local fallBack = nil

    for _, v in pairs(allTags) do
        local tagLevel, levelWeight = self:GetLevelAndWeight(roleId, v)
        if v.Type == tagType and self:CheckFeature(v, feature) and (levels == nil or #levels == 0 or self:CheckLevels(tagLevel, levels)) then
            totalWeight = totalWeight + (useWeight == 1 and levelWeight or 1)
            totalCount = totalCount + 1
            table.insert(randomTagsRaw, { id = v.ID, weight = useWeight and levelWeight or 1 })
        end

        if not fallBack and v.Type == tagType then
            fallBack = v.ID
        end
    end

    if totalWeight == 0 and totalCount == 0 then
        return fallBack
    end

    local randomTags = {}

    totalWeight = 0
    totalCount = 0
    for i = 1, #randomTagsRaw do
        if self._randomFilter[roleId] == nil or self._randomFilter[roleId][randomTagsRaw[i].id] ~= true then
            totalWeight = totalWeight + randomTagsRaw[i].weight
            totalCount = totalCount + 1
            table.insert(randomTags, { id = randomTagsRaw[i].id, weight = totalWeight })
        end
    end

    if totalWeight == 0 and totalCount == 0 then
        for i = 1, #randomTagsRaw do
            totalWeight = totalWeight + randomTagsRaw[i].weight
            totalCount = totalCount + 1
            table.insert(randomTags, { id = randomTagsRaw[i].id, weight = totalWeight })
        end
    end

    if totalWeight > 0 then
        local randomW = math.random(1, totalWeight)

        for i = 1, #randomTags do
            if randomW <= randomTags[i].weight then
                return randomTags[i].id
            end
        end
    elseif totalCount > 0 then
        local randomW = math.random(1, #randomTags)
        return randomTags[randomW].id
    end

    return fallBack
end

--region UITextReplace
function PlayerFavoriteBLL:GetRandomTagName(key)
    if self._randomTagDict[key] == nil then
        return ""
    end
    return UITextHelper.GetUIText((LuaCfgMgr.Get("PlayerTag", self._randomTagDict[key] or {})).Name)
end

---GetFavoriteName
function PlayerFavoriteBLL:GetFavoriteName(roleId, id)
    local id = self:GetFavoriteId(roleId, id)
    if id then
        local cfg = LuaCfgMgr.Get("PlayerTag", id)
        if cfg then
            return UITextHelper.GetUIText(cfg.Name)
        end
    end
end

---GetFavoriteId
function PlayerFavoriteBLL:GetFavoriteId(roleId, id)
    ---@type cfg.PlayerFavorites
    local cfg = LuaCfgMgr.Get("PlayerFavorites", id)
    if cfg == nil then
        return
    end

    ---如果有存的信息，则随机一个
    local savedData = SelfProxyFactory.GetPlayerFavoriteProxy():GetFavorite(roleId, id)
    if savedData ~= nil and savedData.List ~= nil and #savedData.List then
        return savedData.List[math.random(1, #savedData.List)]
    end

    ---如果没有记录则开始分数及选择率的计算
    ---@type table<int, cfg.PlayerTag>
    local allTags = LuaCfgMgr.GetAll("PlayerTag")

    ---@type cfg.PlayerTag
    local favoriteTag = nil

    for k, v in pairs(allTags) do
        if v.Type == cfg.ReferenceType and self:CheckFeature(v, cfg.ReferenceExtraFeature) then
            if favoriteTag == nil or self:TagCompare(roleId, v, favoriteTag, cfg.Positive == 1) then
                favoriteTag = v
            end
        end
    end

    return favoriteTag and favoriteTag.ID or nil
end

function PlayerFavoriteBLL:GetLastAcceptFood(roleId)
    local proxy = SelfProxyFactory.GetPlayerFavoriteProxy()
    local lastAccept = proxy:GetLastAcceptFood(roleId)
    if lastAccept then
        local cfg = LuaCfgMgr.Get("PlayerTag", lastAccept:GetPrimaryValue())
        if cfg then
            return UITextHelper.GetUIText(cfg.Name)
        end
    end

    return ""
end

function PlayerFavoriteBLL:GetWeeklyFavoriteFoodId(roleId)
    return SelfProxyFactory.GetPlayerFavoriteProxy():GetWeeklyFavoriteFood(roleId)
end
function PlayerFavoriteBLL:GetWeeklyFavoriteFood(roleId)
    local tagId = self:GetWeeklyFavoriteFoodId(roleId)

    if tagId then
        local cfg = LuaCfgMgr.Get("PlayerTag", tagId)
        if cfg then
            return UITextHelper.GetUIText(cfg.Name)
        end
    end
    return ""
end

--endregion


--region 筛选相关
---@param tagCfg cfg.PlayerTag
---@param features int[]
function PlayerFavoriteBLL:CheckFeature(tagCfg, features)
    if features == nil or #features == 0 then
        return true
    end

    if tagCfg.ExtraFeature == nil or #tagCfg.ExtraFeature == 0 then
        return false
    end

    local featureDict = { }

    for i = 1, #features do
        featureDict[features[i]] = 0
    end

    for i = 1, #tagCfg.ExtraFeature do
        local extraFeature = tagCfg.ExtraFeature[i]
        if featureDict[extraFeature] == 0 then
            featureDict[extraFeature] = 1
        end
    end

    for _, v in pairs(featureDict) do
        if v == 0 then
            return false
        end
    end

    return true
end

---@param roleId int
---@param cfg cfg.PlayerTag
function PlayerFavoriteBLL:GetLevelAndWeight(roleId, cfg)
    local score = SelfProxyFactory.GetPlayerFavoriteProxy():GetTagScoreWithCfg(roleId, cfg)

    if cfg == nil then
        return 1, 0
    end

    ---@type cfg.PlayerTagType
    local typeCfg = LuaCfgMgr.Get("PlayerTagType", cfg.Type)
    if typeCfg == nil or typeCfg.Level == nil then
        return 1, 0
    end

    local levels = typeCfg.Level
    for i = 1, #levels do
        if score < levels[i] then
            return i, (typeCfg.LevelWeight or {})[i] or 0
        end
    end
    return #levels + 1, (typeCfg.LevelWeight or {})[#levels + 1] or 0
end

function PlayerFavoriteBLL:CheckLevels(level, levels)
    for i = 1, levels do
        if level == levels[i] then
            return true
        end
    end
end

---@param tagA cfg.PlayerTag
---@param tagB cfg.PlayerTag
---@param larger bool
function PlayerFavoriteBLL:TagCompare(roleId, tagA, tagB, larger)
    if tagA == nil then
        return false
    end

    if tagB == nil then
        return true
    end

    local scoreA = SelfProxyFactory.GetPlayerFavoriteProxy():GetTagScoreWithCfg(roleId, tagA)
    local scoreB = SelfProxyFactory.GetPlayerFavoriteProxy():GetTagScoreWithCfg(roleId, tagB)

    if scoreA ~= scoreB then
        if larger then
            return scoreA > scoreB
        else
            return scoreA < scoreB
        end
    end

    local chooseA = SelfProxyFactory.GetPlayerFavoriteProxy():GetTagChoosePercent(roleId, tagA.ID)
    local chooseB = SelfProxyFactory.GetPlayerFavoriteProxy():GetTagChoosePercent(roleId, tagB.ID)

    if chooseA ~= chooseB then
        if larger then
            return chooseA > chooseB
        else
            return chooseA < chooseB
        end
    end

    return tagA.ID < tagB.ID
end
--endregion

--region 协议发送
---@param roleId int
---@param chooseIds int[]
---@param appearIds int[]
---@param addScores table<int, int>
function PlayerFavoriteBLL:SendPlayerTagChooseRequest(roleId, chooseIds, appearIds, addScores)
    ---@type pbcmessage.PlayerTagChooseRequest
    local data = { RoleID = roleId, ChooseIDs = chooseIds, AppearIDs = appearIds, AddScores = addScores }
    GrpcMgr.SendRequest(RpcDefines.PlayerTagChooseRequest, data)
end

function PlayerFavoriteBLL:SendSetPlayerFavoriteRequest(roleId, typeId, tagId)
    ---@type pbcmessage.PlayerTagChooseRequest
    local data = { RoleID = roleId, ID = typeId, Favorite = tagId }
    GrpcMgr.SendRequest(RpcDefines.SetPlayerFavoriteRequest, data)
end

function PlayerFavoriteBLL:SendAcceptRecommendRequest(roleId, tagId, recommendNum, reject)
    ---@type pbcmessage.AcceptRecommendRequest
    local data = { RoleID = roleId, TagID = tagId, RecommendNum = recommendNum, IsReject = reject }
    GrpcMgr.SendRequest(RpcDefines.AcceptRecommendRequest, data, true)
end
--endregion

--region conditionCheck
function PlayerFavoriteBLL:CheckCondition(conditionType, data, iDataProvider)
    if conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_TAG_SCORE_CHECK then
        return self:CheckTagValue(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]), tonumber(data[4]), tonumber(data[5]))
    elseif conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_FAVORITE_CHECK then
        return self:CheckFavoriteTag(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]))
    elseif conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_FAVORITE_EXIST then
        if tonumber(data[3]) == 1 then
            return self:CheckHasSavedFavorite(tonumber(data[1]), tonumber(data[2]))
        else
            return not self:CheckHasSavedFavorite(tonumber(data[1]), tonumber(data[2]))
        end
    elseif conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_SCORE_CHECK then
        if tonumber(data[5]) == 1 then
            return self:ScoreCheck(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]), tonumber(data[4]))
        else
            return not self:ScoreCheck(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]), tonumber(data[4]))
        end
    elseif conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_WEEKLY_PICK then
        return self:CheckWeeklyChoice(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]), tonumber(data[4]), tonumber(data[5]))
    elseif conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_FOOD_TODAY_LAST_PICK then
        return self:CheckDailyLastPickNum(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]))
    elseif conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_SCORE_ADD_NUM_WEEK then
        return self:CheckWeeklyContinueChangeNum(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]), tonumber(data[4]), tonumber(data[5]), true, X3_CFG_CONST.CONDITION_PLAYERTAG_SCORE_ADD_NUM_WEEK)
    elseif conditionType == X3_CFG_CONST.CONDITION_PLAYERTAG_SCORE_DECREASE_NUM_WEEK then
        return self:CheckWeeklyContinueChangeNum(tonumber(data[1]), tonumber(data[2]), tonumber(data[3]), tonumber(data[4]), tonumber(data[5]), false, X3_CFG_CONST.CONDITION_PLAYERTAG_SCORE_DECREASE_NUM_WEEK)
    end
end

function PlayerFavoriteBLL:CheckTagValue(roleId, tagId, min, max, checkType)
    local score = SelfProxyFactory.GetPlayerFavoriteProxy():GetTagScoreWithId(roleId, tagId)
    return (score >= min or checkType == 2) and (score <= max or checkType == 1)
end

function PlayerFavoriteBLL:CheckFavoriteTag(roleId, typeId, tagId)
    return self:GetFavoriteId(roleId, typeId) == tagId
end

function PlayerFavoriteBLL:CheckHasSavedFavorite(roleId, typeId)
    local favorite = SelfProxyFactory.GetPlayerFavoriteProxy():GetFavorite(roleId, typeId)
    return favorite ~= nil and favorite.List ~= nil and #favorite.List
end

function PlayerFavoriteBLL:ScoreCheck(roleId, tagType, compareType, checkValue)
    ---@type table<int, cfg.PlayerTag>
    local allTag = LuaCfgMgr.GetAll("PlayerTag")
    ---@type cfg.PlayerFavorites
    local cfg = LuaCfgMgr.Get("PlayerFavorites", tagType)
    if cfg == nil then
        return false
    end

    local proxy = SelfProxyFactory.GetPlayerFavoriteProxy()
    for _, v in pairs(allTag) do
        if v.Type == cfg.ReferenceType and self:ScoreCompare(proxy:GetTagScoreWithId(roleId, v.ID), compareType, checkValue) then
            return true
        end
    end

    return false
end

--【Para3】数值关系，0：等于，1：大于等于，2：小于等于
function PlayerFavoriteBLL:ScoreCompare(tagScore, compareType, checkValue)
    if compareType == 0 then
        return tagScore == checkValue
    elseif compareType == 1 then
        return tagScore >= checkValue
    elseif compareType == 2 then
        return tagScore <= checkValue
    end

    return false
end

function PlayerFavoriteBLL:CheckWeeklyChoice(roleId, tagType, tagId, min, max)
    local proxy = SelfProxyFactory.GetPlayerFavoriteProxy()
    local num = proxy:GetWeeklyChoiceNum(roleId, tagType, tagId)
    return num >= min and (num <= max or max == -1)
end

function PlayerFavoriteBLL:CheckDailyLastPickNum(roleId, min, max)
    local proxy = SelfProxyFactory.GetPlayerFavoriteProxy()
    local lastPick = proxy:GetLastAcceptFood(roleId)
    if lastPick then
        local num = lastPick:GetRecommendNum()
        return num and num >= min and (num <= max or max == -1)
    end

    return false
end

function PlayerFavoriteBLL:CheckWeeklyContinueChangeNum(roleId, tagId, checkType, min, max, isAdd, conditionId)
    if min == -1 and max == -1 then
        Debug.LogErrorFormat("条件%d，区间不能同时配置为-1", conditionId)
        return false
    end
    local num =  SelfProxyFactory.GetPlayerFavoriteProxy():GetWeeklyContinueChangeNum(roleId, tagId, isAdd)
    local isInRange = (num >= min or min == -1) and (num <= max or max == -1 )
    if checkType == 0 then
        return not isInRange
    else
        return isInRange
    end
end
--endregion

return PlayerFavoriteBLL