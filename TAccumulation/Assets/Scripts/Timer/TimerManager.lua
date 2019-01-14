TimerManager = {}
-- 计时器
local Timer = LuaHandle.load("Timer.Timer")
-- 计时器
local BusTimer = LuaHandle.load("Timer.BusTimer")
-- 延时管理中心
local DelayToDoCenter = LuaHandle.load("Timer.DelayToDo")

-- 计时器池
local timerPool = {}
-- 当前帧时间
local theCurrRealtime = 0
-- 上一帧时间
local theLastRealtime = CSharp.Time.realtimeSinceStartup
-- 计时器池--
local TimeNormalCenter = setmetatable({}, {__mode = "k"})
local TimeIgnoreCenter = setmetatable({}, {__mode = "k"})

-- deltaTime
TimerManager.deltaTime = 0
TimerManager.ignoreDeltaTime = 0
TimerManager.fixedDeltaTime = CSharp.Time.fixedDeltaTime

-- 当前服务器时间
TimerManager.curServerTimestamp = os.time()
-- 客户端当前时区与服务器保持一致（约定）
-- os.difftime(TimerManager.curServerTimestamp, os.time(os.date("!*t", TimerManager.curServerTimestamp)))
TimerManager.clientTimeZone = 28800
-- 客户端与服务器时区差（约定）
-- 服务器东八区，客户端东七区，此值为3600
TimerManager.clientDifftime = 0
-- 客户端每日重置时间
TimerManager.clientDailyResetTime = "00:00"
-- 与服务器的Ping值
TimerManager.ping = 0

-- 正常计时--
local function timeNormalUpdate()
    if TimeNormalCenter == nil then
        return
    end
    for k, v in pairs(TimeNormalCenter) do
        if v ~= nil then
            v:update(TimerManager.fixedDeltaTime)
        end
    end
end

-- 忽略timeScaler计时--
local function timeIgnoreUpdate(f)
    if TimeIgnoreCenter == nil then
        return
    end
    for k, v in pairs(TimeIgnoreCenter) do
        if v ~= nil then
            v:update(f)
        end
    end
end

-- 添加计时器--
local function addTimer(t, isIgnoreTimeScale)
    if isIgnoreTimeScale then
        TimeIgnoreCenter[t.InstanceId] = t
    else
        TimeNormalCenter[t.InstanceId] = t
    end
end

-- 更新服务器时间
local function updateServerTimestamp(serverTime, ping)
    TimerManager.curServerTimestamp = serverTime
    TimerManager.ping = ping
end
Event.addListener(Event.UPDATE_SERVER_TIME, updateServerTimestamp)

-- 移除计时器--
local function removeTimer(id, isIgnoreTimeScale)
    if isIgnoreTimeScale then
        TimeIgnoreCenter[id] = nil
    else
        TimeNormalCenter[id] = nil
    end
end
-- 初始化--
function TimerManager.initialize()
end

-- 更新
function TimerManager.update()
    -- 忽略timeScaler
    theCurrRealtime = CSharp.Time.realtimeSinceStartup
    TimerManager.ignoreDeltaTime = theCurrRealtime - theLastRealtime
    theLastRealtime = theCurrRealtime
    timeIgnoreUpdate(TimerManager.ignoreDeltaTime)

    TimerManager.deltaTime = CSharp.Time.deltaTime
    TimerManager.curServerTimestamp = TimerManager.curServerTimestamp + TimerManager.deltaTime

    -- 公交计时
    BusTimer.update()
end

-- 固定更新
function TimerManager.fixedUpdate()
    timeNormalUpdate()
end

-- 实例化新计时器--
-- <param name="maxCd" type="numble">时间</param>
-- <param name="isAutoReset" type="boolen">自动重置，如为True,则结束计时时，会自动重置并重新启动计时</param>
-- <param name="isIgnoreTimeScale" type="boolean">是否忽略timescaler</param>
-- <param name="funcStart" type="function">传入计时开始回调</param>
-- <param name="funcUpdate" type="function">传入计时进行回调</param>
-- <param name="funcComplete" type="function">传入计时结束回调</param>
-- <param name="funcHost" type="table">传入回调宿主，self</param>
-- <param name="isAscend" type="bool">是否为正序计时，默认为倒计时</param>
-- <returns> Timer </returns>
function TimerManager.newTimer(
    maxCd,
    isAutoReset,
    isIgnoreTimeScale,
    funcStart,
    funcUpdate,
    funcComplete,
    funcHost,
    isAscend)
    local t = table.remove(timerPool, 1)
    if nil ~= t then
        -- 检测是否已包含
        removeTimer(t.InstanceId, t.IsIgnoreTimeScale)
        -- 初始化
        t:init(maxCd, isAutoReset, isIgnoreTimeScale, funcStart, funcUpdate, funcComplete, funcHost, isAscend)
    else
        t = Timer(maxCd, isAutoReset, isIgnoreTimeScale, funcStart, funcUpdate, funcComplete, funcHost, isAscend)
    end
    addTimer(t, isIgnoreTimeScale)
    return t
end

-- 公车短途计时器（只有结束回调）--
-- <param name="maxCd" type="numble">时间</param>
-- <param name="action" type="table">到站回调</param>
-- <returns> ShortTime </returns>
function TimerManager.busTimer(maxCd, action)
    return BusTimer.addEvent(maxCd, action)
