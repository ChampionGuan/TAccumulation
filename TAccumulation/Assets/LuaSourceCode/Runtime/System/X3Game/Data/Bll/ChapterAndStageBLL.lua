---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-15 14:32:41
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class ChapterAndStageBLL
local ChapterAndStageBLL = class("ChapterAndStageBLL", BaseBll)

local enumStageState = {
    origin = 0, -- 初始
    notPass = 1, --未通过
    passed = 2,  --通过
}

function ChapterAndStageBLL:OnInit()
    EventMgr.AddListener("CustomRecordUpdate", self.CustomRecordUpdate, self)
    self.ChapterList = {}
    self.StageList = {}
    self.StageArray = {}
    self.CurStageId = 0
    self.LastStageId = 0
    self.RoleID = 0
    self.playerCurChapterId = 0
    self.playerSelectStageIdTab = {}
    self.mSweepTargetItem = nil
    self.PreLoadBatchIdDic = {}  --k stageId   v linkId
    ---已通关的主线最新关卡id
    self.MainLineFarthestStageID = 0
    ---@type pbcmessage.Formation 当前的编队信息
    self.tryFormationData = nil
    self.isProStage = false
    self.isLoading = false
    self.isAutoStage = false
    self.isInStage = false   ---是否在关卡中
    self.inStageId = -1      ---当前所在关卡的ID
    self.tryEnterStageId = -1 ---尝试进入的stageID，Loading的Condition用
    self.isForceCombo = false ---是否无视通关进行连播
    self.PreLoadBatchIdDic = {}
    ---主线章节bgm tag索引
    self.soundTagChapterId = nil
    ---@type pbcmessage.Formation
    self.tryEnterFormationData = nil ---尝试进入的编队数据，Loading的Condition用
end

function ChapterAndStageBLL:OnClear()
    EventMgr.RemoveListenerByTarget(self)
end

---@param serverData pbcmessage.Stage
local function CreateStageInfo(serverData)
    local retTab = {}
    retTab.StageID = serverData.StageID
    retTab.State = serverData.State
    retTab.Num = SelfProxyFactory.GetCustomRecordProxy():GetCustomRecordValue(DataSaveCustomType.DataSaveCustomTypeStageNum, serverData.StageID)
    retTab.Star = serverData.Star
    retTab.PassTime = serverData.PassTime
    retTab.CreateTime = serverData.CreateTime
    retTab.Reward = serverData.Reward
    retTab.AchvInfo = serverData.AchvInfo
    retTab.AchvReward = serverData.AchvReward
    retTab.Drama = serverData.Drama
    retTab.ShowStar = serverData.ShowStar
    retTab.DailyBuyTimes = SelfProxyFactory.GetCustomRecordProxy():GetCustomRecordValue(DataSaveCustomType.DataSaveCustomTypeStageBuyTimes, serverData.StageID)
    return retTab
end

function ChapterAndStageBLL:Init(data)
    if data == nil then
        return
    end
    --Debug.LogErrorTable(data)
    self.ChapterList = data.ChapterMap
    self:InitStageMap(data.StageMap)
    self.CurStageId = data.CurStageID
    self.LastStageId = data.LastStageID
    self.RoleID = data.RoleID

    self:RefreshChapterRed(self.ChapterList)

    self.MainLineFarthestStageID = data.MainLineFarthestStageID
    self.TypePassTime = {}
    if data.BattleTime then
        self.TypePassTime = data.BattleTime  ---各种类型关卡最小时常
    end
end

function ChapterAndStageBLL:InitStageMap(stageMap)
    for k, v in pairs(stageMap) do
        local temp = CreateStageInfo(v)
        self.StageList[v.StageID] = temp
        table.insert(self.StageArray, temp)
    end
    table.sort(self.StageArray, function(x, y)
        return x.StageID < y.StageID
    end)
end

function ChapterAndStageBLL:UpdataChapterAward(chapterId, MainLineRwd)
    if self.ChapterList[chapterId] ~= nil then
        self.ChapterList[chapterId].MainLineRwd = MainLineRwd
    else
        self:AddChapter({ { ChapterID = chapterId, MainLineRwd = MainLineRwd } }, true)
    end
end

function ChapterAndStageBLL:AddChapter(chapterList, notCheckRedPoint)
    if notCheckRedPoint == nil then
        notCheckRedPoint = false
    end
    if self.ChapterList == nil then
        self.ChapterList = {}
    end
    if chapterList == nil then
        return
    end
    for i = 1, #chapterList do
        self.ChapterList[chapterList[i].ChapterID] = chapterList[i]
    end
    if not notCheckRedPoint then
        self:RefreshChapterRed(chapterList)
    end
    EventMgr.Dispatch("OnChapterChangeBack", chapterList)
end

function ChapterAndStageBLL:RemoveChapter(chapterList)
    if self.ChapterList == nil then
        return
    end
    if chapterList == nil then
        return
    end
    for i = 1, #chapterList do
        self.ChapterList[chapterList[i].ChapterID] = nil
    end
    self:RefreshChapterRed(chapterList, true)
    EventMgr.Dispatch("OnChapterChangeBack", chapterList)
end

function ChapterAndStageBLL:GetChapter(chapterId)
    if not self:HasChapter(chapterId) then
        return nil
    end
    return self.ChapterList[chapterId]
end

function ChapterAndStageBLL:HasChapter(chapterId)
    return table.containskey(self.ChapterList, chapterId)
end
--根据难度获取所有的章节信息
function ChapterAndStageBLL:GetChapterByType(difficultyLevel)
    local allChapterCfg = LuaCfgMgr.GetAll("ChapterInfo")
    local mainLineLimitCfg = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MAINLINEOPENLIMIT)
    local chapterLimitId = 0
    if mainLineLimitCfg ~= nil then
        chapterLimitId = tonumber(mainLineLimitCfg)
    end
    local retTab = {}
    for k, v in pairs(allChapterCfg) do
        if v.Difficulty == difficultyLevel then
            if chapterLimitId ~= 0 then
                if v.Chapter <= chapterLimitId then
                    table.insert(retTab, v)
                end
            else
                table.insert(retTab, v)
            end
        end
    end
    table.sort(retTab, function(a, b)
        return a.Chapter < b.Chapter
    end)
    return retTab
end

---获取指定难度下默认选中的章节ID
function ChapterAndStageBLL:GetDefaultChapterID(difficultyLevel, isJudgePlayerSet)
    if isJudgePlayerSet == nil then
        isJudgePlayerSet = true
    end
    local allChapterInfoCfg = self:GetChapterByType(difficultyLevel)
    local chapterID = 0
    if isJudgePlayerSet then
        if self.playerCurChapterId == 0 then
            chapterID = self:GetCurChapterId(allChapterInfoCfg)
        else
            chapterID = self.playerCurChapterId
        end
    else
        chapterID = self:GetCurChapterId(allChapterInfoCfg)
    end

    return chapterID
end

function ChapterAndStageBLL:ChangeDifficulty(difficultyLevel)
    local allChapterInfoCfg = self:GetChapterByType(difficultyLevel)
    local chapterID = 0
    chapterID = self:GetCurChapterId(allChapterInfoCfg)
    return chapterID
end

function ChapterAndStageBLL:GetCurLevel()
    if self.playerCurChapterId == 0 then
        return Define.Enum_DifficultyLevel.Normal
    else
        local curChapterCfg = LuaCfgMgr.Get("ChapterInfo", self.playerCurChapterId)
        if curChapterCfg ~= nil then
            return curChapterCfg.Difficulty
        end
    end
end

function ChapterAndStageBLL:SetPlayerCurChapterId(chapterId)
    self.playerCurChapterId = chapterId
end
function ChapterAndStageBLL:SetPlayerCurSelectId(chapterLevel, stageId)
    self.playerSelectStageIdTab[chapterLevel] = stageId
end
function ChapterAndStageBLL:GetPlayerCurChapter()
    return self.playerCurChapterId
end
function ChapterAndStageBLL:GetPlayerCurSelectId(chapterLevel)
    if table.containskey(self.playerSelectStageIdTab, chapterLevel) then
        return self.playerSelectStageIdTab[chapterLevel]
    end
    return 0
end

function ChapterAndStageBLL:ClearPlayerCurSelectId()
    self.playerSelectStageIdTab = {}
end

