---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-05-29 20:25:43
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class TimerMgr
TimerMgr = {}
local cs_timer = CS.UnityEngine.Time
local cur_delta
local realtimeSinceStartup
local is_enter_game = false
local cur_date = {}
local Timer = require("Runtime.Common.Timer").new()
local ZONE_DIFF = 0
local serverOpenTime = 0
TimerMgr.UpdateType = Timer.UpdateType
local REAL_TIME_SINCE_START_UP = 0
local CUR_TIME_SECONDS = 0
local H_TIMES = 3600

---添加延时回调（忽略scale）
---@param delay number 单位是秒
---@param func function
---@param target table 如果有，调用func的时候就是冒号调用（可以访问方法中的self），如果没有就是点调用
---@param count boolean | number  如果是number的话，执行次数，-1或者true:无限次，>=1 执行count次数
---@param update_type number TimerMgr.UpdateType  1:update 2:lateupdate,3:fixupdate 默认1
---@param tag_name string 标签名称，用于调试
---@return int 用于取消注册的唯一id
function TimerMgr.AddTimer(delay, func, target, count, update_type, tag_name)
    return Timer:AddTimer(delay, func, target, count, update_type, false, tag_name)
end

---添加延时回调,考虑scale
---@param delay number 单位是秒
---@param func function
---@param target table 如果有，调用func的时候就是冒号调用（可以访问方法中的self），如果没有就是点调用
---@param count boolean | number  如果是number的话，执行次数，-1或者true:无限次，>=1 执行count次数
---@param update_type number TimerMgr.UpdateType  1:update 2:lateupdate,3:fixupdate 默认1
---@param tag_name string 标签名称，用于调试
---@return int 用于取消注册的唯一id
function TimerMgr.AddScaledTimer(delay, func, target, count, update_type, tag_name)
    return Timer:AddScaledTimer(delay, func, target, count, update_type, tag_name)
end

---取消延时回调
---@param timer_id number
function TimerMgr.Discard(timer_id)
    Timer:Discard(timer_id)
end

---根据绑定的target取消所有延时回调
---@param target table
function TimerMgr.DiscardTimerByTarget(target)
    Timer:DiscardTimerByTarget(target)
end

---延时帧调用
---@param frame_count int 几帧之后执行
---@param func function
---@param target table
---@param count int 执行次数
---@param update_type number TimerMgr.UpdateType  1:update 2:lateupdate,3:fixupdate 默认1
---@return int
function TimerMgr.AddTimerByFrame(frame_count, func, target, count, update_type)
    return Timer:AddTimer(frame_count, func, target, count, update_type, true)
end

---添加late update 回调
---@param func function
---@param target table
---@param tag_name string 标签名称，用于调试
---@return number
function TimerMgr.AddLateUpdate(func, target, tag_name)
    return Timer:AddLateUpdate(func, target, tag_name)
end

---
---清理计时器
---@param timer_id number
function TimerMgr.RemoveLateUpdate(timer_id)
    Timer:RemoveLateUpdate(timer_id)
end

---根据target 清理计时器
---@param target table
function TimerMgr.RemoveLateUpdateByTarget(target)
    Timer:RemoveLateUpdateByTarget(target)
end

---添加计时器
---@see TimerMgr.AddLateUpdate
function TimerMgr.AddFinalUpdate(func, target)
    return Timer:AddFinalUpdate(func, target)
end

---清理计时器
---@param timer_id int
function TimerMgr.RemoveFinalUpdate(timer_id)
    Timer:RemoveFinalUpdate(timer_id)
end

---根据对象清理
---@param target table
function TimerMgr.RemoveFinalUpdateByTarget(target)
    Timer:RemoveFinalUpdateByTarget(target)
end

---获取零时区时间戳
---@param date _date
---@return number
function TimerMgr.GetUnixTimestamp(date)
    return os.time(date) + ZONE_DIFF - TimerMgr.GetZoneTimestampOffset()
end

---根据零时区时间戳转换成当前服务器所在时区日期
---@param timestamp number
---@return _date
function TimerMgr.GetDateByUnixTimestamp(timestamp)
    if timestamp == nil then
        timestamp = os.time()
    end
    timestamp = timestamp + TimerMgr.GetZoneTimestampOffset()
    return os.date("!*t", math.max(math.floor(timestamp), 0))
end

---根据服务器下发的时间戳计算日期
---@param timestamp number
---@return _date
function TimerMgr.GetDateByServerTimestamp(timestamp)
    if timestamp == nil then
        timestamp = os.time()
    end
    ---早先和佳佳老师对的时候说服务器时间带时区，目前和毛豆老师确定下来服务器时间不带时区，因此去掉这个矫正
    --timestamp = timestamp - TimerMgr.GetZoneTimestampOffset()
    return TimerMgr.GetDateByUnixTimestamp(timestamp)
end

---获取时区
---@return number
function TimerMgr.GetTimeZone()
    if not GrpcMgr then
        return 0
    end
    return GrpcMgr.GetTimeZone() or 0
end

---获取服务器时区时间戳偏移量
function TimerMgr.GetZoneTimestampOffset()
    return TimerMgr.GetTimeZone() * H_TIMES
