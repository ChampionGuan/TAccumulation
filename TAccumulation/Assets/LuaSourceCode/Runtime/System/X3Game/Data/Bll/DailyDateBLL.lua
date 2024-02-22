---
--- Client (C) CompanyName, All Rights Reserved
--- Created by: 峻峻
--- Date: 2020-08-14 14:32:03
---
---日常约会逻辑层
---@class DailyDateBLL
local DailyDateBLL = class("DailyDateBLL", BaseBll)
local OpenTimeData = require("Runtime.System.X3Game.Modules.OpenTime.OpenTimeData")

---@type DailyDateProxy
local proxy = nil
---@type boolean 日常约会UI是否已经开启过
local dailyDateWndOpened = false
---@type int[] 已经注册过的TimerId
local registeredTimerId = nil
---@type table<int, int> 红点ID索引
local redPointIdDict = nil
---@type table<int, int[]> 已检查的New列表
local checkedNewRecordMap = nil
---@type table<int, bool> 已经查看过的娃娃池列表
local dollDropGroupCheckedDict = nil
---@type table<int, table<int, bool>> 当前所有男主的娃娃池列表
local dollDropGroupIdDict = nil
---@type int[] 上次打开的SubId列表
local lastSubIdMap = nil
---@type table<int, OpenTimeData> NormalDoll开启时间缓存
local ufoCatcherNormalDoll = nil
---@type fun 进入回调
local enterCallback = nil
---@type int 检查Timer
local checkTimerId = 0
---@type table<int, int[]> 娃娃索引，减少扫表
local roleDollDict = nil
---@type table<int, DollItemData> 变色娃娃索引，减少扫表
local dollItemDict = nil

---@class DollItemData
---@field originId int 原色娃娃Id
---@field colorList int[] 所有变色娃娃Id列表
---@field collectedColorAll table<int, boolean> 是否集齐了所有变色娃娃，key为ManType
---@field collectedToday table<int, boolean> 是否有今日抓到的娃娃，key为ManType

---初始化
function DailyDateBLL:OnInit()
    proxy = SelfProxyFactory.GetDailyDateProxy()

    EventMgr.AddListener("CommonDailyReset", self.CommonDailyReset, self)
    EventMgr.AddListener("UserRecordUpdate", self.UserRecordUpdate, self)
    EventMgr.AddListener("CustomRecordUpdate", self.CustomRecordUpdate, self)
    ---藏品有修改更新首次获得娃娃
    EventMgr.AddListener("CollectionUpdateReply", self.CollectionUpdateReply, self)
    --EventMgr.AddListener("EnterDailyDateReply_Error", self.EnterDailyDateReply_Error, self)

    EventMgr.AddListener("FinStageReply", self.CheckOpenCondition, self)
    EventMgr.AddListener("EVENT_LEVEL_UP", self.CheckOpenCondition, self)
    EventMgr.AddListener("RoleUpdate", self.CheckOpenCondition, self)
    EventMgr.AddListener("UnLockSystem", self.CheckOpenCondition, self)
    EventMgr.AddListener("GetUFOCatcherRewardReply", self.CheckOpenCondition, self)
    EventMgr.AddListener("GetBlockTowerRewardReply", self.CheckOpenCondition, self)
    EventMgr.AddListener("GetMiaoRewardReply", self.CheckOpenCondition, self)

    redPointIdDict = {}
    redPointIdDict[Define.GamePlayType.GamePlayTypeUfoCatcher] = X3_CFG_CONST.RED_DATE_UFOCATCHER
    redPointIdDict[Define.GamePlayType.GamePlayTypeBlockTower] = X3_CFG_CONST.RED_DATE_BLOCKTOWER
    redPointIdDict[Define.GamePlayType.GamePlayTypeMiao] = X3_CFG_CONST.RED_DATE_MIAOCARD

    registeredTimerId = {}
    dollDropGroupCheckedDict = {}
    dollDropGroupIdDict = {}
    lastSubIdMap = {}
    ufoCatcherNormalDoll = {}

    roleDollDict = {}
    local dollItemAll = LuaCfgMgr.GetAll("UFOCatcherDollItem")
    for dollId, cfgList in pairs(dollItemAll) do
        for manType, _ in pairs(cfgList) do
            if roleDollDict[manType] == nil then
                roleDollDict[manType] = {}
            end
            table.insert(roleDollDict[manType], #roleDollDict[manType] + 1, dollId)
        end
    end
    dollItemDict = {}
    local colorDollAll = LuaCfgMgr.GetAll("UFOCatcherDollColor")
    for _, cfg in pairs(colorDollAll) do
        if dollItemDict[cfg.OriginDollID] == nil then
            dollItemDict[cfg.OriginDollID] = { originId = cfg.OriginDollID, colorList = {}, collectedColorAll = { }, collectedToday = { } }
        end
        local colorList = dollItemDict[cfg.OriginDollID].colorList
        table.insert(colorList, #colorList + 1, cfg.ColorDollID)
    end

    checkedNewRecordMap = nil
    enterCallback = nil
    checkTimerId = 0
end

---
function DailyDateBLL:LogicEntry()
    self:InitTimestampEvent()
    local dollDropGroupIdList = BllMgr.GetPlayerServerPrefsBLL():GetIntList(GameConst.CustomDataIndex.DollFamily)
    for _, v in pairs(dollDropGroupIdList) do
        dollDropGroupCheckedDict[v] = true
    end
    table.clear(lastSubIdMap)
    local lastSubIdList = BllMgr.GetPlayerServerPrefsBLL():GetIntList(GameConst.CustomDataIndex.DailyDateLastSubId)
    for i = 1, #lastSubIdList, 2 do
        lastSubIdMap[lastSubIdList[i]] = lastSubIdList[i + 1]
    end
    self:RefreshRed()
end

---根据玩家的Item缓存数据
function DailyDateBLL:InitDollItemData()
    local roleCfgs = LuaCfgMgr.GetAll("RoleInfo")
    for manType, _ in pairs(roleCfgs) do
        for id, _ in pairs(dollItemDict) do
            self:RefreshDollData(id, manType)
        end
    end
end

--region UI
---打开难度界面
---@param dailyDateEntryId int
---@param roleId int
function DailyDateBLL:OpenDifficultyWnd(dailyDateEntryId, roleId)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", dailyDateEntryId)
    local sysID = dailyDateEntry.SystemID
    if SysUnLock.IsUnLock(sysID) == false then
        UICommonUtil.ShowMessage(SysUnLock.LockTips(sysID))
    elseif proxy:IsDateInOpenTime(dailyDateEntry.ID) == false then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_6046)
    else
        if dailyDateEntry.GameType == Define.GamePlayType.GamePlayTypeUfoCatcher then
            UIMgr.Open(UIConf.UFOCatcherEntranceWnd, dailyDateEntryId, roleId)
        elseif dailyDateEntry.GameType == Define.GamePlayType.GamePlayTypeMiao then
            UIMgr.Open(UIConf.CatCardEntranceWnd, dailyDateEntry, roleId)
        else
            UIMgr.Open(UIConf.DailyDateDifficultyWnd, dailyDateEntry, roleId)
        end
    end
end

---打开帮助界面
---@param dailyDateEntryId int
---@param difficultyId int
function DailyDateBLL:OpenHelpWnd(dailyDateEntryId, difficultyId)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", dailyDateEntryId)
    if dailyDateEntry.GameType == Define.GamePlayType.GamePlayTypeUfoCatcher
            or dailyDateEntry.GameType == Define.GamePlayType.GamePlayTypeMiao then
        UIMgr.Open(UIConf.DailyDateRule, dailyDateEntry.GameType, proxy:GetDifficulty(dailyDateEntryId, difficultyId))
    else
        UIMgr.Open(UIConf.DailyPlayMethodTips, dailyDateEntry)
    end
end
--endregion

---尝试进入日常约会
---@param dailyDateEntryId int
---@param difficultyId int
function DailyDateBLL:TryEnterDailyDate(dailyDateEntryId, difficultyId)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", dailyDateEntryId)
    local difficulty = proxy:GetDifficulty(dailyDateEntryId, difficultyId)
    if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(difficulty.OpenCondition) then
        local leftTimes = SelfProxyFactory.GetDailyDateProxy():GetLeftTimes(dailyDateEntryId, difficulty.ManType)
        if leftTimes > 0 or SelfProxyFactory.GetGamePlayProxy():IsGuide(dailyDateEntry.GameType, difficultyId) then
            self:EnterDailyDate(dailyDateEntryId, difficultyId)
        elseif self:CanBuyTimes(dailyDateEntryId, difficulty.ManType) then
            self:TryBuyTimes(dailyDateEntryId, difficulty.ManType)
        else
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_6019)
        end
    else
        UICommonUtil.ShowMessage(ConditionCheckUtil.GetConditionDescByGroupId(difficulty.OpenCondition))
    end