function ChapterAndStageBLL:HasPlayerCurSelectId()
    if next(self.playerSelectStageIdTab) then
        return true
    end

    return false
end

function ChapterAndStageBLL:ShowChapterMainWnd(stageCfg, sweepTargetItem)
    if stageCfg ~= nil and stageCfg.ID ~= 0 then
        if self:StageCanDo(stageCfg, false) then
            self.playerCurChapterId = 0
            local chapterInfoCfg = LuaCfgMgr.Get("ChapterInfo", stageCfg.ChapterInfoID)
            self.playerSelectStageIdTab[chapterInfoCfg.Difficulty] = 0
            if sweepTargetItem ~= nil then
                if sweepTargetItem.Num == 0 then
                    --扫荡最少个数为1
                    sweepTargetItem.Num = 1
                end
                self.mSweepTargetItem = sweepTargetItem
            end
            UIMgr.OpenWithAnim(UIConf.MainLineChapterWnd, false, 1, stageCfg, sweepTargetItem)
        else
            --print("跳转关卡还未开启")
        end
    else
        --print("跳转关卡未找到 配置问题")
    end
end
function ChapterAndStageBLL:ShowChapterWndByLv(level)
    if level == 2 then
        if not SysUnLock.IsUnLock(20001) then
            return
        end
    end
    UIMgr.Open(UIConf.MainLineChapterWnd, 2, level)
end

function ChapterAndStageBLL:ClearSweepTargetItem()
    self.mSweepTargetItem = nil
end
function ChapterAndStageBLL:GetSweepTargetItem()
    return self.mSweepTargetItem
end

function ChapterAndStageBLL:SetSweepTargetItem(sweepTargetItem)
    self.mSweepTargetItem = sweepTargetItem
end

---获取最新章节
function ChapterAndStageBLL:GetCurChapterId(allChapterInfo)
    local chapterID = 0
    for i = 1, #allChapterInfo do
        if not self:ChapterIsLock(allChapterInfo[i].ID, false) then
            chapterID = allChapterInfo[i].ID
        end
    end
    if chapterID == 0 then
        chapterID = allChapterInfo[1].ID
    end
    return chapterID
end
function ChapterAndStageBLL:IsPlayDramaAfter(stageId)
    if self:HasStage(stageId) then
        local stageData = self:GetStage(stageId)
        local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
        if stageData.Drama == stageCfg.DramaAfter then
            return true
        end
    end
    return false
end

---获取章节的星星奖励
function ChapterAndStageBLL:GetChapterStarRewardInfo(chapterId)
    local chapterInfoCfg = LuaCfgMgr.Get("ChapterInfo", chapterId)

    local reward = {}
    if chapterInfoCfg == nil then
        return reward
    end
    if chapterInfoCfg.NeedStar1 ~= 0 then
        local chapterRewardData = {}
        chapterRewardData["ID"] = 0
        chapterRewardData["NeedStarNum"] = chapterInfoCfg.NeedStar1
        chapterRewardData["Rewards"] = chapterInfoCfg.StarReward1
        table.insert(reward, chapterRewardData)
    end
    if chapterInfoCfg.NeedStar2 ~= 0 then
        local chapterRewardData = {}
        chapterRewardData["ID"] = 1
        chapterRewardData["NeedStarNum"] = chapterInfoCfg.NeedStar2
        chapterRewardData["Rewards"] = chapterInfoCfg.StarReward2
        table.insert(reward, chapterRewardData)
    end
    if chapterInfoCfg.NeedStar3 ~= 0 then
        local chapterRewardData = {}
        chapterRewardData["ID"] = 2
        chapterRewardData["NeedStarNum"] = chapterInfoCfg.NeedStar3
        chapterRewardData["Rewards"] = chapterInfoCfg.StarReward3
        table.insert(reward, chapterRewardData)
    end
    return reward
end

function ChapterAndStageBLL:GetRoleId()
    return self.RoleID
end
function ChapterAndStageBLL:GetCurStageId()
    return self.CurStageId
end

function ChapterAndStageBLL:GetLastStageId()
    return self.LastStageId
end

function ChapterAndStageBLL:GetIsProStage()
    return self.isProStage
end

---指定章节是否未解锁
function ChapterAndStageBLL:ChapterIsLock(chapterId, isShowTips)
    --[[
    if self:HasChapter(chapterId) then
        return false
    end
    --]]
    ---未解锁
    local allChapterStageCfg = self:GetAllStageInfoByChapterId(chapterId)
    ---此章节第一关解锁状态检测，只判断关卡进度
    local firstStageCfg = allChapterStageCfg[1]
    if not self:StageCanDo(firstStageCfg, false) then
        if isShowTips then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9108)
        end
        return true
    end
    if allChapterStageCfg ~= nil and #allChapterStageCfg >= 1 then
        local chapterInfoCfg = LuaCfgMgr.Get("ChapterInfo", chapterId)
        if not ConditionCheckUtil.CheckConditionByIntList(chapterInfoCfg.NeedLevel) then
            ---等级开发条件检测
            if isShowTips then
                UICommonUtil.ShowMessage(UITextHelper.GetUIText(UITextConst.UI_TEXT_9107, chapterInfoCfg.NeedLevel[2]))
            end
            return true
        end
        if chapterInfoCfg.ExOpenCondition ~= 0 then
            ---额外开放条件检测
            if not ConditionCheckUtil.CheckConditionByCommonConditionGroupId(chapterInfoCfg.ExOpenCondition) then
                local conditionDes = ConditionCheckUtil.GetConditionDescByGroupId(chapterInfoCfg.ExOpenCondition)
                if isShowTips then
                    UICommonUtil.ShowMessage(conditionDes)
                end
                return true
            end
        end
    else
        if isShowTips then
            UICommonUtil.ShowMessage(UITextHelper.GetUIText(UITextConst.UI_TEXT_9048))
        end
    end
    return false
end

---判断指定关卡是否可进入
function ChapterAndStageBLL:StageCanDo(stageCfg, isShowTips)
    if isShowTips == nil then
        isShowTips = false
    end
    --[[
    if self:HasStage(stageCfg.ID) then
        return true
    end
    --]]
    local preStageIsOpen = false
    local preStageIdTab = GameHelper.ToTable(stageCfg.PreStageID)
    for i = 1, #preStageIdTab do
        preStageIsOpen = self:StageIsUnLockById(preStageIdTab[i])
        if not preStageIsOpen and preStageIdTab[i] ~= 0 then
            ---指定关卡不可进入，根据前一个关卡进行提示
            local stageInfo = LuaCfgMgr.Get("CommonStageEntry", preStageIdTab[i])
            if isShowTips then
                if stageInfo.NumTab == 0 then
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_21224)
                else
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9042, UITextHelper.GetUIText(stageInfo.NumTab), UITextHelper.GetUIText(stageInfo.Name))
                end
            end
            return false, stageInfo
        end
    end
    return true
end
local StageLockType = {
    ExOpenConditionType = 1, --额外条件
    LevelType = 2, --等级条件
    PreStageType = 3, --前置关卡
}
---@param stageId  int 关卡id
---@param isShowTips boolean  是否展示tips
---@param LevelText int  等级提示的UIText
---@return boolean,StageLockType
function ChapterAndStageBLL:StageIsUnLock(stageId, isShowTips, LevelText)
    --[[
    if self:HasStage(stageId) then
        return true
    end
    --]]
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg == nil then
        return false
    end
    if stageCfg.ExOpenCondition ~= 0 then
        if not ConditionCheckUtil.CheckConditionByCommonConditionGroupId(stageCfg.ExOpenCondition) then
            local conditionDes = ConditionCheckUtil.GetConditionDescByGroupId(stageCfg.ExOpenCondition)
            if isShowTips then
                UICommonUtil.ShowMessage(conditionDes)
            end
            return false, StageLockType.ExOpenConditionType, conditionDes --额外条件描述
        end
    end

    if not ConditionCheckUtil.CheckConditionByIntList(stageCfg.NeedLevel) then
        if isShowTips then
            if LevelText ~= nil then
                UICommonUtil.ShowMessage(UITextHelper.GetUIText(LevelText, stageCfg.NeedLevel[2]))
            else
                UICommonUtil.ShowMessage(UITextHelper.GetUIText(UITextConst.UI_TEXT_9022, stageCfg.NeedLevel[2]))
            end
        end
        return false, StageLockType.LevelType, stageCfg.NeedLevel[2]  --等级
    end

    local isCanDo, preStageCfg = self:StageCanDo(stageCfg, isShowTips)
    if not isCanDo then
        return isCanDo, StageLockType.PreStageType, preStageCfg --前置关卡配置
    end
    return true
