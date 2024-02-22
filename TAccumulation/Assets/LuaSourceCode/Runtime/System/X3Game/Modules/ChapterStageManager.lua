---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-16 15:32:39
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

require "Runtime.System.X3Game.Data.Bll.ChapterAndStageBLL"
---@class ChapterStageManager
local ChapterStageManager = {}
local isOpenPorStage = true--是否开启序章外部调用
if UNITY_EDITOR then
    isOpenPorStage = false
else
    isOpenPorStage = true
end
local mFormationType = nil  --编队类型
local virtualCamera = nil-- 剧情添加虚拟相机
local isStageBackMainHome = false  --是否是从主线回到主界面
local stageGuideJumpFun = nil --战斗结算通关指引跳转的回调
local isInAutoStage = false --处于连播模式
local curStageId = -1 --当前进行的关卡ID
local finStageReply = nil --当前结束的关卡信息

---@初始化
function ChapterStageManager.Init()
    curStageId = -1
    isStageBackMainHome = false
end

---@Clear
function ChapterStageManager.Clear()
    curStageId = -1
    isStageBackMainHome = false
end

---@ 前往编队
---@param entry cfg.CommonStageEntry  关卡配置
---@param formationType int 编队类型
---@param hunterContestKey int 大螺旋编队key
---@param rankLevel int 大螺旋段位组等级
function ChapterStageManager.GoToTeamEditor(entry, formationType, hunterContestKey, rankLevel)
    local curTeamEditorStageCfg = entry
    if formationType == nil then
        formationType = TeamConst.TeamType.MainLineBattle
    end
    if curTeamEditorStageCfg.IsShowFormation == 0 then
        local teamId = BllMgr.GetFormationBLL():GetTeamIdByStageId(formationType, curTeamEditorStageCfg.ID)
        local teamInfo = SelfProxyFactory.GetFormationProxy():GetFormationByGuid(teamId)
        if teamInfo == nil then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_8329)
            return
        end
        BllMgr.GetChapterAndStageBLL():SendDoStageHaveTeam(curTeamEditorStageCfg.ID, teamInfo)
        return
    end
    if entry.TeamEnterShowType ~= nil then
        for i, v in ipairs(entry.TeamEnterShowType) do
            if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(v.ID) then
                if v.Num  == 2 then
                    UICommonUtil.BlackScreenOut()
                    break
                elseif v.Num  == 3 then
                    UICommonUtil.WhiteScreenOut()
                    break
                end
            end
        end
    end
    UICommonUtil.SetCaptureEnable(false)
    UIMgr.Open(UIConf.TeamWnd, TeamConst.FormationType.Formation, formationType, curTeamEditorStageCfg.ID, hunterContestKey, rankLevel)
end

---@开始关卡
------@param stageId int
function ChapterStageManager.OnStageStart(stageId)
    curStageId = stageId
end

---获取当前关卡id
---@return int
function ChapterStageManager.GetCurStageID()
    return curStageId
end

---@通用结束战斗
---@param stageReplyData  FinStageReply
function ChapterStageManager.EndBattle(stageReplyData)
    --message FinStageReply {
    --repeated S3Int ExpR = 1;        //成功通关获得玩家经验值
    --repeated S3Int SCoreR = 2;      //成功通关S-Core获得经验值
    --repeated S3Int LovePointR = 3;  //成功通关增加好感度
    --repeated S3Int FirstR = 4;      //首次成功通关奖励
    --repeated S3Int PerfectR = 5;    //首次三星通关奖励
    --repeated S3Int CommonR = 6;     //每次成功通关奖励
    --int32 Star = 7;                 //多少星
    --int32 StageID = 8;              //关卡ID
    --int32 IsWin = 9;                //输赢
    --repeated S3Int GiveBackR = 10;  //每次失败返还奖励
    --Formation Formation = 11;    //阵型
    --}
    finStageReply = stageReplyData
    GameSoundMgr.SetAutoMode(true)
    isInAutoStage = false
    UIMgr.SetCanRestoreHistory(false)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageReplyData.StageID)
    if stageReplyData.IsWin == 0 then
        if stageCfg.Type == Define.EStageType.Main then
            ChapterStageManager.CheckProChapter(stageReplyData)
        else
            ChapterStageManager.BackToMainHome()
        end
        return
    end
    if stageCfg.DramaAfter ~= 0 then
        GameStateMgr.Switch(GameState.MainStory, stageReplyData.StageID, false)
    else
        if stageCfg.Type == Define.EStageType.Main then
            ChapterStageManager.CheckProChapter(stageReplyData)
        elseif stageCfg.Type == Define.EStageType.SoulTrial then
            -- 深空试炼 检查当前是否为多关卡 且有下一关
            local nextStageId = BllMgr.GetSoulTrialBLL():GetNextStageIdInMultiLevel(stageReplyData.StageID)
            if nextStageId then
                BllMgr.GetFormationBLL():ReqDoMutiplyStage(nil, nextStageId)
            else
                ChapterStageManager.BackToMainHome()
            end
        else
            ChapterStageManager.BackToMainHome()
        end
    end