end

---进入日常约会
---@param dailyDateId int
---@param subId int
---@param callback fun
function DailyDateBLL:EnterDailyDate(dailyDateId, subId, callback)
    enterCallback = callback
    EventMgr.AddListenerOnce("EnterDailyDateReply", self.InternalEnterDailyDate, self)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", dailyDateId)
    local data = {}
    data.DailyDateId = dailyDateId
    data.SubId = subId
    data.Version = LogicEntityUtil.GetGameVersion(dailyDateEntry.GameType)
    GrpcMgr.SendRequest(RpcDefines.EnterDailyDateRequest, data, true)
end

---进入日常约会
---@param msg pbcmessage.EnterDailyDateReply
---@param requestData pbcmessage.EnterDailyDateRequest
function DailyDateBLL:InternalEnterDailyDate(msg, requestData)
    EventMgr.Dispatch("DailyDateCmd_EnterDailyDate", requestData.DailyDateId, requestData.SubId, self.enterCallback)
    enterCallback = nil
end

---校验不通过，返回错误码
---@param errorCode int
--function DailyDateBLL:EnterDailyDateReply_Error(errorCode)
--    if errorCode == X3_CFG_CONST.GAMEPLAYVERIFYFAILED or errorCode == X3_CFG_CONST.GAMEPLAYVERIFYILLEGALVERSION then
--        local btn_list = {
--            { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_text = UITextConst.UI_TEXT_5701, btn_call = function()
--                --重登游戏
--                GameStateMgr.Switch(GameState.Logout)
--            end },
--            { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_text = UITextConst.UI_TEXT_5702, btn_call = function()
--                --关闭弹窗
--            end },
--        }
--        UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_6306, btn_list, AutoCloseMode.None)
--    end
--end