end

---指定关卡是否已通关
function ChapterAndStageBLL:StageIsUnLockById(stageId)
    if self:HasStage(stageId) then
        local stageData = self:GetStage(stageId)
        if stageData.State == enumStageState.passed then
            return true
        end
    end
    return false
end

function ChapterAndStageBLL:IsAutoNextStage()
    if self.isAutoStage or self:IsPrologueChapter() then
        return true
    end
    return false
end

---检查是否是自动进入下一关的关卡
function ChapterAndStageBLL:CheckAutoStage(stageId)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg.AutoNext == 1 and stageCfg.Type == 1 and ((not self:StageIsUnLockById(stageId)) or self.isForceCombo) then
        self.isAutoStage = true
    else
        self.isAutoStage = false
    end
end

function ChapterAndStageBLL:CheckAppendBatch(stageId)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg.AutoNext == 1 and stageCfg.Type == 1 and ((not self:StageIsUnLockById(stageId)) or self.isForceCombo) then
        self:AppendBatchCurStage(stageCfg)
    end
    if stageCfg.PreStageID and #stageCfg.PreStageID > 0 and stageCfg.PreStageID[1] ~= 0 then
        self:ClearPreLoadBatchIdTab(stageCfg.PreStageID[1])
    end
end

function ChapterAndStageBLL:AppendBatchCurStage(stageCfg)
    local curStageList = self:GetAllStageInfoByChapterId(stageCfg.ChapterInfoID)
    local index = 0
    local nextStageCfg = nil
    for i = 1, #curStageList do
        if stageCfg.ID == curStageList[i].ID then
            index = i
            break
        end
    end
    if index ~= 0 and index + 1 <= #curStageList then
        nextStageCfg = curStageList[index + 1]
    end
    if nextStageCfg then
        self:AppendBatchStage(stageCfg, nextStageCfg)
    end
end

function ChapterAndStageBLL:CancelStage()
    self.isAutoStage = false
end

---是否为序章模式
function ChapterAndStageBLL:IsPrologueChapter()
    local sundryCfg = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MAINLINESTORYPOINT)
    local stageId = sundryCfg
    if not self:StageIsUnLockById(stageId) and ChapterStageManager.GetIsOpenPorStage() then
        self.isProStage = true
        return true
    else
        self.isProStage = false
        return false
    end
end

local function get_loading_type(stageID)
    return BllMgr.GetHeadIconBLL():IsShowLoading() and GameConst.LoadingType.FaceEditHeadIcon or ChapterStageManager.GetStageLoadingType(stageID)
end

function ChapterAndStageBLL:StartProStage(isLoading)
    if isLoading == nil then
        isLoading = true
    end
    --UIMgr.CloseWindowsPanels()
    local StageData = nil
    local firstChapterId = 100
    local sundryCfg = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.CHAPTERSTART)
    if sundryCfg ~= nil then
        firstChapterId = tonumber(sundryCfg)
    end
    local allProStageCfg = self:GetAllStageInfoByChapterId(firstChapterId)
    if self:GetLastStageId() == 0 then
        local firstStageId = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PROLOGUESTART)
        local firstStageCfg = allProStageCfg[1]
        if firstStageId ~= nil then
            local stageCfg = LuaCfgMgr.Get("CommonStageEntry", tonumber(firstStageId))
            if stageCfg ~= nil and stageCfg.ID ~= 0 then
                firstStageCfg = stageCfg
            end
        end
        StageData = firstStageCfg
    else
        if self:StageIsUnLockById(self.LastStageId) then
            local lastStageCfg = LuaCfgMgr.Get("CommonStageEntry", self.LastStageId)
            if lastStageCfg ~= nil then
                for i = 1, #allProStageCfg do
                    local preStageTab = allProStageCfg[i].PreStageID
                    if table.containsvalue(preStageTab, lastStageCfg.ID) then
                        StageData = allProStageCfg[i]
                    end
                end
            end
        else
            StageData = LuaCfgMgr.Get("CommonStageEntry", self.LastStageId)
        end
    end
    local mType = StageData.SubType
    self:PreloadBatchPreChapter(StageData)
    if mType == Define.Enum_StageType.FightStage then
        --todo 战斗关卡部分loading问题等后续处理
        if BllMgr.GetHeadIconBLL():IsShowLoading() then
            BllMgr.GetHeadIconBLL():CloseLoading()
        end

        if not self:StageCanFight(StageData, false, true) then
            return
        end
        if StageData.DramaFront ~= 0 then
            if isLoading then
                local loadingType = ChapterStageManager.GetStageLoadingType(StageData.ID)
                UICommonUtil.SetLoadingEnableWithOpenParam({
                    MoveInCallBack = function()
                        if GameStateMgr.GetCurStateName() == GameState.MainStory then
                            ChapterStageManager.ResMainStory(false)
                            ChapterStageManager.InitMainStory(StageData.ID, true)
                        else
                            GameStateMgr.Switch(GameState.MainStory, StageData.ID, true)
                        end
                    end,
                    IsPlayMoveOut = true
                }, loadingType, true)
            else
                if GameStateMgr.GetCurStateName() == GameState.MainStory then
                    ChapterStageManager.ResMainStory(false)
                    ChapterStageManager.InitMainStory(StageData.ID, true)
                else
                    GameStateMgr.Switch(GameState.MainStory, StageData.ID, true)
                end
            end
        else
            ChapterStageManager.GoToTeamEditor(StageData, TeamConst.TeamType.MainLineBattle, true)
        end
    elseif mType == Define.Enum_StageType.MovieStage then
        if isLoading then
            UICommonUtil.SetLoadingEnableWithOpenParam({
                MoveInCallBack = function()
                    self:SendDoStageAsync(StageData.ID)
                end,
                IsPlayMoveOut = true
            }, get_loading_type(StageData.ID), true)
        else
            self:SendDoStageAsync(StageData.ID)
        end
    end

    if not isLoading and BllMgr.GetHeadIconBLL():IsShowLoading() then
        BllMgr.GetHeadIconBLL():EndLoading()
    end
end

function ChapterAndStageBLL:PreloadBatchPreChapter(curStageCfg)
    local curPreStageTab = self:GetCurPreStageTab(curStageCfg)
    for i = 1, #curPreStageTab do
        if i + 1 <= #curPreStageTab then
            local tempStageCfg = curPreStageTab[i]
            local tempNextStageCfg = curPreStageTab[i + 1]
            self:AppendBatchStage(tempStageCfg, tempNextStageCfg)
        end
    end
end

function ChapterAndStageBLL:AppendBatchStage(tempStageCfg, tempNextStageCfg)
    local linkIdTab = {}
    local tempId = 0
    if tempStageCfg.SubType == Define.Enum_StageType.FightStage then
        if tempStageCfg.DramaFront ~= 0 then
            tempId = PreloadBatchMgr.AppendBatchLink(PreloadBatchType.Dialogue, tostring(tempStageCfg.DramaFront), PreloadBatchType.Battle, tostring(tempStageCfg.ID))
            table.insert(linkIdTab, tempId)
        end
        if tempStageCfg.DramaAfter ~= 0 then
            tempId = PreloadBatchMgr.AppendBatchLink(PreloadBatchType.Battle, tostring(tempStageCfg.ID), PreloadBatchType.Dialogue, tostring(tempStageCfg.DramaAfter))
            table.insert(linkIdTab, tempId)
        end
    elseif tempStageCfg.SubType == Define.Enum_StageType.MovieStage then
        if tempStageCfg.DramaFront ~= 0 then
            if tempNextStageCfg.SubType == Define.Enum_StageType.FightStage then
                if tempNextStageCfg.DramaFront ~= 0 then
                    tempId = PreloadBatchMgr.AppendBatchLink(PreloadBatchType.Dialogue, tostring(tempStageCfg.DramaFront), PreloadBatchType.Dialogue, tostring(tempNextStageCfg.DramaFront))
                    table.insert(linkIdTab, tempId)
                    tempId = PreloadBatchMgr.AppendBatchLink(PreloadBatchType.Dialogue, tostring(tempNextStageCfg.DramaFront), PreloadBatchType.Battle, tostring(tempNextStageCfg.ID))
                    table.insert(linkIdTab, tempId)
                else
                    tempId = PreloadBatchMgr.AppendBatchLink(PreloadBatchType.Dialogue, tostring(tempStageCfg.DramaFront), PreloadBatchType.Battle, tostring(tempNextStageCfg.ID))
                    table.insert(linkIdTab, tempId)
                end
                if tempNextStageCfg.DramaAfter ~= 0 then
                    tempId = PreloadBatchMgr.AppendBatchLink(PreloadBatchType.Battle, tostring(tempNextStageCfg.ID), PreloadBatchType.Dialogue, tostring(tempNextStageCfg.DramaAfter))
                    table.insert(linkIdTab, tempId)
                end
            elseif tempStageCfg.SubType == Define.Enum_StageType.MovieStage then
                tempId = PreloadBatchMgr.AppendBatchLink(PreloadBatchType.Dialogue, tostring(tempStageCfg.DramaFront), PreloadBatchType.Dialogue, tostring(tempNextStageCfg.DramaFront))
                table.insert(linkIdTab, tempId)
            end
        end
    end
    self.PreLoadBatchIdDic[tempStageCfg.ID] = linkIdTab