end
---@检测是否序章模式
function ChapterStageManager.CheckProChapter(stageReplyData)
    if BllMgr.GetChapterAndStageBLL():IsAutoNextStage() and BllMgr.GetChapterAndStageBLL():CanIntoAutoStage(stageReplyData.StageID) then
        if stageReplyData.IsWin == 0 then
            if BllMgr.GetChapterAndStageBLL():IsPrologueChapter() then
                ChapterStageManager.AgainStage(stageReplyData.StageID)
            else
                ChapterStageManager.BackToMainHome()
            end
        else
            isInAutoStage = true
            GameSoundMgr.SetAutoMode(false)
            if ChapterStageManager.GetBattleEnterOrEndShow(stageReplyData.StageID, 2) == Define.EndBattleShowType.NormalUI then
                local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageReplyData.StageID)
                local nextStageCfg = BllMgr.GetChapterAndStageBLL():GetNextStage(stageCfg)
                local loadingType = ChapterStageManager.GetStageLoadingType(nextStageCfg.ID)
                if GameStateMgr.GetCurStateName() == GameState.Battle then
                    UICommonUtil.SetLoadingEnableWithOpenParam({
                        MoveInCallBack = function()
                            UIMgr.Close("BattleResultWnd", false)
                            ChapterStageManager.UnLoadBattleAsset(function() BllMgr.GetChapterAndStageBLL():AutoStage(stageReplyData.StageID) end)
                        end,
                        IsPlayMoveOut = true
                    }, loadingType, true)
                else
                    UICommonUtil.SetLoadingEnableWithOpenParam({
                        MoveInCallBack = function()
                            BllMgr.GetChapterAndStageBLL():AutoStage(stageReplyData.StageID)
                        end,
                        IsPlayMoveOut = true
                    }, loadingType, true)
                end
            else
                BllMgr.GetChapterAndStageBLL():AutoStage(stageReplyData.StageID)
            end
        end
    else
        ChapterStageManager.BackToMainHome()
    end
end

---@判断是否开启序章
function ChapterStageManager.GetIsOpenPorStage()
    local sundryIsOpen = true
    local sundryCfg = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MAINLINESTORYGMSWITCH)
    if sundryCfg ~= nil then
        if sundryCfg == 0 then
            sundryIsOpen = false
        else
            sundryIsOpen = true
        end
    end
    return isOpenPorStage and sundryIsOpen
end
---@ 主要用于gm设置序章开启状态
function ChapterStageManager.SetIsOpenProStage(isOpen)
    isOpenPorStage = isOpen
end
---@判单是否开启主线界面
function ChapterStageManager.IsOpenChapterWnd()
    if isStageBackMainHome then
        ChapterStageManager.onStageBackMainHome(curStageId)
    end
    if stageGuideJumpFun ~= nil then
        stageGuideJumpFun()
    end
    stageGuideJumpFun = nil
    isStageBackMainHome = false
    finStageReply = nil
end
---@param stageID number
function ChapterStageManager.onStageBackMainHome(stageID)
    local curStageCfg = LuaCfgMgr.Get("CommonStageEntry", stageID)
    if curStageCfg.Type == Define.EStageType.Main then
        if not UIMgr.IsOpened(UIConf.MainLineChapterWnd) then
            UIMgr.OpenWithAnim(UIConf.MainLineChapterWnd,false, 3, finStageReply)
        end
    end
end
---@设置回到主界面后得回调
function ChapterStageManager.SetJumpFunc(func)
    stageGuideJumpFun = func
end
---@重置从主线回到主界面状态
function ChapterStageManager.ClearStageBackFlag()
    isStageBackMainHome = false