---获取日常约会结束语
---@param endingWords string 配置表中的结束语
---@param score int 日常约会得分
---@return string
function DailyDateBLL:GetComment(endingWords, score)
    local endingWordsArray = string.split(endingWords, "|")
    local group = 0
    for i = 1, #endingWordsArray do
        local endingWordID = string.split(endingWordsArray[i], "=")
        if tonumber(endingWordID[1]) <= score and tonumber(endingWordID[2]) > score then
            group = tonumber(endingWordID[3])
            break
        end
    end
    local wordsArray = LuaCfgMgr.GetAll("DailyDateEndingWords")
    local randomPool = {}
    for _, word in pairs(wordsArray) do
        if word.Group == group then
            table.insert(randomPool, #randomPool + 1, word)
        end
    end
    local index = math.random(1, #randomPool)
    return UITextHelper.GetUIText(randomPool[index].Description)
end

---尝试购买次数
---@param id int 日常约会id
---@param roleId int 男主Id
function DailyDateBLL:TryBuyTimes(id, roleId)
    local leftTimes = proxy:GetLeftTimes(id, roleId)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", id)
    if leftTimes >= dailyDateEntry.MaxTimesLimit then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_6044)
    elseif self:CanBuyTimes(id, roleId) then
        UIMgr.Open(UIConf.BuyPowerWnd, Define.BuyPowerWndType.BuyDailyDateTimes, id, roleId)
    else
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_6045)
    end
end

---是否可以购买次数
---@param id int 日常约会id
---@param roleId int 男主Id
---@return boolean
function DailyDateBLL:CanBuyTimes(id, roleId)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", id)
    local itemEnough = false
    if dailyDateEntry.ConnectTicket then
        for i = 1, #dailyDateEntry.ConnectTicket do
            local costTicket = dailyDateEntry.ConnectTicket[i]
            if BllMgr.GetItemBLL():SingleItemHasEnoughCost(costTicket) then
                itemEnough = true
            end
        end
    end
    return proxy:GetLeftCanBuyTimes(id, roleId) > 0 or itemEnough
end

---确认购买次数
---@param id int 日常约会id
---@param roleId int 男主类型
---@param costTicket S3Int[] 使用券的数量
function DailyDateBLL:ConfirmBuyTimes(id, roleId, costTicket)
    local req = {}
    req.DailyDateId = id
    req.ManID = roleId
    req.CostTicket = { }
    if costTicket then
        for id, num in pairs(costTicket) do
            local itemCfg = LuaCfgMgr.Get("Item", id)
            table.insert(req.CostTicket, { Id = id, Type = itemCfg.Type, Num = num })
        end
    end
    GrpcMgr.SendRequest(RpcDefines.BuyEnterCountRequest, req, true)
end

---通过新手引导筛选列表
---@param filtedList cfg.DailyDateEntry[]
function DailyDateBLL:CheckGuideFilter(filtedList)
    local res = {}
    for _, v in pairs(filtedList) do
        local ok = true
        if v.GuideCheck then
            ok = ConditionCheckUtil.CheckConditionByIntList(v.GuideCheck)
        end
        if ok then
            table.insert(res, v)
        end
    end
    return res
end

---日常约会面板打开了
function DailyDateBLL:DailyDateWndOpened()
    dailyDateWndOpened = true
    self:RefreshDateTimesRed()
end

---获取日常约会是否开过了
---@return boolean
function DailyDateBLL:GetDailyDateWndOpened()
    return dailyDateWndOpened
end

---日常约会整点刷新
function DailyDateBLL:CommonDailyReset()
    dailyDateWndOpened = false
    self:RefreshRed()
end

---初始化刷新逻辑
function DailyDateBLL:InitTimestampEvent()
    for _, uniqueID in pairs(registeredTimerId) do
        TimerMgr.Discard(uniqueID)
    end
    table.clear(registeredTimerId)
    local dailyDateList = proxy:GetDailyDateModelDict()
    local addedRegisterEvent = PoolUtil.GetTable()
    local serverTimeOffset = GrpcMgr.GetServerTime()
    for _, model in pairs(dailyDateList) do
        if model.end_timestamp > 0 and model.endTime:CompareTo(serverTimeOffset) > 0 and table.indexof(addedRegisterEvent, model.endTime) == false then
            table.insert(addedRegisterEvent, model.endTime)
            table.insert(registeredTimerId, TimerMgr.AddTimer(model.end_timestamp - TimerMgr.GetCurTimeSeconds() + 1, self.TimeEventRefresh, self))
        end
        if model.start_timestamp > 0 and model.startTime:CompareTo(serverTimeOffset) > 0 and table.indexof(addedRegisterEvent, model.startTime) == false then
            table.insert(addedRegisterEvent, model.startTime)
            table.insert(registeredTimerId, TimerMgr.AddTimer(model.start_timestamp - TimerMgr.GetCurTimeSeconds() + 1, self.TimeEventRefresh, self))

        end
    end
    PoolUtil.ReleaseTable(addedRegisterEvent)
    addedRegisterEvent = nil
end

---日常约会到点刷新
function DailyDateBLL:TimeEventRefresh()
    ---开启时间变了的话一定要重新刷新
    proxy:InitDailyDateData()
    self:StartCheckTimer()
end

---需要重新检测开放
function DailyDateBLL:CheckOpenCondition()
    local hasNew = proxy:InitDailyDateData()
    if hasNew then
        self:StartCheckTimer()
    end
end

---
function DailyDateBLL:StartCheckTimer()
    --使用Timer代替每帧Update和Dirty标记位
    if checkTimerId == 0 then
        checkTimerId = TimerMgr.AddTimerByFrame(1, self.LateUpdateCheck, self, 1, TimerMgr.UpdateType.LATE_UPDATE)
    end
end