end

function ChapterAndStageBLL:ClearPreLoadBatchIdTab(stageId)
    if stageId then
        if table.containskey(self.PreLoadBatchIdDic, stageId) then
            for i = 1, #self.PreLoadBatchIdDic[stageId] do
                local linkId = self.PreLoadBatchIdDic[stageId][i]
                PreloadBatchMgr.SubBatchLinkById(linkId)
            end
            self.PreLoadBatchIdDic[stageId] = nil
        end
    else
        for k, v in pairs(self.PreLoadBatchIdDic) do
            local linkIdTab = v
            for i = 1, #linkIdTab do
                PreloadBatchMgr.SubBatchLinkById(linkIdTab[i])
            end
        end
        self.PreLoadBatchIdDic = {}
    end
end

function ChapterAndStageBLL:GetCurPreStageTab(curStageCfg)
    local endStageId = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MAINLINESTORYPOINT)
    local sundryCfg = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.CHAPTERSTART)
    local firstChapterId = 100
    local endStageCfg = LuaCfgMgr.Get("CommonStageEntry", endStageId)
    firstChapterId = tonumber(sundryCfg)
    local starOrder = curStageCfg.Order
    local endOrder = endStageCfg.Order
    local retStageCfg = {}
    local allProStageCfg = self:GetAllStageInfoByChapterId(firstChapterId)
    for i = 1, #allProStageCfg do
        local tempStageCfg = allProStageCfg[i]
        if tempStageCfg.Order >= starOrder and tempStageCfg.Order <= endOrder then
            table.insert(retStageCfg, tempStageCfg)
            if tempStageCfg.Order == endOrder then
                break
            end
        end
    end
    return retStageCfg
end

---@gm设置连播不清除状态
function ChapterAndStageBLL:SetIsForceStageCombo(isForce)
    self.isForceCombo = isForce
end

function ChapterAndStageBLL:GetIsForceStageCombo(isForce)
    return self.isForceCombo
end

---@判断能否进入自动下一关
function ChapterAndStageBLL:CanIntoAutoStage(preStageId)
    local StageData = nil
    local lastStageCfg = LuaCfgMgr.Get("CommonStageEntry", preStageId)
    if lastStageCfg ~= nil then
        StageData = self:GetNextStage(lastStageCfg)
    end
    if StageData ~= nil then
        if not self:StageCanDo(StageData) then
            return false
        end
        local mType = StageData.SubType
        if mType == Define.Enum_StageType.FightStage then
            if not self:StageCanFight(StageData, false, true) then
                return false
            end
        end
    else
        return false
    end
    return true
end

function ChapterAndStageBLL:AutoStage(preStageId)
    local StageData = nil
    local lastStageCfg = LuaCfgMgr.Get("CommonStageEntry", preStageId)
    if lastStageCfg ~= nil then
        StageData = self:GetNextStage(lastStageCfg)
    end
    if StageData ~= nil then
        if not self:StageCanDo(StageData) then
            return
        end
        local mType = StageData.SubType
        if mType == Define.Enum_StageType.FightStage then
            if not self:StageCanFight(StageData, false, true) then
                return
            end
            if StageData.DramaFront ~= 0 then
                if GameStateMgr.GetCurStateName() == GameState.MainStory then
                    ChapterStageManager.ResMainStory(false)
                    ChapterStageManager.InitMainStory(StageData.ID, true)
                else
                    GameStateMgr.Switch(GameState.MainStory, StageData.ID, true)
                end
            else
                UIMgr.Close(UIConf.SpecialDatePlayWnd)
                ChapterStageManager.GoToTeamEditor(StageData, TeamConst.TeamType.MainLineBattle)
            end
        elseif mType == Define.Enum_StageType.MovieStage then
            self:SendDoStageAsync(StageData.ID)
        end
    end
end

---获取指定关卡的下一个关卡
---目前策划会对下一关进行配置
function ChapterAndStageBLL:GetNextStage(preStageCfg)
    if (not preStageCfg) or preStageCfg.AfterStageID == 0 then
        return
    end
    local nextCfg = LuaCfgMgr.Get("CommonStageEntry", preStageCfg.AfterStageID)
    return nextCfg
end

function ChapterAndStageBLL:CheckStage(preStageId)
    if self:IsPrologueChapter() and self:CanIntoAutoStage(preStageId) then
        self:AutoStage(preStageId)
    else
        ChapterStageManager.BackToMainHome()
    end
end
function ChapterAndStageBLL:SetIsProStage(flag)
    self.isProStage = flag
end

function ChapterAndStageBLL:OnMovieFinish(stageData, formationType)
    if stageData.IsShowFormation == 0 then
        local loadingType = ChapterStageManager.GetStageLoadingType()
        UICommonUtil.SetLoadingEnable(loadingType, true)
        self:_OnComplete(stageData, formationType)
    else
        ChapterStageManager.BackToMainHome()
        self:_OnComplete(stageData, formationType)
    end
end
function ChapterAndStageBLL:_OnComplete(stageData, formationType)
    ChapterStageManager.GoToTeamEditor(stageData, formationType)
end

---判断是否有进入关卡的资源
---@param StageData CommonStageEntry 关卡配置
---@param isShowTips boolean 是否飘字和弹窗
---@param isJudgePower boolean 是否进行体力判断
---@param isShowTips boolean 判断体力是否只飘字不弹购买弹窗
function ChapterAndStageBLL:StageCanFight(StageData, isShowTips, isJudgePower, powerShowTips)
    if StageData.Times and StageData.Times ~= 0 then
        local stage = self:GetStage(StageData.ID)
        if stage ~= nil and stage.Num >= StageData.Times then
            if isShowTips then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9044)
            end
            return false
        end
    end
    if isJudgePower then
        local enterCostTab = GameHelper.ToTable(StageData.EnterCost)
        if #enterCostTab > 0 or StageData.EnterCost ~= nil then
            local item = BllMgr.GetItemBLL():GetLocalItem(enterCostTab[1].ID)
            if item == nil then
                return false
            end

            if BllMgr.GetPlayerBLL():GetPlayerCoin().Power < enterCostTab[1].Num then
                if isShowTips then
                    if powerShowTips then
                        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5318)
                    else
                        UICommonUtil.ShowBuyPowerWnd()
                    end
                end
                return false
            end
        end
    end
    return true
end

--关卡跳转专用接口
function ChapterAndStageBLL:StageCanSkip(stageCfg, isShowTips)
    if stageCfg == nil then
        return false
    end
    if self:StageCanDo(stageCfg, isShowTips) then
        if self:StageCanFight(stageCfg, isShowTips, false) then
            return true
        end
    end
    return false
end