end

---@战斗结算再试一次接口
function ChapterStageManager.AgainStage(stageId)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg == nil then
        return
    end
    ChapterStageManager.GoToTeamEditor(stageCfg, stageCfg.Type)
end
---返回主界面时清理剧情UI部分
function ChapterStageManager.UnloadDialog()
    DialogueManager.GetDefaultDialogueSystem():ClearDialogue()
    if not BllMgr.GetChapterAndStageBLL():IsAutoNextStage() then
        UIMgr.Close(UIConf.SpecialDatePlayWnd)
    end
end
---@主线剧情相关内容
function ChapterStageManager.InitMainStory(stageId, isBefore)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg == nil then
        return
    end
    DialogueManager.GetDefaultDialogueSystem():CloseUIWhenEndDialogue(false)
    local dialogInfoId = 0
    if isBefore then
        dialogInfoId = stageCfg.DramaFront
    else
        dialogInfoId = stageCfg.DramaAfter
    end
    virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.AutoSyncMode)
    DialogueManager.GetDefaultDialogueSystem():InitAndAutoPlay(dialogInfoId, function()
        if isBefore then
            if stageCfg.SubType == Define.Enum_StageType.MovieStage then
                BllMgr.GetChapterAndStageBLL():SendFinStage(stageId)
            elseif stageCfg.SubType == Define.Enum_StageType.FightStage then
                ChapterStageManager.UnloadDialog()
                BllMgr.GetChapterAndStageBLL():OnMovieFinish(stageCfg, mFormationType)
            end
        else
            if BllMgr.GetChapterAndStageBLL():IsAutoNextStage() and BllMgr.GetChapterAndStageBLL():CanIntoAutoStage(stageId) then
                ChapterStageManager.UnloadDialog()
                GameSoundMgr.SetAutoMode(false)
                isInAutoStage = true
                BllMgr.GetChapterAndStageBLL():AutoStage(stageId)
            else
                isStageBackMainHome = true
                UICommonUtil.SetLoadingEnableWithOpenParam({
                    MoveInCallBack = function()
                        ChapterStageManager.UnloadDialog()
                        PreloadBatchMgr.UnloadHoldonNodes()
                        GameStateMgr.Switch(GameState.MainHome)
                    end
                }, GameConst.LoadingType.MainHome, true)
            end
        end
    end, BllMgr.GetHeadIconBLL():GetLoadingWeightAndProgress())
    if BllMgr.GetHeadIconBLL():IsShowLoading() then
        BllMgr.GetHeadIconBLL():EndLoading()
    end
    DialogueManager.GetDefaultDialogueSystem():GetSettingData():SetShowPauseButton(true)
    ---第一次通关时隐藏倍速播放功能
    if BllMgr.GetChapterAndStageBLL():StageIsUnLockById(stageId) then
        DialogueManager.GetDefaultDialogueSystem():GetSettingData():SetShowPlaySpeedButton(true)
    else
        DialogueManager.GetDefaultDialogueSystem():GetSettingData():SetShowPlaySpeedButton(false)
    end
    DialogueManager.GetDefaultDialogueSystem():GetSettingData():SetUseNodeGraph(true)
    DialogueManager.GetDefaultDialogueSystem():GetSettingData():SetAutoCloseWhiteScreen(true)
    DialogueManager.GetDefaultDialogueSystem():GetSettingData():SetShowPhotoButton(true)
    if isBefore then
        if BllMgr.GetChapterAndStageBLL():StageIsUnLockById(stageId) then
        else
        end
    else
        if BllMgr.GetChapterAndStageBLL():IsPlayDramaAfter(stageId) then
        else
            BllMgr.GetChapterAndStageBLL():SendSetDrama(stageId, dialogInfoId)
        end
    end
    if not BllMgr.GetChapterAndStageBLL():IsPrologueChapter() then
        DialogueManager.GetDefaultDialogueSystem():RegisterExitClickHandler(function()
            ChapterStageManager.ShowDialogQuitMessageBox(stageId, stageCfg.SubType == Define.Enum_StageType.MovieStage)
        end)
    end
    PerformanceLog.Begin(PerformanceLog.Tag.MainLine, stageId)
