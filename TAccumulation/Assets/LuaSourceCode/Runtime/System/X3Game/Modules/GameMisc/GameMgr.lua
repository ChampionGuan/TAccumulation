--- X3@PapeGames
--- GameMgr
--- 本类用来作为获取引擎的各种事件或Update调用的入口
--- 事件更新的顺序依次为：Update -> LateUpdate -> FinalUpdate
--- Created by Tungway
--- Created Date: 2020/8/27
--- Updated by Tungway
--- Update Date: 2021/01/04

local gameGlobalHelper = require("Runtime.System.X3Game.Modules.GameMisc.GameGlobalHelper")

---@class GameMgr
local GameMgr = require("Runtime.System.X3Game.Modules.GameMisc.GameMgrForUpdate")
local CLS = CS.X3Game.GameMgr
---最后一次退到后台的时间
local lastApplicationBlurTime = 0
---最后一次切回游戏的时间
local lastApplicationFocusTime = 0
---是否在运行中
local isRunning = true
---是否失焦
local loseFocus = false
local focusTimerId = nil

---是否开始重启
local startReboot = false
---保底重启计时器
local safeRebootTimer = nil

---@return boolean
function GameMgr.IsRunning()
    return isRunning
end

---App获得或失去焦点
---focus bool 是否获得焦点
---@param focus boolean
function GameMgr:OnApplicationFocus(focus)
    if not UNITY_EDITOR then
        CriticalLog.Flush()
    end
    if focus == false then
        lastApplicationBlurTime = os.time()

        if (not loseFocus) then
            EventMgr.Dispatch("Game_Focus", false)
            -- 数据埋点 切换后台（非安卓）
            if (Application.GetPlatform() ~= CS.UnityEngine.RuntimePlatform.Android) then
                EventTraceMgr:Trace(EventTraceEnum.EventType.SwitchBackground)
            end
        end
        loseFocus = true
        PlayerPrefs.Save()
    else
        ---精度误差为秒，累计误差不可估量
        lastApplicationFocusTime = os.time()
        if (focusTimerId) then
            TimerMgr.Discard(focusTimerId)
            focusTimerId = nil
        end

        focusTimerId = TimerMgr.AddTimerByFrame(1, function()
            loseFocus = false
            EventMgr.Dispatch("Game_Focus", true)
            -- 数据埋点 切换前台（非安卓）
            if (Application.GetPlatform() ~= CS.UnityEngine.RuntimePlatform.Android) then
                EventTraceMgr:Trace(EventTraceEnum.EventType.SwitchFrontdesk)
            end
            focusTimerId = nil;
        end)
    end
end

function GameMgr:OnApplicationPause(pauseStatus)
    EventMgr.Dispatch("Game_Pause", pauseStatus)
    -- 数据埋点 切换前后台 (安卓)
    if (Application.GetPlatform() == CS.UnityEngine.RuntimePlatform.Android) then
        EventTraceMgr:Trace(pauseStatus and EventTraceEnum.EventType.SwitchBackground or EventTraceEnum.EventType.SwitchFrontdesk)
    end
end

---内存较低时此函数被触发
function GameMgr:OnLowMemory()
end

---App退出
function GameMgr:OnApplicationQuit()
    PlayerPrefs.Save()
    EventMgr.Dispatch("Game_Quit")
    if DialogueManager then
        DialogueManager.Clear()
    end
    if ShaderWarmupMgr then
        ShaderWarmupMgr.StopWarmup()
    end
end

---开始run
function GameMgr:OnStartRun()
    isRunning = true
end

---结束run
function GameMgr:OnStopRun()
    isRunning = false
end

---游戏重启
function GameMgr.ReInitGlobal()
    gameGlobalHelper.ReInitGlobal()
end

---获取最后一次退到后台的时间
---@return float
function GameMgr.GetLastApplicationBlurTime()
    return lastApplicationBlurTime
end

---获取最后一次返回前台的时间
---@return float
function GameMgr.GetLastApplicationFocusTime()
    return lastApplicationFocusTime
end

---获取Fps
---@return int
function GameMgr.GetFps()
    return CLS.Fps