---关卡，处理服务器消息刷新关卡信息
function ChapterAndStageBLL:AddStage(stageList)
    if self.StageList == nil then
        self.StageList = {}
    end
    if stageList == nil then
        return
    end
    for i = 1, #stageList do
        local lastUnlockState = self:StageIsUnLockById(stageList[i].StageID)
        local tempStage = CreateStageInfo(stageList[i])
        self.StageList[stageList[i].StageID] = tempStage
        local curUnlockState = self:StageIsUnLockById(stageList[i].StageID)
        ---通过GM命令没有FinStageReply，只能通过这个方法来得知关卡通关了
        if lastUnlockState ~= curUnlockState then
            EventMgr.Dispatch("UnlockStage", stageList[i].StageID)
        end
    end
    EventMgr.Dispatch("OnStageChangeBack", stageList)
end

function ChapterAndStageBLL:RemoveStage(stageList)
    if self.StageList == nil or stageList == nil then
        return
    end
    for i = 1, #stageList do
        self.StageList[stageList[i].StageID] = nil
    end
end

function ChapterAndStageBLL:GetStage(stageId)
    if not self:HasStage(stageId) then
        return nil
    end
    return self.StageList[stageId]
end

function ChapterAndStageBLL:HasStage(stageId)
    return table.containskey(self.StageList, stageId)
end

function ChapterAndStageBLL:GetAllStageInfoByChapterId(chapterId)
    local retTab = {}
    local stageList = LuaCfgMgr.Get("CommonStageEntryByChapterId", chapterId)
    if stageList then
        retTab = stageList
    end
    return retTab
end

---获取指定章节所有已解锁关卡
function ChapterAndStageBLL:GetAllLockStageCfgByChapterId(chapterId)
    local retTab = {}
    local stagesTab = self:GetAllStageInfoByChapterId(chapterId)
    for i = 1, #stagesTab do
        if self:StageCanDo(stagesTab[i], false) then
            table.insert(retTab, stagesTab[i])
        end
    end
    return retTab
end
function ChapterAndStageBLL:StageIsThreeStar(stageId)
    if not self:HasStage(stageId) then
        return false
    end
    local stage = self:GetStage(stageId)
    return stage.Star >= 3
end

function ChapterAndStageBLL:GetStageStar(stageId)
    local stage = self:GetStage(stageId)
    return stage and stage.Star or 0
end

---获取对应星级的状态
---@param stageId int 关卡id
---@param star int 查询的是哪颗星是否完成
---@return bool 是否完成
function ChapterAndStageBLL:GetStarState(stageId, star)
    if star <= 0 or star > 3 then
        return false
    end
    local stage = self:GetStage(stageId)
    local starState = stage and stage.ShowStar or 0
    return (starState & (1 << (star - 1))) ~= 0
end

function ChapterAndStageBLL:CanSweep(stageId)
    local star = self:GetStageStar(stageId)
    local needStar = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.FASTBATTLENEEDSTAR)
    return star >= needStar
end

function ChapterAndStageBLL:SetSweepRoleId(roleId)
    self.RoleID = roleId
    EventMgr.Dispatch("OnChooseRoleChangeBack", roleId)
end

function ChapterAndStageBLL:MovieStageCallBack(stageId)
    local stage = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stage == nil then
        Debug.Log("MovieStageCallBack stageCfg is nil", tostring(stageId))
        return
    end
    Debug.Log("MovieStageCallBack stageId", tostring(stageId))
    if GameStateMgr.GetCurStateName() == GameState.MainStory then
        ChapterStageManager.ResMainStory(false)
        ChapterStageManager.InitMainStory(stageId, true)
    else
        Debug.Log(" GameStateMgr.Switch MainStory ", tostring(stageId))
        GameStateMgr.Switch(GameState.MainStory, stageId, true)
    end
end

function ChapterAndStageBLL:IsHaveRpByDifficulty(difficuly)
    local allChapterInfoCfg = self:GetChapterByType(difficuly)
    for i = 1, #allChapterInfoCfg do
        if self:IsHaveGetStartRewardByChapterId(allChapterInfoCfg[i].ID) then
            return true
        end
    end
    return false
end
--星级宝箱章节红点
function ChapterAndStageBLL:IsHaveGetStartRewardByChapterId(chapterId)
    local chapterReward = self:GetChapterStarRewardInfo(chapterId)
    local chapter = self:GetChapter(chapterId)
    local currentStar = 0
    if chapter == nil then
        currentStar = 0
    else
        currentStar = chapter.Star
    end
    for i = 1, #chapterReward do
        local reward = chapterReward[i]
        local isOpen = currentStar >= reward.NeedStarNum
        if isOpen then
            local isGet = ((chapter.Reward & (1 << reward.ID)) >> reward.ID) == 1
            if not isGet then
                return true
            end
        end
    end
    return false
end

function ChapterAndStageBLL:GetFirstChapterId()
    local firstChapterId = 100
    local sundryCfg = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.CHAPTERSTART)
    if sundryCfg == 0 then
    else
        firstChapterId = tonumber(sundryCfg)
    end
    return firstChapterId
end
--UI用 是否在关卡界面隐藏数量
function ChapterAndStageBLL:IsHideItemNum(itemType)
    local hideTypeTab = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.TIPSSTAGESHOWTYPE)
    if table.containsvalue(hideTypeTab, itemType) then
        return true
    end
    return false
end
--发送服务器消息
function ChapterAndStageBLL:SendDoStage(stageId)
    local messageBody = {}
    messageBody.StageID = stageId
    self.tryEnterStageId = stageId
    GrpcMgr.SendRequest(RpcDefines.DoStageRequest, messageBody, true)
end
function ChapterAndStageBLL:SendDoStageAsync(stageId)
    local messageBody = {}
    messageBody.StageID = stageId
    self.tryEnterStageId = stageId
    GrpcMgr.SendRequest(RpcDefines.DoStageRequest, messageBody, true)
end

function ChapterAndStageBLL:SendDoStageT(stageId, formation)
    local messageBody = {}
    messageBody.StageID = stageId
    messageBody.Formation = formation
    self.tryEnterStageId = stageId
    self.tryEnterFormationData = formation
    GrpcMgr.SendRequest(RpcDefines.DoStageRequest, messageBody, true)
end

function ChapterAndStageBLL:SendFinStage(stageId)
    local messageBody = {}
    messageBody.StageID = stageId
    GrpcMgr.SendRequest(RpcDefines.FinStageRequest, messageBody)
end
function ChapterAndStageBLL:SendChapterStarReward(chapterId, rewardId)
    local messageBody = {}
    messageBody.ChapterID = chapterId
    messageBody.Index = rewardId
    GrpcMgr.SendRequest(RpcDefines.ChapterStarRewardRequest, messageBody)
end

function ChapterAndStageBLL:SendSweep(stageId, num, sweepTargetItem, isSetDelay)
    if isSetDelay then
        ErrandMgr.SetDelay(true)
    end

    self:ClearSweepTargetItem()

    local messageBody = {}
    messageBody.StageID = stageId
    messageBody.Num = num
    if sweepTargetItem ~= nil and sweepTargetItem.ID ~= nil then
        local haveNum = BllMgr.GetItemBLL():GetItemNum(sweepTargetItem.ID)
        local needNum = sweepTargetItem.Num - haveNum  ---sweepTargetItem.Num表示总的需要数量
        if needNum > 0 then
            local targetItem = {}
            targetItem.Id = sweepTargetItem.ID
            targetItem.Num = needNum ---给服务端的targetItem.Num表示的是距离总的数量还差多少数量
            messageBody.TargetItem = targetItem

            ---拥有数量不足时，本地存一下本次扫荡的目标物品信息，用于扫荡UI界面显示
            self:SetSweepTargetItem(sweepTargetItem)
        end
    end

    GrpcMgr.SendRequest(RpcDefines.SweepRequest, messageBody)
end

---发送进入关卡的消息
function ChapterAndStageBLL:SendDoStageHaveTeam(stageId, teamInfo)
    if teamInfo == nil then
        Debug.LogError("阵容不能为空")
        return
    end
    local messageBody = {}
    messageBody.StageID = stageId
    messageBody.Formation = teamInfo
    self.tryEnterStageId = stageId
    self.tryEnterFormationData = teamInfo
    GrpcMgr.SendRequest(RpcDefines.DoStageRequest, messageBody, true)
end
function ChapterAndStageBLL:SendSetSweepRole(roleId)
    local messageBody = {}
    messageBody.RoleID = roleId
    GrpcMgr.SendRequest(RpcDefines.SetSweepRoleRequest, messageBody)