end
---@退出剧情MessageBox
function ChapterStageManager.ShowDialogQuitMessageBox(stageId, isSendCancelStage)
    UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_9023, {
        { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_text = UITextConst.UI_TEXT_5701, btn_call = function()
            GameSoundMgr.SetAutoMode(true)
            isInAutoStage = false
            if isSendCancelStage then
                BllMgr.GetChapterAndStageBLL():SendC2SCancelStage(stageId)
            else
                ChapterStageManager.BackToMainHome()
            end
            PerformanceLog.End(PerformanceLog.Tag.MainLine, stageId)
        end },
        { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_text = UITextConst.UI_TEXT_5702, btn_call = function()
            --DialogueManager.GetDefaultDialogueSystem():ResumeTime()
            DialogueManager.GetUIController():ResumeTime()
        end }
    })
end
---@退出剧情时的回调
function ChapterStageManager.FightMovieStage(finStageReplyData)
    finStageReply = finStageReplyData
    local stageId = finStageReplyData.Stage.StageID
    GameSoundMgr.SetAutoMode(true)
    isInAutoStage = false
    if BllMgr.GetChapterAndStageBLL():IsAutoNextStage() and BllMgr.GetChapterAndStageBLL():CanIntoAutoStage(stageId) then
        isInAutoStage = true
        ChapterStageManager.UnloadDialog()
        GameSoundMgr.SetAutoMode(false)
        BllMgr.GetChapterAndStageBLL():AutoStage(stageId)
    else
        isStageBackMainHome = true
        UICommonUtil.SetLoadingEnableWithOpenParam({
            MoveInCallBack = function()
                ChapterStageManager.UnloadDialog()
                PreloadBatchMgr.UnloadHoldonNodes()
                GameStateMgr.Switch(GameState.MainHome)
            end
        }, GameConst.LoadingType.MainHome, true)
    end
    local reward = ChapterStageManager.ScreenReward(finStageReplyData.FirstR)
    if #reward > 0 then
        local showRewardList, transRewardDic = BllMgr.GetItemBLL():GetShowRewardAndTransReward(finStageReplyData.FirstR)
        ErrandMgr.Add(X3_CFG_CONST.POPUP_MAINLINE_FIRSTREWARD, { showRewardList, transRewardDic, true })
    end
    PerformanceLog.End(PerformanceLog.Tag.MainLine, stageId)
end

function ChapterStageManager.ScreenReward(rewardList)
    local retTab = {}
    for k, v in pairs(rewardList) do
        if v.Type ~= 0 then
            local itemTypeCfg = LuaCfgMgr.Get("ItemType", v.Type)
            if itemTypeCfg ~= nil and itemTypeCfg.Display == 1 then
                table.insert(retTab, v)
            end
        else
            table.insert(retTab, v)
        end
    end
    return retTab
end

---@设置编队类型
function ChapterStageManager.SetFormationType(formationType)
    mFormationType = formationType
end
---@重置主线剧情状态
function ChapterStageManager.ResMainStory(isClose)
    if isClose == nil then
        isClose = true
    end
    ChapterStageManager.CloseDialogue(isClose)
end
---@退出主线剧情
function ChapterStageManager.CloseDialogue(isClose)
    if isClose then
        UIMgr.Close(UIConf.SpecialDatePlayWnd)
    end
    DialogueManager.GetDefaultDialogueSystem():CloseUIWhenEndDialogue(true)
    DialogueManager.GetDefaultDialogueSystem():ExitDialogue()
    DialogueManager.GetDefaultDialogueSystem():ClearDialogue()
    if virtualCamera ~= nil then
        GlobalCameraMgr.DestroyVirtualCamera(virtualCamera)
    end
end

---@根据关卡ID获取Loading类型
function ChapterStageManager.GetStageLoadingType(stageID)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageID)
    if stageCfg then
        return stageCfg.LoadingTypeID
    end
    return GameConst.LoadingType.Battle
end