end

---获取当前时间戳（单位是秒）浮点数,服务器同步的时间戳
---返回的是unix的时间戳
---@return int
function TimerMgr.GetCurTimeSeconds()
    return math.floor(TimerMgr.GetRealTimeSeconds())
end

---@return float
function TimerMgr.GetRealTimeSeconds()
    return CUR_TIME_SECONDS + TimerMgr.RealtimeSinceStartup() - REAL_TIME_SINCE_START_UP
end

---@class _date
---@field month number 当前月
---@field day number 当前月天数
---@field hour number 当天小时
---@field min number 当前分
---@field sec number 当前秒
---@field wday number 当前星期
---@field yday number 当前已过天数
---@field year number 当前年
---@field isdst bool 是否是夏令时
---@return _date
function TimerMgr.GetCurDate(is_force)
    if not cur_date or is_force then
        cur_date = TimerMgr.GetDateByUnixTimestamp(TimerMgr.GetCurTimeSeconds())
        cur_date.wday = cur_date.wday - 1
    else
        local zone = TimerMgr.GetTimeZone()
        if not zone then
            return cur_date
        end
        local t = math.max(math.floor(TimerMgr.GetCurTimeSeconds() + TimerMgr.GetZoneTimestampOffset()), 0)
        cur_date.day = tonumber(os.date("!%d", t))
        cur_date.hour = tonumber(os.date("!%H", t))
        cur_date.min = tonumber(os.date("!%M", t))
        cur_date.sec = tonumber(os.date("!%S", t))
        cur_date.wday = tonumber(os.date("!%w", t))
        cur_date.year = tonumber(os.date("!%Y", t))
        cur_date.month = tonumber(os.date("!%m", t))
    end
    return cur_date
end

---获取RealtimeSinceStartup
---@param force boolean 是否需要强制校验
---@return float
function TimerMgr.RealtimeSinceStartup(force)
    if not realtimeSinceStartup or force then
        realtimeSinceStartup = CS.UnityEngine.Time.realtimeSinceStartup
    end
    return realtimeSinceStartup
end

---返回游戏当前帧数
---@return int
function TimerMgr.GetFrameCount()
    return GameMgr and GameMgr.GetFrameCount() or 0
end

---获取当前tick
---@param is_unscaled boolean
---@return number
function TimerMgr.GetCurTickDelta(is_unscaled)
    if not is_unscaled then
        return cur_delta
    end
    return cs_timer.unscaledDeltaTime
end

--- LateUpdate
---@param delta float
function TimerMgr.LateUpdate(delta)
    Timer:LateUpdate(delta)
end

---FinalUpdate
---@param delta float
function TimerMgr.FinalUpdate(delta)
    Timer:FinalUpdate(delta, realtimeSinceStartup)
end

---FixedUpdate
---@param delta float
function TimerMgr.FixedUpdate(delta)
    Timer:FixedUpdate(delta)
end

---unity生命周期update
---@param delta float
function TimerMgr.Update(delta, sinceStartup)
    cur_delta = delta
    realtimeSinceStartup = sinceStartup
    Timer:Update(delta)
end

---统一清理
---@private
function TimerMgr.Clear()
    Timer:Clear()
    TimerMgr.DiscardTimerByTarget(TimerMgr)
end

---@private
function TimerMgr.Destroy()
    TimerMgr.Clear()
end

local function Init()
    Timer:SetEngineTimer(TimerMgr)
    Timer:SetPool(PoolUtil.GetTable, PoolUtil.ReleaseTable)
    local now = os.time()
    ---获取系统是否启用夏令时 如果启用 zone_diff 增加一个小时
    local isdst = os.date("*t", now).isdst
    ZONE_DIFF = os.difftime(now, os.time(os.date("!*t", now))) + (isdst and H_TIMES or 0)
    TimerMgr.ForceSync()
end

---时区
---@return int
function TimerMgr.GetZoneDiff()
    return ZONE_DIFF
end

---进入游戏之后同步服务器时间
---@private
function TimerMgr.EnterGame()
    is_enter_game = true
    TimerMgr.ForceSync()
    EventMgr.Dispatch(Const.Event.TIME_REFRESH)
end

---Profiler
---@param name string
function TimerMgr.BeginSample(name)
    Profiler.BeginSample(name)
end

---结束profiler
function TimerMgr.EndSample(name)
    Profiler.EndSample(name)
end

---设置开服时间
---@param openTime number
function TimerMgr.SetServerOpenTime(openTime)
    serverOpenTime = openTime
end

---获取开服时间
---@return number
function TimerMgr.GetServerOpenTime()
    return serverOpenTime
end

---强制同步数据,禁止业务直接调用
---@private
function TimerMgr.ForceSync()
    if is_enter_game then
        CUR_TIME_SECONDS = GrpcMgr.GetServerTimeToUnixTimeSeconds()
    else
        CUR_TIME_SECONDS = os.time()
    end
    REAL_TIME_SINCE_START_UP = TimerMgr.RealtimeSinceStartup(true)
    TimerMgr.GetCurDate(true)
end

Init()
return TimerMgr