end
function ChapterAndStageBLL:SendSetDrama(stageId, dramaId)
    local messageBody = {}
    messageBody.StageID = stageId
    messageBody.DramaID = dramaId
    GrpcMgr.SendRequest(RpcDefines.DramaRequest, messageBody)
end
function ChapterAndStageBLL:SendC2SCancelStage(stageId)
    local messageBody = {}
    messageBody.StageID = stageId
    self:CancelStage()
    GrpcMgr.SendRequest(RpcDefines.CancelStageRequest, messageBody, true)
end

function ChapterAndStageBLL:SendC2SBuyStageTimes(stageId, times)
    local messageBody = {}
    messageBody.StageID = stageId
    messageBody.Times = times
    GrpcMgr.SendRequest(RpcDefines.BuyStageTimesRequest, messageBody)
end

function ChapterAndStageBLL:SendC2SMainLineReward(chapterId)
    local messageBody = {}
    messageBody.ChapterID = chapterId
    GrpcMgr.SendRequest(RpcDefines.MainLineRewardRequest, messageBody, true)
end

function ChapterAndStageBLL:SendC2SMainLineRewardOneKey(chapterId, taskIdList)
    local messageBody = {}
    messageBody.ChapterID = chapterId
    messageBody.TaskIDList = taskIdList
    GrpcMgr.SendRequest(RpcDefines.MainLineRewardOneKeyRequest, messageBody, true)
end

function ChapterAndStageBLL:CheckCondition(id, datas, iDataProvider)
    local result = false
    if id == X3_CFG_CONST.CONDITION_GAMELEVEL_RELATION_CLEAR then
        result = self:StageIsUnLockById(tonumber(datas[1]))
    elseif id == X3_CFG_CONST.CONDITION_STAGE_STATUS then
        result = self:StageStatus(tonumber(datas[1]), tonumber(datas[2]))
    elseif id == X3_CFG_CONST.CONDITION_MIANLINE_CHAPTER_STATUS then
        result = not self:ChapterIsLock(tonumber(datas[1]))
    elseif id == X3_CFG_CONST.CONDITION_BATTLE_STAGEIDCHECK then
        result = datas[1] == self.tryEnterStageId
    elseif id == X3_CFG_CONST.CONDITION_BATTLE_MONSTERIDCHECK then
        local monsterID = datas[2]
        local stageCfg = LuaCfgMgr.Get("CommonStageEntry", self.tryEnterStageId)
        if stageCfg then
            local monsterIDs = stageCfg.MonsterForShow
            for i = 1, #monsterIDs do
                if monsterIDs[i].ID == monsterID then
                    return datas[1] == 1
                end
            end
        end
        return datas[1] ~= 1
    elseif id == X3_CFG_CONST.CONDITION_MAINLINE_STAGEISSERIES then
        local boolTemp = false
        if datas[1] == 1 then
            boolTemp = true
        elseif datas[1] == 0 then
            boolTemp = false
        end
        return boolTemp == self.isProStage
    elseif id == X3_CFG_CONST.CONDITION_MAINLINE_CONTINUATION then
        ---是否是连播状态
        result = self:IsAutoNextStage()
    elseif id == X3_CFG_CONST.CONDITION_TEAM_SCORE then
        result = self:CheckScoreID(datas)
    elseif id == X3_CFG_CONST.CONDITION_COUPLE_SUIT then
        result = self:CheckCoupleSuit(datas)
    elseif id == X3_CFG_CONST.CONDITION_BATTLE_TIME then
        result = self:CheckBattlePassTime(datas)
    end
    return result
end

--进入战斗的男女主是否为情侣装（Para1,1是，0否）备注：原色皮和变色皮搭配，算情侣装
function ChapterAndStageBLL:CheckCoupleSuit(datas)
    if self.tryEnterFormationData == nil or self.tryEnterFormationData.SCoreID == nil then
        return false
    end
    local checkNum = tonumber(datas[1])
    local suitID = self.tryEnterFormationData.PlSuitId
    local scoreId = self.tryEnterFormationData.SCoreID
    local currentNum = 0
    if BllMgr.GetScoreBLL():Is_Couple_SuitId_ScoreId(suitID, scoreId) then
        currentNum = 1
    end
    return checkNum == currentNum
end

function ChapterAndStageBLL:CheckScoreID(datas)
    --进入战斗的搭档身份是否（Para1,1是，0否）为指定ID（Para2）
    if self.tryEnterFormationData == nil or self.tryEnterFormationData.SCoreID == nil then
        return false
    end
    local checkNum = tonumber(datas[1])
    local targetID = tonumber(datas[2])
    local scoreID = self.tryEnterFormationData.SCoreID
    local resultNum = scoreID == targetID and 1 or 0
    return resultNum == checkNum
end
---判断最短通关时间
function ChapterAndStageBLL:CheckBattlePassTime(datas)
    local targetTime = datas[4]
    local minTime = 3000 --随便给一个大数
    if self.TypePassTime == nil then
        return false
    end
    for k, v in pairs(self.TypePassTime) do
        local isExcept = false
        for i = 1, 3 do
            if datas[i] ~= 0 and k == datas[i] then
                isExcept = true
                break
            end
        end
        if (not isExcept) and minTime > v then
            minTime = v
        end
    end
    return minTime <= targetTime
end
---检查是否在list列表中
---@param fashionList table<int,int>
---@param fashionID int
---@return boolean 是否相等
local function CheckIsInFashionList(fashionList, fashionID)
    if fashionList == nil then
        return false
    end

    local equal = false
    for i, v in ipairs(fashionList) do
        ---@type cfg.FashionData
        local fashionCfg = LuaCfgMgr.Get("FashionData", v)
        if fashionCfg.PartEnum == X3_CFG_CONST.FASHIONPART_CLOTH and fashionID == v then
            equal = true
            break
        end
    end
    return equal
end

---检查穿着与他今天最近一次战斗同款的score原始/爆衫服装
---@param roleId int 角色id
---@param fashionID int 当前score穿戴的fashionID
---@param fashionType int  0表示原始服装，1表示爆衫服装， -1表示无限制、同款的原始or爆衫均可通过
---@return int -1：无效字段 1：相等 0：不等
function ChapterAndStageBLL:CheckPreBattleFormationSuit(fashionID, fashionType, roleId)
    local dungeonRecord = BllMgr.GetDungeonRecordBLL():GetLatestDungeonRecordCurDay(roleId)
    if table.isnilorempty(dungeonRecord) then return -1 end
    
    ---@type cfg.SCoreBaseInfo
    local sCoreBaseInfoCfg = LuaCfgMgr.Get("SCoreBaseInfo", dungeonRecord.Formation.SCoreID)
    ---@type cfg.FormationSuit
    local fashionSuitCfg = LuaCfgMgr.Get("FormationSuit",sCoreBaseInfoCfg.DefaultSkin)
    if fashionSuitCfg.FashionList then
        if fashionType == 0 or fashionType == -1 then
            local equal = CheckIsInFashionList(fashionSuitCfg.FashionList, fashionID)
            if equal then
                return 1
            end
        end
    end

    if fashionSuitCfg.DirtFashionList then
        if fashionType == 1 or fashionType == -1 then
            local equal = CheckIsInFashionList(fashionSuitCfg.DirtFashionList, fashionID)
            if equal then
                return 1
            end
        end
    end
    
    return 0
end

function ChapterAndStageBLL:GetEnterBattleFormationData()
    return self.tryEnterFormationData
end

function ChapterAndStageBLL:StageStatus(stageId, stageStatusType)
    local ret = false
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageStatusType == 1 then
        --未解锁状态
        if not self:StageCanDo(stageCfg, false) then
            ret = true
        end
    elseif stageStatusType == 2 then
        --已解锁未通过
        if self:StageCanDo(stageCfg, false) then
            if not self:StageIsUnLockById(stageId) then
                ret = true
            end
        end
    elseif stageStatusType == 3 then
        --已通关
        ret = self:StageIsUnLockById(stageId)
    elseif stageStatusType == 4 then
        --一星通过

        ret = self:StageIsHaveStarNum(stageId, 1)
    elseif stageStatusType == 5 then
        --二星通过

        ret = self:StageIsHaveStarNum(stageId, 2)
    elseif stageStatusType == 6 then
        --三星通过

        ret = self:StageIsHaveStarNum(stageId, 3)
    end

    return ret
