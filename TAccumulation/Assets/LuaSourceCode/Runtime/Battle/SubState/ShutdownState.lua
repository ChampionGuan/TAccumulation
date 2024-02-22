﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2024/1/30 18:51
---

local CSUnityEngine = CS.UnityEngine
local CSLoadSceneMode = CSUnityEngine.SceneManagement.LoadSceneMode
local CSQualitySettings = CSUnityEngine.QualitySettings
local CSGameObject = CSUnityEngine.GameObject
local CSTime = CSUnityEngine.Time
local CSApplication = CSUnityEngine.Application
local CSPhysics = CSUnityEngine.Physics
local CSX3Battle = CS.X3Battle
local CSBattle = CSX3Battle.Battle
local CSBattleClient = CSX3Battle.BattleClient
local CSBattleRunStatus = CSX3Battle.BattleRunStatus
local CSBattleResMgr = CSX3Battle.BattleResMgr
local CSXResources = CS.XAssetsManager.XResources
local CSX3AssetInsProvider = CS.PapeGames.X3.X3AssetInsProvider
local CSPreloadBatchMgr = CS.X3Game.PreloadBatchMgr

local BaseState = require("Runtime.Battle.Common.SimpleStateMachine").BaseState
local BattleSVC = require("Runtime.Battle.BattleSVC")

---战斗退出状态
---@class BattleShutdownState:BaseState
---@field context BattleLauncher
local ShutdownState = XECS.class("ShutdownState", BaseState)

function ShutdownState:CanEnter(prevState)
    return prevState == nil or prevState == self.context.inBattleState or prevState == self.context.settlementState
end

---@param shutdownType BattleShutdownType 战斗退出的方式，不同方式走不同流程
function ShutdownState:OnEnter(prevState, shutdownType, param1, param2)
    self._isWorking = true
    self._csBattle = CSBattle.Instance
    self._csBattleClient = CSBattleClient.Instance

    if shutdownType == BattleShutdownType.CleanupBattlefield then
        --- 清理战场（param1参数为是否用协程，param2参数为清理完成的回调函数）
        self:_CleanupBattlefield(param1, function()
            XECS.XPCall(param2)
            self:_Finished()
        end)
    elseif shutdownType == BattleShutdownType.AftSettlement then
        --- 结算状态后（param1参数为结算协议）    
        self:_AftBattleSettlement(param1, handler(self, self._Finished)) --- 退出战斗主态
    elseif shutdownType == BattleShutdownType.ExitMainState then
        --- 退出战斗主状态
        self:_ExitBattleGameState(handler(self, self._Finished))
    else
        --- 其他
        self:_Finished()
    end
end

function ShutdownState:CanExit(nextState)
    return not self._isWorking
end

function ShutdownState:OnExit(nextState)
    self._csBattle = nil
    self._csBattleClient = nil
end

---战斗结算之后的退出流程
---@param msg pbcmessage.FinStageReply
function ShutdownState:_AftBattleSettlement(msg, onCompleteFunc)
    CriticalLog.Log("[战斗][退出流程][ShutdownState._AftBattleSettlement()] 来自结算状态后，开始退出战斗！！")

    local battleArg = self._csBattle.arg
    local cleanupCompleteFunc = function()
        if battleArg.startupType == BattleStartupType.Online then
            ---当前为在线战斗
            if msg == nil then
                Debug.LogErrorFormat("缺少正确的结算数据,无法退出战斗状态")
                return
            end
            --Debug.Log("战斗流程：在线，准备退出战斗状态，开始章节结算。非结算UI的方式")
            ChapterStageManager.EndBattle(msg)
            --- 完全结束时清除PPV2的暗角
            UICommonUtil.ScreenTransitionClear(true)
        else
            -- Rogue 白盒测试代码.
            if battleArg.gameplayType == CS.X3Battle.BattleGameplayType.Rogue then
                local battleTest = require("Runtime.Battle.BattleTest")
                battleTest:ExitBattleGameplayHandle(battleArg)
                return
            end

            local fromState = battleArg.fromGameState
            -- 主线通过离线面版启动战斗，然后点击重新战斗，在放弃战斗。此时强制切换到登录状态
            if battleArg.startupType == BattleStartupType.OfflineQuickBattle and fromState == GameState.Battle then
                fromState = GameState.Login
            end

            GameStateMgr.Switch(fromState)
        end

        XECS.XPCall(onCompleteFunc)
        CriticalLog.Log("[战斗][退出流程][ShutdownState._AftBattleSettlement()] 结算后的退出战斗流程结束！！")
    end

    -- 开始清理战场
    self:_CleanupBattlefield(true, cleanupCompleteFunc)