---
function DailyDateBLL:LateUpdateCheck()
    checkTimerId = 0
    self:LogicEntry()
    EventMgr.Dispatch("DailyDateRefresh")
end

--region Record
---监听UserRecord消息
---@param saveType int
---@param subId int
function DailyDateBLL:UserRecordUpdate(saveType, subId)
    if saveType == DataSaveRecordType.DataSaveRecordTypeChocolateLimit then
        EventMgr.Dispatch("HappyChocolateCntUpdate")
    end
end

---监听CustomRecord消息
---@param customType int
function DailyDateBLL:CustomRecordUpdate(customType, ...)
    if customType == DataSaveCustomType.DataSaveCustomTypeDailyDateEnterCount then
        EventMgr.Dispatch("DailyDateTimesUpdate")
    elseif customType == DataSaveCustomType.DataSaveCustomTypeDailyDateBuyCount then
        EventMgr.Dispatch("DailyDateTimesUpdate")
    end
end

---返回刷新规则
---@param customType int
---@param id int
---@return int, string
function DailyDateBLL:GetRefreshSchedule(customType, id, ...)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", id)
    if dailyDateEntry then
        return dailyDateEntry.TimesRefreshType, dailyDateEntry.TimesRefreshDetail
    else
        return 0, nil
    end
end

---返回刷新值
---@param curValue int
---@param customType int
---@return int
function DailyDateBLL:GetRefreshValue(curValue, customType, id, roleId, ...)
    local newValue = curValue
    if customType == DataSaveCustomType.DataSaveCustomTypeDailyDateEnterCount then
        local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", id)
        if dailyDateEntry then
            if curValue < dailyDateEntry.MaxTimesLimit then
                newValue = Mathf.Min(curValue + dailyDateEntry.Times, dailyDateEntry.MaxTimesLimit)
            end
        else
            newValue = 0
        end
    elseif customType == DataSaveCustomType.DataSaveCustomTypeDailyDateBuyCount then
        newValue = 0
    end
    return newValue
end
--endregion

---获取娃娃家族有效时间
---@param index int
---@return OpenTimeData
function DailyDateBLL:GetUFOCatcherNormalDollPoolTime(index)
    if ufoCatcherNormalDoll[index] == nil then
        local openTimeData = OpenTimeData.new()
        local cfg = LuaCfgMgr.Get("UFOCatcherNormalDollPool", index)
        openTimeData:Parse(cfg.TimeType, cfg.TimePara)
        ufoCatcherNormalDoll[index] = openTimeData
    end
    return ufoCatcherNormalDoll[index]
end

---刷新娃娃缓存数据，供Condition以及TextReplace使用
---@param dollId int 娃娃Id
---@param manType int 男主Id
function DailyDateBLL:RefreshDollData(dollId, manType)
    local dollColor = LuaCfgMgr.Get("UFOCatcherDollColor", dollId)
    local originId = dollId
    if dollColor then
        originId = dollColor.OriginDollID
    end
    local dollItemData = dollItemDict[originId]
    if dollItemData and dollItemData.colorList then
        local collectedColorAll = true
        local collectedToday = false
        ---是娃娃藏品
        local collectionItemData = SelfProxyFactory.GetCollectionRoomProxy():GetCollectItemInfo(manType, originId)
        collectedToday = collectionItemData and (TimeUtil.GetOpenDay(collectionItemData.update_time) <= 1) or false
        for _, v in pairs(dollItemData.colorList) do
            if BllMgr.GetItemBLL():GetItemNum(v, nil, manType) <= 0 then
                collectedColorAll = false
            end
        end
        dollItemData.collectedToday[manType] = collectedToday
        dollItemData.collectedColorAll[manType] = collectedColorAll
    end
end