end

function ChapterAndStageBLL:StageIsHaveStarNum(stageId, starNum)
    if not self:HasStage(stageId) then
        return false
    end
    local stage = self:GetStage(stageId)
    return stage.Star >= starNum
end

---------------------主线红点相关--------------------------------
---根据章节刷新红点
local function RefreshRedByChapter(chapter_id, count)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_MAINLINE_REWARD, count, chapter_id)
    local chapterInfoCfg = LuaCfgMgr.Get("ChapterInfo", chapter_id)
    if chapterInfoCfg ~= nil then
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_MAINLINE_REWARD_DIFFICULTY, BllMgr.GetChapterAndStageBLL():IsHaveRpByDifficulty(chapterInfoCfg.Difficulty) and 1 or 0, 1)
    end
end
---刷新红点数据
function ChapterAndStageBLL:RefreshChapterRed(check_map, is_remove)
    check_map = check_map or self.ChapterList
    for k, v in pairs(check_map) do
        local chapter_id = v.ChapterID
        local red_count = is_remove and 0 or (self:IsHaveGetStartRewardByChapterId(chapter_id) and 1 or 0)
        RefreshRedByChapter(chapter_id, red_count)
    end
end

---返回刷新规则
---@param customType int
---@return int, string
function ChapterAndStageBLL:GetRefreshSchedule(customType, id, ...)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", id)
    ---保护返回默认值
    if not stageCfg then
        return 0, ""
    end
    return stageCfg.TimesRefreshType, stageCfg.TimesRefreshDetail
end

---返回刷新值
---@param curValue int
---@param customType int
---@return int
function ChapterAndStageBLL:GetRefreshValue(curValue, customType, id, manType, ...)
    local newValue = curValue
    if customType == DataSaveCustomType.DataSaveCustomTypeStageNum then
        newValue = 0
    elseif customType == DataSaveCustomType.DataSaveCustomTypeStageBuyTimes then
        newValue = 0
    end
    return newValue
end

---监听CustomRecord消息
---@param customType int
function ChapterAndStageBLL:CustomRecordUpdate(customType, id, ...)
    if customType == DataSaveCustomType.DataSaveCustomTypeStageNum then
        if self.StageList[id] then
            self.StageList[id].Num = SelfProxyFactory.GetCustomRecordProxy():GetCustomRecordValue(DataSaveCustomType.DataSaveCustomTypeStageNum, id)
        end
    elseif customType == DataSaveCustomType.DataSaveCustomTypeStageBuyTimes then
        if self.StageList[id] then
            self.StageList[id].DailyBuyTimes = SelfProxyFactory.GetCustomRecordProxy():GetCustomRecordValue(DataSaveCustomType.DataSaveCustomTypeStageBuyTimes, id)
        end
    end
    EventMgr.Dispatch("OnStageChangeBack")
end

----------------------------jump跳转相关--------------------------start

---主线跳转
---@param chapterId int 主线章节id
function ChapterAndStageBLL:JumpToChapterMainWnd(chapterId)

    if not chapterId or chapterId == 0 then
        ---跳转最新章节 选中最新关卡
        local targetStageCfg = self:GetMainlineNowStage()
        self:ShowChapterMainWnd(targetStageCfg)
        return
    end

    local allChapterStageCfg = self:GetAllStageInfoByChapterId(chapterId)
    if not allChapterStageCfg or #allChapterStageCfg == 0 then
        ---跳转最新章节 选中最新关卡
        local targetStageCfg = self:GetMainlineNowStage()
        self:ShowChapterMainWnd(targetStageCfg)
        return
    end

    if not self:ChapterIsLock(chapterId) then
        ---此章节已解锁 跳转到此章节内可挑战的最新关卡
        local targetStageCfg = self:GetChapterNowStage(chapterId)
        if targetStageCfg then
            self:ShowChapterMainWnd(targetStageCfg)
            return
        end
    end

    ---此章节未解锁 查看是否有未通关且可挑战的最新关卡
    local lastStageCfg = self:GetLastStage()
    local nextStageCfg = self:GetNextStage(lastStageCfg)

    if nextStageCfg then
        if self:ChapterIsLock(nextStageCfg.ChapterInfoID, true) then
            ---最新关卡的章节未解锁
            return
        end

        if not self:StageIsUnLock(nextStageCfg.ID, true) then
            ---最新关卡未解锁
            return
        end
    end

    ---最新关卡可进入且未通关过
    self:ShowChapterMainWnd(nextStageCfg)
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5810) ---"请先通关前置章节关卡哦"

end