---@检查当前关卡是否为多关卡战斗 如果是 额外返回一个当前关卡的Idx和总关卡数量
---@param stageId number 关卡Id
---@return number, number, number 是否为多关卡(0 不是 | 1 是), 当前关卡Idx, 总关卡数量
function ChapterStageManager:CheckIfBattleMultiLevel(stageId)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if not stageCfg then Debug.LogError("stageCfg not found, stageId : " .. tostring(stageId)) return 0, 0, 0 end
    if stageCfg.Type == Define.EStageType.SoulTrial then    -- 深空试炼多关卡处理
        local soulTrialId = BllMgr.GetSoulTrialBLL():GetSoulTrialIdByStageId(stageId)
        local isMulti = BllMgr.GetSoulTrialBLL():CheckIfLayerMultiLevel(soulTrialId)
        if isMulti then
            local curStageIdx, stageCount
            curStageIdx, stageCount = BllMgr.GetSoulTrialBLL():GetStageIndex(stageId)
            return 1, curStageIdx, stageCount
        end
    end

    return 0, 0, 0
end

---@设置获取战斗战前或战后显示类型
---@param stageId int  --关卡Id
---@param type int   --战前 1  战后 2  是否需要强制竖屏 3
---@param isWin bool   --是否获胜
---@return  int  --showType表演类型
function ChapterStageManager.GetBattleEnterOrEndShow(stageId, type)
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg == nil then
        return 0
    end
    local tempConditionTab = nil
    if type == 1 then
        tempConditionTab = stageCfg.BattleEnterShowType
    elseif type == 2 then
        tempConditionTab = stageCfg.BattleEndShowType
    elseif type == 3 then
        tempConditionTab = stageCfg.DirectionType
    end
    if tempConditionTab == nil then
        return 0
    end
    for i, v in ipairs(tempConditionTab) do
        if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(v.ID) then
            return v.Num
        end
    end
    return 0
end

---@是否在连播
function ChapterStageManager.GetIsInAutoStage()
    return isInAutoStage
end

---@连播中从编队退出
function ChapterStageManager.QuitFromTeamWnd()
    if isInAutoStage then
        GameSoundMgr.SetAutoMode(true)
        ChapterStageManager.BackToMainHome(true)
        isInAutoStage = false
        BllMgr.GetChapterAndStageBLL():CancelStage()
    end
end
---@退回到主界面
function ChapterStageManager.BackToMainHome(isQuitFromTeam)
    isStageBackMainHome = true
    if GameStateMgr.GetCurStateName() == GameState.Battle then
        UICommonUtil.SetLoadingEnableWithOpenParam({
            MoveInCallBack = function()
                ---战斗清除连播
                BllMgr.GetChapterAndStageBLL():CancelStage()
                UIMgr.Close("BattleResultWnd", false)
                ChapterStageManager.UnLoadBattleAsset(function()
                    PreloadBatchMgr.UnloadHoldonNodes()
                    GameStateMgr.Switch(GameState.MainHome) end)
            end
        }, GameConst.LoadingType.MainHome, true)
    else
        UICommonUtil.SetLoadingEnableWithOpenParam({
            MoveInCallBack = function()
                if isQuitFromTeam then
                    UIMgr.Close(UIConf.TeamWnd)
                end
                PreloadBatchMgr.UnloadHoldonNodes()
                GameStateMgr.Switch(GameState.MainHome)
            end
        }, GameConst.LoadingType.MainHome, true)
    end
end
---卸载战斗资源
function ChapterStageManager.UnLoadBattleAsset(callBack)
    if g_battleLauncher then
        g_battleLauncher:CleanupBattlefield(true, callBack)
    else
        callBack()
    end
end

