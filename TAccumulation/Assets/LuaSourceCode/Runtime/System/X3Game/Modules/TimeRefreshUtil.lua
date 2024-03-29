﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/2/25 15:25
---

---
---@class TimeRefreshUtil
local TimeRefreshUtil = class("TimeRefreshUtil")
local CS_DateTimeOffset = CS.System.DateTimeOffset
local CS_TimeSpan = CS.System.TimeSpan

---@type int 每日刷新时间(时）
local dailyResetHour = 5
---@type int 每日刷新时间(分）
local dailyResetMinute = 0
---@type int 每日刷新时间(秒）
local dailyResetSecond = 0

local function Init()
    local resetString = string.split(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.COMMONDAILYRESETTIME), ":")
    dailyResetHour = tonumber(resetString[1])
    dailyResetMinute = tonumber(resetString[2])
    dailyResetSecond = tonumber(resetString[3])
end

---0 // 不会定时刷新
---1 // 每日固定时间点（5点）重置
---2 // 每周固定时间点（周一5点）重置
---3 // 每月固定时间点（1日5点）重置
---4 // 每年固定时间点（1月1日5点）重置
---5 // 每周特定时间重置, 参数:周X=hh:mm:ss,多个用|分割，例：1=14:00:00|3=19:00:00
---6 // 特定时间重置, 参数:年月日=hh:mm:ss,多个用|分割,年月日为0标识每年/每月/每日,例:601=14:00:00|1230=19:00:00
---7 // 间隔指定时间后刷新,参数hh:mm:ss 例:2:00:00表示间隔2小时后刷新
---根据配置类型和上次刷新时间获得下次数据刷新的时间戳（带时区）
---@param type Define.DateRefreshType 刷新类型
---@param lastRefreshTime int 上次刷新时间
---@return int
function TimeRefreshUtil.GetNextRefreshTime(lastRefreshTime, type, detail)
    if type == Define.DateRefreshType.None then
        return 0
    end
    local nextRefreshTime = 0
    local lastTimeOffset = CS_DateTimeOffset.FromUnixTimeSeconds(lastRefreshTime)
    lastTimeOffset = lastTimeOffset:ToOffset(CS_TimeSpan(TimerMgr.GetTimeZone(), 0, 0))
    local nextRefreshTimeOffset = nil
    if type == Define.DateRefreshType.Day then
        --5:00~次日5:00为一个刷新时间段，如果在0：00~4:59就统一减去一天当做上一个刷新周期
        if lastTimeOffset.Hour < dailyResetHour then
            lastTimeOffset = lastTimeOffset:AddHours(-dailyResetHour)
        end
        nextRefreshTimeOffset = lastTimeOffset:AddDays(1)
        nextRefreshTimeOffset = CS_DateTimeOffset(nextRefreshTimeOffset.Year, nextRefreshTimeOffset.Month, nextRefreshTimeOffset.Day, dailyResetHour, dailyResetMinute, dailyResetSecond, nextRefreshTimeOffset.Offset)
    elseif type == Define.DateRefreshType.Week then
        --5:00~次日5:00为一个刷新时间段，如果在0：00~4:59就统一减去一天当做上一个刷新周期
        if lastTimeOffset.Hour < dailyResetHour then
            lastTimeOffset = lastTimeOffset:AddHours(-dailyResetHour)
        end
        nextRefreshTimeOffset = lastTimeOffset:AddDays((7 - lastTimeOffset.DayOfWeek:GetHashCode()) % 7 + 1)
        nextRefreshTimeOffset = CS_DateTimeOffset(nextRefreshTimeOffset.Year, nextRefreshTimeOffset.Month, nextRefreshTimeOffset.Day, dailyResetHour, dailyResetMinute, dailyResetSecond, nextRefreshTimeOffset.Offset)
    elseif type == Define.DateRefreshType.Month then
        --5:00~次日5:00为一个刷新时间段，如果在0：00~4:59就统一减去一天当做上一个刷新周期
        if lastTimeOffset.Hour < dailyResetHour then
            lastTimeOffset = lastTimeOffset:AddHours(-dailyResetHour)
        end
        nextRefreshTimeOffset = lastTimeOffset:AddMonths(1)
        nextRefreshTimeOffset = CS_DateTimeOffset(nextRefreshTimeOffset.Year, nextRefreshTimeOffset.Month, 1, dailyResetHour, dailyResetMinute, dailyResetSecond, nextRefreshTimeOffset.Offset)
    elseif type == Define.DateRefreshType.Year then
        --5:00~次日5:00为一个刷新时间段，如果在0：00~4:59就统一减去一天当做上一个刷新周期
        if lastTimeOffset.Hour < dailyResetHour then
            lastTimeOffset = lastTimeOffset:AddHours(-dailyResetHour)
        end
        nextRefreshTimeOffset = lastTimeOffset:AddYears(1)
        nextRefreshTimeOffset = CS_DateTimeOffset(nextRefreshTimeOffset.Year, 1, 1, dailyResetHour, dailyResetMinute, dailyResetSecond, nextRefreshTimeOffset.Offset)
    elseif type == Define.DateRefreshType.WeekTime then
        --5 // 每周特定时间重置, 参数:周X=hh:mm:ss,多个用|分割，例：1=14:00:00|3=19:00:00
        if string.isnilorempty(detail) == false then
            local subString = string.split(detail, '|')
            for i = 1, #subString do
                local timeString = string.split(subString[i], '=')
                local weekOfDay = tonumber(timeString[1])
                local time = string.split(timeString[2], ':')
                local refreshTimeOffset = nil
                if lastTimeOffset.DayOfWeek:GetHashCode() < weekOfDay then
                    --用AddDays解决跨月跨年之类的问题
                    refreshTimeOffset = lastTimeOffset:AddDays(weekOfDay - lastTimeOffset.DayOfWeek:GetHashCode())
                    refreshTimeOffset = CS_DateTimeOffset(refreshTimeOffset.Year, refreshTimeOffset.Month, refreshTimeOffset.Day, tonumber(time[1]), tonumber(time[2]), tonumber(time[3]), refreshTimeOffset.Offset)
                    if nextRefreshTimeOffset == nil or refreshTimeOffset:CompareTo(nextRefreshTimeOffset) < 0 then
                        nextRefreshTimeOffset = refreshTimeOffset
                    end
                elseif (lastTimeOffset.DayOfWeek:GetHashCode() == weekOfDay and
                        TimeRefreshUtil.TimeCompare(lastTimeOffset.Hour, lastTimeOffset.Minute, lastTimeOffset.Second, tonumber(time[1]), tonumber(time[2]), tonumber(time[3])) == -1) then
                    refreshTimeOffset = CS_DateTimeOffset(lastTimeOffset.Year, lastTimeOffset.Month, lastTimeOffset.Day, tonumber(time[1]), tonumber(time[2]), tonumber(time[3]), lastTimeOffset.Offset)
                    if nextRefreshTimeOffset == nil or refreshTimeOffset:CompareTo(nextRefreshTimeOffset) < 0 then
                        nextRefreshTimeOffset = refreshTimeOffset
                    end
                end
            end
            ---到这里表示需要算下周的日子了
            if nextRefreshTimeOffset == nil then
                for i = 1, #subString do
                    local timeString = string.split(subString[i], '=')
                    local weekOfDay = tonumber(timeString[1])
                    local time = string.split(timeString[2], ':')
                    local refreshTimeOffset = nil
                    refreshTimeOffset = lastTimeOffset:AddDays(7 - lastTimeOffset.DayOfWeek:GetHashCode() + weekOfDay)
                    refreshTimeOffset = CS_DateTimeOffset(refreshTimeOffset.Year, refreshTimeOffset.Month, refreshTimeOffset.Day, tonumber(time[1]), tonumber(time[2]), tonumber(time[3]), refreshTimeOffset.Offset)
                    if nextRefreshTimeOffset == nil or refreshTimeOffset:CompareTo(nextRefreshTimeOffset) < 0 then
                        nextRefreshTimeOffset = refreshTimeOffset
                    end
                end
            end
        end
    elseif type == Define.DateRefreshType.Time then
        --6 // 特定时间重置, 参数:年月日=hh:mm:ss,多个用|分割,年月日为0标识每年/每月/每日,例:601=14:00:00|1230=19:00:00
        if string.isnilorempty(detail) == false then
            local subString = string.split(detail, '|')
            local curTime = TimerMgr.GetCurDate()
            for i = 1, #subString do
                local timeString = string.split(subString[i], '=')
                local date = tonumber(timeString[1])
                local year = math.modf(date / 10000)
                local month = math.modf(date % 10000 / 100)
                local day = math.modf(date % 100)
                local time = string.split(timeString[2], ':')
                local refreshTimeOffset = nil
                if day == 0 then
                    refreshTimeOffset = CS_DateTimeOffset(curTime.year, curTime.month, curTime.day, tonumber(time[1]), tonumber(time[2]), tonumber(time[3]), lastTimeOffset.Offset)
                    nextRefreshTimeOffset = TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nextRefreshTimeOffset, refreshTimeOffset)
                    refreshTimeOffset = refreshTimeOffset:AddDays(1)
                    nextRefreshTimeOffset = TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nextRefreshTimeOffset, refreshTimeOffset)
                elseif month == 0 then
                    refreshTimeOffset = CS_DateTimeOffset(curTime.year, curTime.month, day, tonumber(time[1]), tonumber(time[2]), tonumber(time[3]), lastTimeOffset.Offset)
                    nextRefreshTimeOffset = TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nextRefreshTimeOffset, refreshTimeOffset)
                    refreshTimeOffset = refreshTimeOffset:AddMonths(1)
                    nextRefreshTimeOffset = TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nextRefreshTimeOffset, refreshTimeOffset)
                elseif year == 0 then
                    refreshTimeOffset = CS_DateTimeOffset(curTime.year, month, day, tonumber(time[1]), tonumber(time[2]), tonumber(time[3]), lastTimeOffset.Offset)
                    nextRefreshTimeOffset = TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nextRefreshTimeOffset, refreshTimeOffset)
                    refreshTimeOffset = refreshTimeOffset:AddYears(1)
                    nextRefreshTimeOffset = TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nextRefreshTimeOffset, refreshTimeOffset)
                else
                    refreshTimeOffset = CS_DateTimeOffset(year, month, day, tonumber(time[1]), tonumber(time[2]), tonumber(time[3]), lastTimeOffset.Offset)
                    nextRefreshTimeOffset = TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nextRefreshTimeOffset, refreshTimeOffset)
                end
            end
        end
    elseif type == Define.DateRefreshType.AddTime then
        if not string.isnilorempty(detail) then
            local valList = string.split(detail, ":")
            nextRefreshTimeOffset = lastTimeOffset:AddHours(tonumber(valList[1])):AddMinutes(tonumber(valList[2])):AddSeconds(tonumber(valList[3]))
        end
    end
    if nextRefreshTimeOffset then
        nextRefreshTime = nextRefreshTimeOffset:ToUnixTimeSeconds()
    end
    return nextRefreshTime, nextRefreshTimeOffset