end

---退出战斗游戏态下的退出流程
function ShutdownState:_ExitBattleGameState(onCompleteFunc)
    CriticalLog.Log("[战斗][退出流程][ShutdownState._ExitBattleGameState()] 退出了战斗主状态，开始发起战斗退出流程，准备发起竖屏切换！！")

    local cleanupCompleteFunc = function()
        BattleUtil:TryBattleMemorySnapShot(4)
        UIMgr.Open(UIConf.InputEffectWnd)

        XECS.XPCall(onCompleteFunc)
        CriticalLog.Log("[战斗][退出流程][ShutdownState._ExitBattleGameState()] 退出战斗主状态完成！！")
    end

    local portraitModeCompleteFunc = function()
        self:_CleanupBattlefield(false, cleanupCompleteFunc)
    end

    --- 切换到竖屏模式
    UIMgr.SetPortraitMode(portraitModeCompleteFunc)
end

--- 清理战场（销毁战斗实例，卸载战斗资源，恢复系统和游戏设置）
---@param isCoroutine bool 是否是以协程的方式
---@param onCompleteFunc function 清理完成后的回调
function ShutdownState:_CleanupBattlefield(isCoroutine, onCompleteFunc)
    --- 判断战斗是否已销毁
    if not self._csBattleClient then
        XECS.XPCall(onCompleteFunc)
        return
    end

    CriticalLog.Log("[战斗][退出流程][ShutdownState._CleanupBattlefield()] 开始准备清理战场（卸资源，销毁实例等）！！")
    if isCoroutine then
        BattleUtil.StartCoroutine(self._ToDestroyBattle, self, onCompleteFunc, true)
    else
        self:_ToDestroyBattle(onCompleteFunc, false)
    end
end

--- 销毁战斗
function ShutdownState:_ToDestroyBattle(onCompleteFunc, isCoroutine)
    CriticalLog.Log("[战斗][退出流程][ShutdownState._DestroyBattle()] 开始销毁战斗实例，卸载资源等！")

    --- 上传防作弊日志
    self:_UploadCheatFile()
    --- 连战下一关背景音
    self:_PlayMultilevelBgMusic()

    --- 卸载SVC
    BattleSVC:Unload()
    --- 卸载预加载的资源
    if self.context._preloadBatchID then
        XECS.XPCall(PreloadBatchMgr.Unload, self.context._preloadBatchID)
        self.context._preloadBatchID = nil
    end

    -- 此处不能删，必须要延迟一帧清理战斗逻辑
    if isCoroutine then
        coroutine.yield(nil)
    end
    --- 退出并销毁战斗逻辑
    self._csBattleClient:Shutdown()
    CSGameObject.Destroy(self._csBattleClient.gameObject)
    self._csBattleClient = nil
    self._csBattle = nil

    --- 卸载配置等资源
    TbUtil.UnInit()
    X3AssetInsProvider.DestroyPoolAllLifeMode()

    if isCoroutine then
        coroutine.yield(nil)
        coroutine.yield(nil)
    end
    Res.LoadScene("Loading", CSLoadSceneMode.Single)

    if isCoroutine then
        coroutine.yield(nil)
        coroutine.yield(nil)
    end
    --- 清理内存
    BattleUtil:ClearMemory()
    --- 恢复系统和游戏设置
    self:_ResetGameSetting()

    if isCoroutine then
        coroutine.yield(CSUnityEngine.WaitForSeconds(0.5))
    end

    CriticalLog.Log("[战斗][退出流程][ShutdownState._DestroyBattle()] 战斗实例销毁，资源卸载完成！")
    XECS.XPCall(onCompleteFunc)