end

-- 延时执行--
-- <param name="maxCd" type="numble">时间</param>
-- <param name="speedRate" type="numble">计时速率</param>
-- <param name="isIgnoreTimeScale" type="boolean">是否忽略timescaler</param>
-- <param name="func" type="function">传入回调方法</param>
-- <param name="params" type="function">传入回调参数</param>
-- <param name="funcHost" type="table">传入回调宿主</param>
-- <returns> DelayToDo </returns>
function TimerManager.waitTodo(maxCd, speedRate, isIgnoreTimeScale, func, params, funcHost)
    return DelayToDoCenter.newTimer(maxCd, speedRate, isIgnoreTimeScale, func, params, funcHost)
end

--- 析构指定计时器---
-- <param name="timer" type="timer">计时器实例化</param>
function TimerManager.disposeTimer(timer)
    if timer ~= nil and nil ~= timer.InstanceId then
        removeTimer(timer.InstanceId, timer.IsIgnoreTimeScale)
        timer:recycle()
        table.insert(timerPool, timer)
    end
    return nil
end

--- 析构指定延时执行---
-- <param name="timer" type="timer">计时器实例化</param>
function TimerManager.disposeDelayToDo(delayTodo)
    DelayToDoCenter.dispose(delayTodo)
    return nil
end

--- 服务器的每日重置秒数
function TimerManager.serverDailyResetSec()
    local commonConfig = DataTrunk.ConfigInfo.MiscCommonConfig.Config
    return commonConfig.DailyResetHour * 3600 + commonConfig.DailyResetMinute * 60
end

--- 获取距每日重置的剩余时间---
function TimerManager.getResetTimeLeft()
    local commonConfig = DataTrunk.ConfigInfo.MiscCommonConfig.Config
    local resetHour, resetMin =
        commonConfig.DailyResetHour + TimerManager.clientDifftime / 3600,
        commonConfig.DailyResetMinute

    -- 当前客户端时间
    local tab = os.date("!*t", TimerManager.curServerTimestamp + TimerManager.clientTimeZone)
    return (24 + resetHour) * 3600 + resetMin * 60 - (tab.hour * 3600 + tab.min * 60 + tab.sec)
end

--- 获取此时客户端带时区时间戳---
function TimerManager.getCurClientTimestamp()
    return TimerManager.curServerTimestamp + TimerManager.clientTimeZone
end

--- 获取此时客户端带时区时间---
function TimerManager.getCurClientTimeTab()
    -- year = tab.year,
    -- month = tab.month,
    -- day = tab.day,
    -- hour = tab.hour,
    -- min = tab.min,
    -- sec = tab.sec
    return os.date("!*t", TimerManager.getCurClientTimestamp())
end

-- 获取客户端今日零时时间戳
function TimerManager.getClientTodayZeroTimestamp()
    local curTime = TimerManager.getCurClientTimeTab()
    return os.time(
        {
            year = curTime.year,
            month = curTime.month,
            day = curTime.day,
            hour = 0,
            min = 0,
            sec = 0
        }
    )
end

-- 获取客户端显示，时间戳转换(时:分)
function TimerManager.getClientTime_HM(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return Localization.None
    end
    return os.date("!%H:%M", timestamp + TimerManager.clientTimeZone)
end

-- 获取客户端显示，时间戳转换(时:分:秒)
function TimerManager.getClientTime_HMS(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return Localization.None
    end
    return os.date("!%H:%M:%S", timestamp + TimerManager.clientTimeZone)
end

-- 获取客户端显示，时间戳转换(年-月-日 小时:分钟)
function TimerManager.getClientTime_YMDHM(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return Localization.None
    end
    return os.date("!%Y-%m-%d %H:%M", timestamp + TimerManager.clientTimeZone)
end

-- 获取客户端显示，时间戳转换(年-月-日)
function TimerManager.getClientTime_YMD(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return Localization.None
    end
    return os.date("!%Y-%m-%d", timestamp + TimerManager.clientTimeZone)
end

-- 获取客户端显示，时间戳转换(年-月-日 小时:分钟:秒)
function TimerManager.getClientTime_YMDHMS(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return Localization.None
    end
    return os.date("!%Y-%m-%d %H:%M:%S", timestamp + TimerManager.clientTimeZone)
end

-- 获取客户端显示，时间戳转换自定义
function TimerManager.getClientTime_Custom(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return Localization.None
    end
    local tab = os.date("!*t", timestamp + TimerManager.clientTimeZone)
    return string.format(Localization.Time, tab.year, tab.month, tab.day, tab.hour, tab.min)
end

-- 获取客户端显示，时间戳转周
function TimerManager.getClientWeekend(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return ""
    end
    
    return Localization["TodayIs_" .. os.date("!%w", timestamp + TimerManager.clientTimeZone)]
end

-- 根据小时分钟获取日期
-- 如：周三 15:00
function TimerManager.getWeekendNameByHourAndMinite(hour, min)
    if hour == nil or type(hour) ~= "number" or min == nil or type(min) ~= "number" then
        return ""
    end

    return Localization["TodayIs_" .. hour % 24] .. " " .. os.date("!%H:%M", hour * 3600 + min * 60)
end