end

---获取最近的刷新时间，一定是要大于上一次刷新时间
---@param curTimeOffset CS.System.DateTimeOffset 当前时间
---@param nearestTimeOffset CS.System.DateTimeOffset
---@param nextTimeOffset CS.System.DateTimeOffset
---@return CS.System.DateTimeOffset
function TimeRefreshUtil.GetNearestRefreshTime(lastTimeOffset, nearestTimeOffset, nextTimeOffset)
    if (nearestTimeOffset == nil or nextTimeOffset:CompareTo(nearestTimeOffset) < 0) and
            nextTimeOffset:CompareTo(lastTimeOffset) >= 0 then
        return nextTimeOffset
    end
    return nearestTimeOffset
end

---比较两个时间大小
---@param hour1 int
---@param minute1 int
---@param second1 int
---@param hour2 int
---@param minute2 int
---@param second2 int
---@return int
function TimeRefreshUtil.TimeCompare(hour1, minute1, second1, hour2, minute2, second2)
    if hour1 == hour2 and minute1 == minute2 and second1 == second2 then
        return 0
    end
    if hour1 < hour2 or (hour1 == hour2 and minute1 < minute2) or
            (hour1 == hour2 and minute1 == minute2 and second1 < second2) then
        return -1
    end
    return 1
end

Init()

return TimeRefreshUtil