end

---上传防作弊日志
function ShutdownState:_UploadCheatFile()
    local cheatStatistics = self._csBattle.cheatStatistics
    if not cheatStatistics:GetIsUp() then
        return
    end
    local formationStr = self.context._formationStr
    if not formationStr then
        return
    end

    CriticalLog.Log("[战斗][退出流程][ShutdownState.UpCheatFile()] 上传防作弊日志！")
    self.context._formationStr = nil
    cheatStatistics:WriteOssFile(BattleUtil.GetOSSInfoData(formationStr))
end

---下一场战斗背景音
function ShutdownState:_PlayMultilevelBgMusic()
    if self._csBattle.status ~= CSBattleRunStatus.Success then
        return
    end

    local stageID = self._csBattle.arg.commonStageId
    if ChapterStageManager:CheckIfBattleMultiLevel(stageID) ~= 1 then
        return
    end

    if BllMgr.GetSoulTrialBLL():GetCfg_SoulTrial_MissionId(stageID) == nil then
        return
    end

    local nextStageId = BllMgr.GetSoulTrialBLL():GetNextStageIdInMultiLevel(stageID)
    if not nextStageId then
        return
    end

    local levelConfig = BattleUtil.GetBattleLevelConfig(nextStageId)
    if not levelConfig then
        return
    end

    local toPlay = function(musicName)
        ---这里等待一帧的原因时，同一个bank不能在同帧卸载和加载
        coroutine.yield(nil)

        WwiseMgr.LoadBankWithEventName(TbUtil.battleConsts.BGMEventName, false)
        GameSoundMgr.StopMusic()
        GameSoundMgr.PlayMusic(musicName, true)
        --Debug.LogFormat("战斗流程：深空连战播放背景音乐 = " .. levelConfig.musicName)
    end

    BattleUtil.StartCoroutine(toPlay, levelConfig.BackgroundMusic)
end

--- 退出战斗时的一些游戏设置恢复
---（在战斗实例销毁，战斗资源卸载后调用！）
function ShutdownState:_ResetGameSetting()
    ---恢复系统和游戏设置
    CSQualitySettings.streamingMipmapsActive = self.context._mainlineStreamingActive
    CSQualitySettings.streamingMipmapsMemoryBudget = self.context._mainlineStreamingBudget
    BattleUtil.EnableFSR(self.context._originalFsrEnableState)
    CSApplication.targetFrameRate = self.context._prevFrameRate
    CSTime.fixedDeltaTime = self.context._fixedDeltaTime
    CSPhysics.autoSyncTransforms = self.context._prevAutoSyncTransforms
    CSPhysics.autoSimulation = self.context._prevAutoSimulation
    CSXResources.PauseTick = self.context._preXResourcesPauseTick
    CSX3AssetInsProvider.Instance.TickEnable = self.context._x3AssetInsProviderTickEnable
    BattleUtil.SetEnergySavingModel(self.context._curEnergySavingModel)
    GameHelper.SetMultiTouchEnable(false, GameConst.MultiTouchLockType.Battle)
    CSPreloadBatchMgr.loadingCntPerFrame = self.context._preLoadingCntPerFrame

    ---关闭：战斗中加载资源时，打印错误日志
    CSBattleResMgr.isDynamicLoadErring = false
    ---关闭：非战斗resMgr模块内，加载行为发生时是否打印错误日志,例如武器部件，UI依赖的材质资源
    CSBattleResMgr.isDynamicBottomLoadErring = false
end

function ShutdownState:_Finished()
    XECS.XPCall(self._onShutdownCompleted)
    self._onShutdownCompleted = nil

    self._isWorking = false
    self.stateMachine:Switch(nil)
end

return ShutdownState