---与该男主抓到的娃娃中，指定类型（=0，常规娃娃）中，已获得重复娃娃达到指定数量（=10）及以上的娃娃名字之一。
---@param manType int 男主Id
---@param dollType int 娃娃类型
---@param count int 数量
---@return string
function DailyDateBLL:GetRepeatedDollName(manType, dollType, count)
    local randomId = 0
    local randomName = nil
    local randomNamePool = PoolUtil.GetTable()
    local todayCatchedPool = PoolUtil.GetTable()
    local dollList = roleDollDict[manType]
    if dollList then
        for _, id in pairs(dollList) do
            local itemCfg = LuaCfgMgr.Get("Item", id)
            if itemCfg and itemCfg.IntExtra1 == dollType then
                if BllMgr.GetItemBLL():GetItemNum(id, nil, manType) >= count then
                    table.insert(randomNamePool, #randomNamePool + 1, id)
                    local collectionItemData = SelfProxyFactory.GetCollectionRoomProxy():GetCollectItemInfo(manType, id)
                    if collectionItemData and (TimeUtil.GetOpenDay(collectionItemData.update_time) <= 1) then
                        table.insert(todayCatchedPool, #todayCatchedPool + 1, id)
                    end
                end
            end
        end
    end

    if #todayCatchedPool > 0 then
        randomId = todayCatchedPool[math.random(1, #todayCatchedPool)]
    elseif #randomNamePool > 0 then
        randomId = randomNamePool[math.random(1, #randomNamePool)]
    end
    if randomId > 0 then
        randomName = UITextHelper.GetUIText(BllMgr.GetItemBLL():GetItemShowName(randomId))
    end
    PoolUtil.ReleaseTable(todayCatchedPool)
    PoolUtil.ReleaseTable(randomNamePool)
    return randomName
end

---文本参数{ColorDoll=0}：与该男主抓到的娃娃种类中，指定类型（=0，常规娃娃）中，已集齐全套的娃娃种类名字之一。
---@param dollType int 娃娃类型
---@param count int 数量
---@return string
function DailyDateBLL:GetColorDollName(manType, dollType)
    local randomId = 0
    local randomName = nil
    local randomNamePool = PoolUtil.GetTable()
    local todayCatchedPool = PoolUtil.GetTable()
    local dollList = roleDollDict[manType]
    if dollList then
        for _, id in pairs(dollList) do
            local itemCfg = LuaCfgMgr.Get("Item", id)
            if itemCfg and itemCfg.IntExtra1 == dollType then
                local dollItem = dollItemDict[id]
                if dollItem and dollItem.collectedColorAll[manType] then
                    table.insert(randomNamePool, #randomNamePool + 1, id)
                    if dollItem.collectedToday[manType] then
                        table.insert(todayCatchedPool, #todayCatchedPool + 1, id)
                    end
                end
            end
        end
    end

    if #todayCatchedPool > 0 then
        randomId = todayCatchedPool[math.random(1, #todayCatchedPool)]
    elseif #randomNamePool > 0 then
        randomId = randomNamePool[math.random(1, #randomNamePool)]
    end
    if randomId > 0 then
        randomName = UITextHelper.GetUIText(BllMgr.GetItemBLL():GetItemShowName(randomId))
    end
    PoolUtil.ReleaseTable(todayCatchedPool)
    PoolUtil.ReleaseTable(randomNamePool)
    return randomName
end

--region 红点数据相关---日常约会红点刷新逻辑
function DailyDateBLL:RefreshRed()
    self:ClearNewRed()
    self:RefreshNewRed()
    self:RefreshDateTimesRed()
    self:RefreshDollFamilyRed()
end

--每日登录日常约会红点提示
function DailyDateBLL:RefreshDateTimesRed()
    local is_need_check_times = dailyDateWndOpened == false and BllMgr.GetPlayerBLL():IsFirstLoginEveryday()
    local count = (is_need_check_times and proxy:GetLeftTimesAll() > 0) and 1 or 0
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_DATE_TIMES, count)
end

---刷新日常约会New红点
function DailyDateBLL:RefreshNewRed()
    local dailyDateList = proxy:GetDailyDateModelDict()
    if checkedNewRecordMap == nil then
        checkedNewRecordMap = {}
        for _, v in pairs(dailyDateList) do
            checkedNewRecordMap[v.id] = table.clone(v.difficultyMap) --不能使用相同的Table，会导致提前被修改
        end
    end
    for entryId, model in pairs(dailyDateList) do
        for difficultyId, _ in pairs(model.difficultyMap) do
            local isNew = false
            isNew = self:CheckDailyDateItemRenderCornerMark(entryId, difficultyId)
            if isNew then
                if checkedNewRecordMap ~= nil then
                    if table.containskey(checkedNewRecordMap, entryId) == false then
                        checkedNewRecordMap[entryId] = {}
                    end
                    if table.containskey(checkedNewRecordMap[entryId], difficultyId) == false then
                        local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", entryId)
                        local difficulty = proxy:GetDifficulty(entryId, difficultyId)
                        if self:NeedShowUnlock(dailyDateEntry, difficulty) and proxy:HasSameGame(entryId, difficultyId, checkedNewRecordMap[entryId]) == false then
                            ErrandMgr.Add(X3_CFG_CONST.POPUP_SPECIALTYPE_DIFFICULTYUNLOCK, { entryId = entryId, difficultyId = difficultyId })
                        end
                        checkedNewRecordMap[entryId][difficultyId] = true
                    end
                end
            end
            self:RefreshRedByEntryAndDifficulty(entryId, difficultyId, isNew and 1 or 0)
        end
    end
end

---是否需要显示解锁弹窗
---@param dailyDateEntry cfg.DailyDateEntry
---@param difficulty cfg.UFOCatcherDifficulty|cfg.MiaoCardDifficulty|cfg.BlockTowerDifficulty
------@return boolean
function DailyDateBLL:NeedShowUnlock(dailyDateEntry, difficulty)
    local needShow = true
    for _, v in pairs(dailyDateEntry.DifficultyUnlockNoPopup) do
        if BllMgr.GetGameplayBLL():IsSameDifficultyType(v, difficulty) then
            needShow = false
        end
    end
    return needShow
end

---清空红点数据
function DailyDateBLL:ClearNewRed()
    local dailyDateList = proxy:GetDailyDateModelDict()
    for entryId, model in pairs(dailyDateList) do
        for difficultyId, _ in pairs(model.difficultyMap) do
            self:RefreshRedByEntryAndDifficulty(entryId, difficultyId, 0)
        end
    end
end

---单个约会红点检查
---@param dailyDateEntryId int 对应DailyDateEntryId
---@param difficultyId int 对应DifficultyId
---@return boolean
function DailyDateBLL:CheckDailyDateItemRenderCornerMark(dailyDateEntryId, difficultyId)
    local model = proxy:GetDailyDateModel(dailyDateEntryId)
    if model.difficultyMap ~= nil then
        for i, _ in pairs(model.difficultyMap) do
            local data = nil
            data = proxy:GetDifficulty(dailyDateEntryId, difficultyId)
            if self:HasChecked(dailyDateEntryId, difficultyId) == false and proxy:IsSameGame(dailyDateEntryId, difficultyId, i) and
                    ConditionCheckUtil.CheckConditionByCommonConditionGroupId(data.OpenCondition) then
                return true
            end
        end
    end
    return false
end

---是否看过该日常约会了
---@param entryId int 对应DailyDateEntryId
---@param difficultyId int 对应DifficultyId
---@return boolean
function DailyDateBLL:HasChecked(entryId, difficultyId)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", entryId)
    local redPointValue = RedPointMgr.GetValue(redPointIdDict[dailyDateEntry.GameType], self:GetCalcuateRedId(entryId, difficultyId))
    return redPointValue == 1
end

---计算唯一id
---@param dailyDateEntryId int 对应DailyDateEntryId
---@param difficultyId int 对应DifficultyId
function DailyDateBLL:GetCalcuateRedId(dailyDateEntryId, difficultyId)
    return difficultyId * 10 + dailyDateEntryId
end

---根据id刷新新开约会红点
---@param entryId int 日常约会玩法Id
---@param difficultyId int 难度Id
---@param count int 红点数量
function DailyDateBLL:RefreshRedByEntryAndDifficulty(entryId, difficultyId, count)
    local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", entryId)
    RedPointMgr.UpdateCount(redPointIdDict[dailyDateEntry.GameType], count, self:GetCalcuateRedId(entryId, difficultyId))
end

---根据约会类型清除日常约会new信息
---@param entryId int 日常约会玩法Id
function DailyDateBLL:ClearNewDailyDate(entryId)
    local model = proxy:GetDailyDateModel(entryId)
    if model.difficultyMap then
        if proxy:IsDateInOpenTime(entryId) == true then
            local datas = proxy:GetDifficulties(entryId, 1)
            for difficultyId, _ in pairs(model.difficultyMap) do
                if self:HasChecked(entryId, difficultyId) == false then
                    for _, data in pairs(datas) do
                        if proxy:IsSameGame(entryId, data.ID, difficultyId) and
                                ConditionCheckUtil.CheckConditionByCommonConditionGroupId(data.ShowCondition) then
                            local dailyDateEntry = LuaCfgMgr.Get("DailyDateEntry", entryId)
                            RedPointMgr.Save(1, redPointIdDict[dailyDateEntry.GameType], self:GetCalcuateRedId(entryId, difficultyId))
                            break
                        end
                    end
                end
            end
        end
    end
    self:RefreshNewRed()
end

---刷新娃娃家族红点
function DailyDateBLL:RefreshDollFamilyRed()
    table.clear(dollDropGroupIdDict)
    local unlockedRoleList = BllMgr.GetRoleBLL():GetUnlockedRole()
    local cfgAll = LuaCfgMgr.GetAll("UFOCatcherTotalDollGroup")
    local condition = {}
    for roleId, _ in pairs(unlockedRoleList) do
        dollDropGroupIdDict[roleId] = {}
        for _, totalDollGroup in pairs(cfgAll) do
            for _, groupId in pairs(totalDollGroup.CollectGroupID) do
                table.clear(condition)
                condition.Group = groupId
                condition.ManType = roleId
                local difficulty = LuaCfgMgr.GetDataByCondition("UFOCatcherDifficulty", condition)
                if difficulty then
                    local totalPool = LuaCfgMgr.Get("UFOCatcherTotalPool", difficulty.DollPool)
                    if totalPool then
                        if totalPool.ActivityPoolID then
                            for _, activityPoolId in pairs(totalPool.ActivityPoolID) do
                                local cfg = LuaCfgMgr.Get("UFOCatcherActivityDollPool", activityPoolId)
                                if cfg and cfg.ActivityDollDropPR > 0 then
                                    local isOpen = true
                                    if string.isnilorempty(cfg.StartTime) == false then
                                        local startTime = TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(cfg.StartTime))
                                        isOpen = TimerMgr.GetCurTimeSeconds() >= startTime
                                    end
                                    if isOpen and string.isnilorempty(cfg.EndTime) == false then
                                        local endTime = TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(cfg.EndTime))
                                        isOpen = TimerMgr.GetCurTimeSeconds() <= endTime
                                    end
                                    if isOpen and not dollDropGroupIdDict[roleId][cfg.DollDropGroupID] then
                                        dollDropGroupIdDict[roleId][cfg.DollDropGroupID] = true
                                    end
                                end
                            end
                        end
                        if totalPool.ManDollDropPR > 0 and not dollDropGroupIdDict[roleId][totalPool.ManDollGroupID] then
                            dollDropGroupIdDict[roleId][totalPool.ManDollGroupID] = true
                        end
                        table.clear(condition)
                        condition.NormalPoolID = totalPool.NormalPoolGroupID
                        local cfgList = LuaCfgMgr.GetListByCondition("UFOCatcherNormalDollPool", condition)
                        local dollDropGroupID = 0
                        for _, cfg in pairs(cfgList) do
                            local highestPriority = -1
                            local openTimeData = self:GetUFOCatcherNormalDollPoolTime(cfg.Index)
                            if cfg.Priority > highestPriority and openTimeData:IsInOpenTime() then
                                dollDropGroupID = cfg.DollDropGroupID
                                highestPriority = cfg.Priority
                            end
                        end
                        if dollDropGroupID > 0 and not dollDropGroupIdDict[roleId][dollDropGroupID] then
                            dollDropGroupIdDict[roleId][dollDropGroupID] = true
                        end
                    end
                end
            end
        end
    end
    local changed = false
    local keys = table.keys(dollDropGroupCheckedDict)
    for _, key in ipairs(keys) do
        local isExist = false
        for _, dropGroupIdDict in pairs(dollDropGroupIdDict) do
            if dropGroupIdDict[key] then
                isExist = true
                break
            end
        end
        if isExist == false then
            changed = true
        end
        dollDropGroupCheckedDict[key] = isExist and true or nil
    end
    self:UpdateDollFamilyRed()
    if changed then
        self:SaveDollDropGroupCheckedDict()
    end
end

---添加查看过的娃娃列表
---@param roleId int
---@param dollPoolList int[]
function DailyDateBLL:AddCheckedDollFamily(roleId, dollPoolList)
    local changed = false
    if dollPoolList then
        for _, v in pairs(dollPoolList) do
            if not dollDropGroupCheckedDict[v] then
                dollDropGroupCheckedDict[v] = true
                changed = true
            end
        end
    end
    if changed then
        self:UpdateDollFamilyRed()
        self:SaveDollDropGroupCheckedDict()
    end
end

---保存查看过的娃娃池列表
function DailyDateBLL:SaveDollDropGroupCheckedDict()
    local tempTable = table.keys(dollDropGroupCheckedDict)
    BllMgr.GetPlayerServerPrefsBLL():SetIntList(GameConst.CustomDataIndex.DollFamily, tempTable)
end

---
function DailyDateBLL:UpdateDollFamilyRed()
    for roleId, dollDropGroupDict in pairs(dollDropGroupIdDict) do
        local isExist = false
        for k, _ in pairs(dollDropGroupDict) do
            if not dollDropGroupCheckedDict[k] then
                isExist = true
            end
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_DATE_UFOUP, isExist and 1 or 0, roleId)
    end
end

---获得上次看的日常约会
---@param dailyDateEntryId int
---@return int
function DailyDateBLL:GetLastSubId(dailyDateEntryId)
    local lastSubId = lastSubIdMap[dailyDateEntryId]
    return lastSubId ~= nil and lastSubId or 0
end

---设置上次看的日常约会
---@param dailyDateEntryId int
---@param index int
function DailyDateBLL:SetLastSubId(dailyDateEntryId, index)
    lastSubIdMap[dailyDateEntryId] = index
    local lastSubIdList = BllMgr.GetPlayerServerPrefsBLL():GetIntList(GameConst.CustomDataIndex.DailyDateLastSubId)
    table.clear(lastSubIdList)
    for k, v in pairs(lastSubIdMap) do
        table.insert(lastSubIdList, k)
        table.insert(lastSubIdList, v)
    end
    BllMgr.GetPlayerServerPrefsBLL():SetIntList(GameConst.CustomDataIndex.DailyDateLastSubId, lastSubIdList)
end

---藏品更新
---@param data pbcmessage.CollectionUpdateReply
function DailyDateBLL:CollectionUpdateReply(data)
    local collectionList = BllMgr.GetPlayerServerPrefsBLL():GetIntList(GameConst.CustomDataIndex.DailyDateFirstGetDoll)
    if data.CollectionList then
        for _, v in pairs(data.CollectionList) do
            local itemCfg = LuaCfgMgr.Get("Item", v.ID)
            if itemCfg and itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_COLLECTION and itemCfg.SubType == 2 then
                ---是娃娃藏品
                local collectionItemData = SelfProxyFactory.GetCollectionRoomProxy():GetCollectItemInfo(data.Role, v.ID)
                if table.indexof(collectionList, v.ID) == false and
                        collectionItemData:IsNewGet() then
                    table.insert(collectionList, v.ID)
                end
                self:RefreshDollData(v.ID, data.Role)
            end
        end
    end
    BllMgr.GetPlayerServerPrefsBLL():SetIntList(GameConst.CustomDataIndex.DailyDateFirstGetDoll, collectionList)
end

---检查是否需要弹藏品Tips
---@param roleId int 男主Id
---@param closeCallback fun 最后一个弹窗的关闭回调
---@param autoClose bool 自动关闭
function DailyDateBLL:CheckDollCollectionTips(roleId, closeCallback, autoClose)
    local firstGetDollList = BllMgr.GetPlayerServerPrefsBLL():GetIntList(GameConst.CustomDataIndex.DailyDateFirstGetDoll)
    local newCollectionCount = #firstGetDollList
    local showed = false
    autoClose = autoClose == nil and true or autoClose
    if newCollectionCount > 0 then
        showed = true
        ErrandMgr.Add(X3_CFG_CONST.POPUP_SPECIALTYPE_DOLLSHOW,
                { dollList = firstGetDollList,
                  roleId = roleId,
                  closeCallback = closeCallback,
                  autoClose = autoClose })
    else
        if closeCallback then
            pcall(closeCallback)
        end
    end
    if showed then
        BllMgr.GetPlayerServerPrefsBLL():SetIntList(GameConst.CustomDataIndex.DailyDateFirstGetDoll, { })
    end
end
--endregion

--region CheckCondition
---@param id X3_CFG_CONST 条件检查Type
---@param datas int[] 条件检查的数据
---@return boolean
function DailyDateBLL:CheckCondition(id, datas, ...)
    local result = false
    local times
    if id == X3_CFG_CONST.CONDITION_BLOCKTOWER_TIMES_TURN then
        times = SelfProxyFactory.GetGamePlayProxy():GetTurnCount()
        result = ConditionCheckUtil.IsInRange(times, datas[1], datas[2])
    elseif id == X3_CFG_CONST.CONDITION_DAILYDATE_TIME then
        local manType = datas[1]
        local dailyDateId = datas[2]
        if dailyDateId == -1 then
            result = ConditionCheckUtil.IsInRange(proxy:GetLeftTimesAll(manType), datas[3], datas[4])
        else
            result = ConditionCheckUtil.IsInRange(proxy:GetLeftTimes(dailyDateId, manType), datas[3], datas[4])
        end
    elseif id == X3_CFG_CONST.CONDITION_DOLL_NUM_TOTAL then
        local manType = datas[1]
        local dollType = datas[2]
        local dollId = datas[3]
        local needCheckList = {}
        if dollId == -1 or dollId == 0 then
            local roleDollList = roleDollDict[manType]
            if roleDollList then
                for _, itemId in pairs(roleDollList) do
                    local itemCfg = LuaCfgMgr.Get("Item", itemId)
                    if itemCfg and (itemCfg.IntExtra1 == dollType or dollType == -1) then
                        table.insert(needCheckList, #needCheckList + 1, itemId)
                    end
                end
            end
        else
            table.insert(needCheckList, #needCheckList + 1, dollId)
        end
        for _, itemId in pairs(needCheckList) do
            local num = BllMgr.GetItemBLL():GetItemNum(itemId, nil, manType)
            if ConditionCheckUtil.IsInRange(num, datas[4], datas[5]) then
                result = true
            end
            if result then
                break
            end
        end
    elseif id == X3_CFG_CONST.CONDITION_DOLL_GROUP_TOTAL then
        local manType = datas[1]
        local dollGroupId = datas[2]
        local customGroupCfg = LuaCfgMgr.Get("UFOCatcherDollCustomGroup", dollGroupId)
        if customGroupCfg then
            result = true
            for _, dollId in pairs(customGroupCfg.DollID) do
                if BllMgr.GetItemBLL():GetItemNum(dollId, nil, manType) <= 0 then
                    result = false
                    break
                end
            end
        end
    elseif id == X3_CFG_CONST.CONDITION_DOLL_COLOR_TOTAL then
        local manType = datas[1]
        local dollType = datas[2]
        local dollId = datas[3]
        local needCheckList = {}
        if dollId == -1 or dollId == 0 then
            local roleDollList = roleDollDict[manType]
            if roleDollList then
                for _, itemId in pairs(roleDollList) do
                    local itemCfg = LuaCfgMgr.Get("Item", itemId)
                    if itemCfg and (itemCfg.IntExtra1 == dollType or dollType == -1) then
                        table.insert(needCheckList, #needCheckList + 1, itemId)
                    end
                end
            end
        else
            table.insert(needCheckList, #needCheckList + 1, dollId)
        end
        for _, itemId in pairs(needCheckList) do
            local dollItemData = dollItemDict[itemId]
            if dollItemData and dollItemData.collectedColorAll[manType] then
                result = true
                break
            end
        end
    elseif id == X3_CFG_CONST.CONDITION_UFO_LATELY_GAME then
        local manType = datas[1]
        local checkEnterType = datas[2]
        local checkGameDifficultyType = datas[3]

        local subId = 0
        local num = 0
        --[[ if checkEnterType == -1 then
             local userRecord = SelfProxyFactory.GetUserRecordProxy():GetUserRecord(X3_CFG_CONST.SAVEDATA_TYPE_UFO_LASTGAME_INFO, manType)
             if userRecord then
                 local subIdList = userRecord:GetSubKeys()
                 for _, v in pairs(subIdList) do
                     table.insert(needCheckEnterTypeList, #needCheckEnterTypeList + 1, v)
                 end
             end
         else
             table.insert(needCheckEnterTypeList, #needCheckEnterTypeList + 1, checkEnterType)
         end]]
        local userRecord = SelfProxyFactory.GetUserRecordProxy():GetUserRecord(X3_CFG_CONST.SAVEDATA_TYPE_UFO_LASTGAME_INFO, manType)
        if userRecord then
            subId = userRecord:GetArg(1)
            num = userRecord:GetArg(2)
        end
        if subId and subId > 0 then
            local difficultyTypeCfg = BllMgr.GetGameplayBLL():GetDifficultyType(Define.GamePlayType.GamePlayTypeUfoCatcher, LuaCfgMgr.Get("UFOCatcherDifficulty", subId))
            if (checkGameDifficultyType == -1 or (difficultyTypeCfg and difficultyTypeCfg.ID == checkGameDifficultyType)) and
                    ConditionCheckUtil.IsInRange(num, datas[4], datas[5]) then
                result = true
            end
        end
        --PoolUtil.ReleaseTable(needCheckEnterTypeList)
    elseif X3_CFG_CONST.CONDITION_DOLL_SERIES_NUM then
        local manType = datas[1]
        local dollId = datas[2]
        local count = 0
        local dollItemData = dollItemDict[dollId]
        if dollItemData and dollItemData.colorList then
            count = BllMgr.GetItemBLL():GetItemNum(dollId, nil, manType)
            for _, v in pairs(dollItemData.colorList) do
                count = count + BllMgr.GetItemBLL():GetItemNum(v, nil, manType)
            end
        end
        result = ConditionCheckUtil.IsInRange(count, datas[3], datas[4])
    end
    return result
end
--endregion

---
function DailyDateBLL:OnClear()
    self.super.OnClear(self)
    checkedNewRecordMap = nil
    enterCallback = nil
    redPointIdDict = nil
    checkTimerId = 0
    dailyDateWndOpened = false
    registeredTimerId = nil
    dollDropGroupCheckedDict = nil
    dollDropGroupIdDict = nil
    enterCallback = nil
end

return DailyDateBLL