---获取已通关的关卡里进度最新的关卡
function ChapterAndStageBLL:GetLastStage()
    local tab = {}
    for k, v in pairs(self.StageList) do
        if v.State == enumStageState.passed then
            table.insert(tab, k)
        end
    end
    table.sort(tab, function(x, y)
        local xCfg = LuaCfgMgr.Get("CommonStageEntry", x)
        if not xCfg then
            return false
        end

        local yCfg = LuaCfgMgr.Get("CommonStageEntry", y)
        if not yCfg then
            return false
        end

        return xCfg.Order < yCfg.Order
    end)

    local lastStageId = tab[#tab]
    local lastStageCfg = LuaCfgMgr.Get("CommonStageEntry", lastStageId)
    return lastStageCfg
end

---获取主线最新可进入关卡
function ChapterAndStageBLL:GetMainlineNowStage()

    local lastStageCfg = self:GetLastStage()
    local nextStageCfg = self:GetNextStage(lastStageCfg)
    if not nextStageCfg then
        return lastStageCfg
    end

    if not self:StageIsUnLock(lastStageCfg.ID) then
        return lastStageCfg
    end

    return nextStageCfg
end

---获取指定已解锁章节最新可进入关卡，若全部通关则返回第一关
function ChapterAndStageBLL:GetChapterNowStage(chapterId)
    local result = nil
    local allChapterStageCfg = self:GetAllStageInfoByChapterId(chapterId)
    local stageCount = #allChapterStageCfg

    for i = stageCount, 1, -1 do
        local stageId = allChapterStageCfg[i].ID
        if self:StageIsUnLock(stageId) then
            ---从后往前遇到的第一个已解锁关卡就是此章节可挑战的最新关卡
            result = stageId
            if i == stageCount then
                ---如果此章节全部都通关了就跳转到此章节第一关
                result = allChapterStageCfg[1].ID
            end
            break
        end
    end

    result = LuaCfgMgr.Get("CommonStageEntry", result)

    return result
end

----------------------------jump跳转相关--------------------------end

---检测指定章节的分包资源是否存在
function ChapterAndStageBLL:CheckChapterSubPackage(chapterId, callback)
    SubPackageUtil.EnterSystem(Define.SubPackageType.CHAPTER, Define.SupPackageSubType.DEFAULT, chapterId, callback)
end
---分包是否存在
function ChapterAndStageBLL:CheckChapterSubPackageLoaded(chapterId)
    return SubPackageUtil.IsHaveSubPackage(Define.SubPackageType.CHAPTER, Define.SupPackageSubType.DEFAULT, chapterId)
end
---分包状态
---@return SubPackage.PackageDownloadState  PackageDownloadState  分包下载状态
function ChapterAndStageBLL:GetChapterSubPackageState(chapterId)
    SubPackageUtil.GetPackageState(Define.SubPackageType.CHAPTER, Define.SupPackageSubType.DEFAULT, chapterId)
end
---暂停下载
function ChapterAndStageBLL:PauseDownload(chapterId)
    SubPackageUtil.PausePackage(Define.SubPackageType.CHAPTER, Define.SupPackageSubType.DEFAULT, chapterId)
end

function ChapterAndStageBLL:DownLoadSubPackage(chapterId)
    SubPackageUtil.DownloadPackage(Define.SubPackageType.CHAPTER, Define.SupPackageSubType.DEFAULT, chapterId)
end

---指定关卡是否已解锁且未通关
function ChapterAndStageBLL:IsStageUnlockAndNotPass(stageId)
    local isUnlock = self:StageIsUnLock(stageId)
    local stage = self:GetStage(stageId)

    local isNotPass = not stage or stage.State ~= enumStageState.passed

    --Debug.LogErrorFormat("关卡:%s是否已解锁:%s,是否未通关:%s",stageId,isUnlock,isNotPass)

    return isUnlock and isNotPass
end

---指定关卡是否有播放过解锁动效的本地记录
function ChapterAndStageBLL:IsPlayedStageUnlockMotion(stageId)
    local key = self:GetPlayedStageUnlockMotionKey(stageId)
    local value = PlayerPrefs.GetBool(key, false)
    --Debug.LogErrorFormat("关卡:%s是否播放过解锁动效:%s",stageId,tostring(value))
    return value
end

---记录指定关卡的解锁动效播放记录
function ChapterAndStageBLL:PlayedStageUnlockMotion(stageId)
    local key = self:GetPlayedStageUnlockMotionKey(stageId)
    PlayerPrefs.SetBool(key, true)
    --Debug.LogError(key)
end

---获取指定关卡的解锁动效播放记录的key
function ChapterAndStageBLL:GetPlayedStageUnlockMotionKey(stageId)
    local uid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
    local key = string.format("%s_%s_%s", "PlayedStageUnlockMotion", stageId, uid)
    return key
end

---可以切换到的指定章节是否是最新章节
function ChapterAndStageBLL:IsChapterNowWithCanChange(chapterId)

    ---是否不包括在ChapterList表里
    if not self:HasChapter(chapterId) then
        return true
    end

    ---是否是ChapterList里最大的章节id
    for id, v in pairs(self.ChapterList) do
        if id > chapterId then
            return false
        end
    end
    return true

end

---指定章节是否有播放过解锁动效的本地记录
function ChapterAndStageBLL:IsPlayedChapterUnlockMotion(chapterId)
    local key = self:GetPlayedChapterUnlockMotionKey(chapterId)
    local value = PlayerPrefs.GetBool(key, false)
    return value
end

---记录指定章节的解锁动效播放记录
function ChapterAndStageBLL:PlayedChapterUnlockMotion(chapterId)
    local key = self:GetPlayedChapterUnlockMotionKey(chapterId)
    PlayerPrefs.SetBool(key, true)
    --Debug.LogError(key)
end

---获取指定章节的解锁动效播放记录的key
function ChapterAndStageBLL:GetPlayedChapterUnlockMotionKey(chapterId)
    local uid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
    local key = string.format("%s_%s_%s", "PlayedChapterUnlockMotion", chapterId, uid)
    return key
end

---设置主线BGM tag的章节id
function ChapterAndStageBLL:SetSoundTagChapterId(chapterId)
    self.soundTagChapterId = chapterId
end



---是否自动选中过指定章节的下一章关卡item
function ChapterAndStageBLL:IsAutoSelectNextChapterItem(chapterId)
    local key = self:GetAutoSelectNextChapterItemKey(chapterId)
    local value = PlayerPrefs.GetBool(key, false)
    return value
end

---自动选中指定章节的下一章关卡item
function ChapterAndStageBLL:AutoSelectNextChapterItem(chapterId)
    local key = self:GetAutoSelectNextChapterItemKey(chapterId)
    PlayerPrefs.SetBool(key, true)
end

---获取 自动选中指定章节的下一章关卡item 的key
function ChapterAndStageBLL:GetAutoSelectNextChapterItemKey(chapterId)
    local uid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
    local key = string.format("%s_%s_%s", "AutoSelectNextChapterItem", chapterId, uid)
    return key
end

---判断关卡是否能从布阵界面退出，连续关卡用
function ChapterAndStageBLL:CanBackFromTeam(stageId)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg ~= nil and stageCfg.IsShowESC ~= nil then
        if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(stageCfg.IsShowESC.ID) then
            return (not (stageCfg.IsShowESC.Num == 1))
        end
    end
    return true
end
---记录当前是否在关卡中
function ChapterAndStageBLL:SetInStage(stageId)
    self.inStageId = stageId
    self.isInStage = true
    ---处理音频
    GameSoundMgr.SetAutoMode(false)
end

function ChapterAndStageBLL:SetOutStage()
    self.isInStage = false
    self.tryEnterStageId = -1
    --self.tryEnterFormationData = nil
end
---处理进入关卡错误码
function ChapterAndStageBLL:OnDoStageError(errCode, reply)
    self.tryEnterStageId = -1
    self.tryEnterFormationData = nil
end

function ChapterAndStageBLL:OnReconnect()
    --if self.isInStage then
        ---音频处理
    --    GameSoundMgr.SetAutoMode(true)
    --    self:SendC2SCancelStage(self.inStageId)
    --end
end
---判断关卡是否有tag，决定推荐
function ChapterAndStageBLL:HasTag(stageId)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    local hasTag = stageCfg.Tag ~= nil and #stageCfg.Tag ~= 0
    return hasTag
end
---判断关卡是否显示推荐界面
function ChapterAndStageBLL:CanRecommend(stageId)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg.RecoTeamIsOpen == 0 then
        return false
    end
    return #self:GetRecommendList(stageId) ~= 0
end
---获取关卡的推荐Score列表
function ChapterAndStageBLL:GetRecommendList(stageId)
    local scoreList = {}
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg.Tag == nil or #stageCfg.Tag == 0 then
        return scoreList
    end
    local scoreCfgList = LuaCfgMgr.GetAll("SCoreBaseInfo")
    for k, v in pairs(scoreCfgList) do
        local scoreTag = v.Tag
        local matchTag = true
        for j = 1, #stageCfg.Tag do
            if not table.containsvalue(scoreTag, stageCfg.Tag[j]) then
                matchTag = false
                break
            end
        end
        if matchTag then
            ---策划配置不可见的Score不显示
            if v.Disable ~= 1 and v.Visible ~= 0 then
                table.insert(scoreList, v)
            end
        end
    end
    return scoreList
end
---处理玩家主动取消
function ChapterAndStageBLL:OnCancelStage(stageID)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageID)
    if stageCfg.SubType == Define.Enum_StageType.MovieStage then
        ChapterStageManager.BackToMainHome()
    else
        --战斗构建结算数据
        local data = {
            StageID = stageID,
            IsWin = 0,
            IsCancel = true
        }
        g_battleLauncher.settlementState:SetStatisticsUIData(data)
    end
    EventMgr.Dispatch("OnStageFinish")
    self:SetOutStage()
end
---处理关卡完成
function ChapterAndStageBLL:OnFinStageReply(errorCode, reply, quest)
    local data = reply.Result and reply.Result or reply
    if data == nil or data.Stage == nil then
        return
    end
    if quest then
        data.ResultReason = quest.Result.Result
    end
    ---更新关卡信息
    local stageList = {}
    table.insert(stageList, data.Stage)
    BllMgr.GetChapterAndStageBLL():AddStage(stageList)

    local stageData = LuaCfgMgr.Get("CommonStageEntry", data.Stage.StageID)
    if stageData == nil then
        return
    end
    if quest and data.IsWin == 1 then
        self:UpdateMinPassTime(stageData.Type, quest.Result.BattleTime)
    end
    ---协议字段修改
    data.StageID = data.Stage.StageID
    if stageData.Type == 3 then
        if data.IsWin == 1 then
            EventMgr.Dispatch("Tower_StageFinish", stageData.ID)
        end
        g_battleLauncher.settlementState:SetStatisticsUIData(data)
    else
        if stageData.SubType == 2 then
            g_battleLauncher.settlementState:SetStatisticsUIData(data)
        elseif stageData.SubType == 1 then
            ChapterStageManager.FightMovieStage(data)
        end
    end
    EventMgr.Dispatch("UserStageGrpcHandle_FinStageReply", data)
    EventMgr.Dispatch("OnStageFinish")
    BllMgr.GetChapterAndStageBLL():SetOutStage()
end

function ChapterAndStageBLL:UpdateMinPassTime(type, time)
    if self.TypePassTime == nil then
        self.TypePassTime = {}
    end
    if self.TypePassTime[type] == nil then
        self.TypePassTime[type] = time
    else
        self.TypePassTime[type] = math.min(time, self.TypePassTime[type])
    end
end
---与策划规定方法，至少半年内不改
---@param numType int 对应X3Battle.MonsterProperty.NumType
function ChapterAndStageBLL:GetMonsterRate(numType)
    local monsterRate = numType
    if monsterRate >= 10 then
        monsterRate = math.floor(monsterRate / 10)
    end
    monsterRate = math.min(math.max(monsterRate, 1), 3)
    return monsterRate
end

return ChapterAndStageBLL