end

---获取StreamingAssetsData目录
---@return string
function GameMgr.GetStreamingAssetsData()
    return CLS.StreamingAssetsGameData
end

function GameMgr:InitDelegate()
    CLS.SetDelegate(self)
end

---注册清理
---@param clearFunc function
---@param initFunc function
function GameMgr.RegisterClear(clearFunc, initFunc)
    gameGlobalHelper.RegisterClear(clearFunc, initFunc)
end

---根据类型初始化全局变量
---@param globalType string
function GameMgr.InitGlobal(globalType)
    gameGlobalHelper.InitGlobal(globalType)
end

---等待资源加载完成
---@param globalType string
function GameMgr.WaitAssetLoadFinished(callback)
    CLS.WaitAssetLoadFinished(callback)
end

---重启
---@param isPatchReboot boolean 是否热更新
---@param finishState string 重启完成后调用的state
---@param needLoading boolean 是否需要Loading
---@param forceReloadLua boolean 是否需要重新加载lua
function GameMgr.ReStart(isPatchReboot, finishState, needLoading, forceReloadLua)
    CriticalLog.Log("GameMgr.Restart begin")
    EventMgr.Dispatch(Const.Event.GAME_RESTART_BEGIN)

    ---切换到空场景
    Res.LoadScene("Empty")
    
    ---提前清理CTS缓存,防止动卡背景使用缓存实例
    CutSceneMgr.RemoveAllAssetInsPermanently()
    ---清理所有的MessageBox和Indicator
    UICommonUtil.Clear()
    ---清理所有界面,保证视频界面必然被打开且显示
    UIMgr.ClearAllPanels()
    ---清理队列中的所有界面, 确保loading后, 不会有其他界面弹出
    ErrandMgr.Clear()
    ---提前设置所有加载模式为false, 避免X3AssetInsProvider清理过程中误删除
    Res.SetABUnloadParameter(false)

    ---如果需要loading, 确保loading先打开
    if needLoading then
        UICommonUtil.SetLoadingEnable(false)
        UICommonUtil.SetLoadingEnableWithOpenParam({ IsFullScreen = false }, GameConst.LoadingType.Common, true)
    end
    
    startReboot = false
    ---保底逻辑，等待5s后直接开始重启
    safeRebootTimer = TimerMgr.AddTimer(5 , function()
        Debug.LogError("保底逻辑重启，请检查三段式动画是否没有播放完成")
        GameMgr.StartReboot(isPatchReboot, finishState, forceReloadLua)
    end)
    
    ---先确保所有三段动画能执行完成
    DynamicCardMgr.SetAllMotionCompleteCb(function()
        GameMgr.StartReboot(isPatchReboot, finishState, forceReloadLua)
    end)
end

function GameMgr.StartReboot(isPatchReboot, finishState, forceReloadLua)
    if not startReboot then
        startReboot = true
        TimerMgr.Discard(safeRebootTimer)
        CriticalLog.Log("GameMgr.Restart: WaitAssetLoadFinished")
        ---先等待正在加载的资源加载完成
        GameMgr.WaitAssetLoadFinished(function()
            CriticalLog.Log("GameMgr.Restart: RebootResUnload")
            ---再确保所有资源卸载完成，再重启
            CLS.RebootResUnload(isPatchReboot , function()
                Res.UnloadUnusedLoaders()
                UIMgr.SetPortraitMode(function()
                    CriticalLog.Log("GameMgr.Restart end")
                    GameStateMgr.Switch(GameState.Entry, isPatchReboot, finishState, forceReloadLua)
                end)
            end)
        end)
    end
end

---设置游戏重启状态
function GameMgr.SetGameReboot(reboot)
    CLS.SetGameReboot(reboot)
end

---GlobalLua的Clear
function GameMgr.ClearAllGlobalLua()
    gameGlobalHelper.ClearAllGlobalLua()
end

---GlobalLua的Destroy
function GameMgr.DestroyAllGlobalLua()
    gameGlobalHelper.DestroyAllGlobalLua()
end

return GameMgr