---处理结算流程
function ChapterStageManager.ShowBattleResult(msg, callBack)
    local levelID = msg.StageID
    local levelCfg = LuaCfgMgr.Get("CommonStageEntry", levelID)
    local nextLevelCfg = BllMgr.GetChapterAndStageBLL():GetNextStage(levelCfg)
    local type = Define.EndBattleShowType.NormalUI
    local num = msg.IsWin
    local str = "失败:" .. tostring(num)
    if num == 1 then
        str = "胜利:" .. tostring(num)
        type = ChapterStageManager.GetBattleEnterOrEndShow(levelID, 2)
    end
    Debug.LogFormat("战斗流程：在线战斗结束:%s，开始ShowStatisticsUI, EndType:%d, levelID:%d", str, type, levelID)
    local isCallOk = false
    if type == Define.EndBattleShowType.NormalUI then
        Debug.Log("战斗流程：在线战斗结束，开始EndType表现，打开结算UI")
        local fun = function()
            -- 默认结算UI
            UIMgr.Open(UIConf.BattleResultWnd, msg)
        end
        isCallOk = XECS.XPCall(fun)
        if num == 1 then
            Debug.Log("战斗流程：播放战斗胜利音乐" .. TbUtil.battleConsts.SuccessBGMName)
            GameSoundMgr.PlayMusic(TbUtil.battleConsts.SuccessBGMName, true)
        else
            Debug.Log("战斗流程：播放战斗失败音乐" .. TbUtil.battleConsts.FailBGMName)
            GameSoundMgr.PlayMusic(TbUtil.battleConsts.FailBGMName, true)
        end
    elseif type == Define.EndBattleShowType.BlackScreenIn then
        Debug.Log("战斗流程：在线战斗结束，开始EndType表现，开始黑屏渐入")
        -- 黑屏渐入，结束后截屏
        local fun = function()
            UICommonUtil.BlackScreenIn(function()
                UICommonUtil.SetCaptureEnable(true, function()
                    if callBack then
                        callBack()
                    end
                end)
            end)
        end
        isCallOk = XECS.XPCall(fun)
    elseif type == Define.EndBattleShowType.WhiteScreenIn then
        Debug.Log("战斗流程：在线战斗结束，开始EndType表现，开始白屏渐入")
        -- 白屏渐入，结束后截屏
        local fun = function()
            UICommonUtil.WhiteScreenIn(function()
                UICommonUtil.SetCaptureEnable(true, function()
                    if callBack then
                        callBack()
                    end
                end)
            end)
        end
        isCallOk = XECS.XPCall(fun)
    elseif type == Define.EndBattleShowType.Loading then
        Debug.Log("战斗流程：在线战斗结束，开始EndType表现，直接起loading")
        -- 直接开启loading
        local fun = function()
            if (nextLevelCfg == nil) then
                Debug.Log("无下一关，配置有误")
            end
            local loadingType = ChapterStageManager.GetStageLoadingType(nextLevelCfg.ID)
            UICommonUtil.SetLoadingEnableWithOpenParam({
                MoveInCallBack = function()
                    if callBack then
                        callBack()
                    end
                end,
                IsPlayMoveOut = true
            }, loadingType, true)
        end
        isCallOk = XECS.XPCall(fun)
    elseif type == Define.EndBattleShowType.Nothing then
        Debug.Log("战斗流程：在线战斗结束，开始EndType表现，直接起loading")
        -- 直接开启loading
        local fun = function()
            UICommonUtil.SetLoadingEnableWithOpenParam({
                MoveInCallBack = function()
                    if callBack then
                        callBack()
                    end
                end,
                IsPlayMoveOut = true
            }, GameConst.LoadingType.MainHome, true)
        end
        isCallOk = XECS.XPCall(fun)
    elseif type == Define.EndBattleShowType.Battle then
        Debug.Log("战斗流程：在线战斗结束，开始EndType表现，无表现直接进入下一战斗")
        local fun = function()
            if (nextLevelCfg == nil) then
                Debug.Log("无下一关，配置有误")
            end
            local loadingType = ChapterStageManager.GetStageLoadingType(nextLevelCfg.ID)
            UICommonUtil.SetLoadingEnableWithOpenParam({
                MoveInCallBack = function()
                    if callBack then
                        callBack()
                    end
                end,
                IsPlayMoveOut = true
            }, loadingType, true)
        end
        isCallOk = XECS.XPCall(fun)
    end
    if not isCallOk then
        Debug.Log("战斗流程：在线战斗结束，EndType表现失败")
        -- 什么也不做,直接结束游戏
        if callBack then
            callBack()
        end
    end
end

---自动战斗状态相关
function ChapterStageManager.GetIsAutoBattleUnLock()
    return SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_AUTO)
end

function ChapterStageManager.GetAutoBattleState()
    local autoCfgValue = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.BATTLEAUTOSWITCH) == 1
    return PlayerPrefs.GetBool(string.format("AutoBattle_%s", SelfProxyFactory.GetPlayerInfoProxy():GetUid()), autoCfgValue)
end

function ChapterStageManager.SetAutoBattleState(isAuto)
    PlayerPrefs.SetBool(string.format("AutoBattle_%s", SelfProxyFactory.GetPlayerInfoProxy():GetUid()), isAuto)
end

function ChapterStageManager.GetAutoBattleLockTips()
    return SysUnLock.LockTips(X3_CFG_CONST.SYSTEM_UNLOCK_AUTO)
end

ChapterStageManager.Init()


return ChapterStageManager
