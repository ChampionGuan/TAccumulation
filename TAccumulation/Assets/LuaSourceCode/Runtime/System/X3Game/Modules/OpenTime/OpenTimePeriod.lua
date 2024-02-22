﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/12/23 18:41
---

---@class OpenTimePeriod
local OpenTimePeriod = class("OpenTimePeriod")
local CS_DateTimeOffset = CS.System.DateTimeOffset
local CS_TimeSpan = CS.System.TimeSpan

---@class OpenTimeParam
---@field year int
---@field month int
---@field day int
---@field dayOfWeek int
---@field hour int
---@field minute int
---@field second int

---
function OpenTimePeriod:ctor()
    ---@type int 每日刷新时间(时）
    self.dailyResetHour = 5
    ---@type int 每日刷新时间(分）
    self.dailyResetMinute = 0
    ---@type int 每日刷新时间(秒）
    self.dailyResetSecond = 0

    ---@type OpenTimeParam 开启时间的时间参数
    self.startTimeParam = {}
    ---@type OpenTimeParam 结束时间的时间参数
    self.endTimeParam = {}
    ---@type uint 下一次有效的开启时间（包括当前正在开放的）
    self.openStartTime = nil
    ---@type uint 下一次有效的关闭时间（包括当前正在开放的）
    self.openEndTime = nil
    ---@type uint
    self.timeType = Define.DateOpenType.Day

    local resetString = string.split(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.COMMONDAILYRESETTIME), ":")
    self.dailyResetHour = tonumber(resetString[1])
    self.dailyResetMinute = tonumber(resetString[2])
    self.dailyResetSecond = tonumber(resetString[3])
end

---解析字符串配置
---@param timeType int
---@param dateStr string
function OpenTimePeriod:Parse(timeType, timeParam)
    self.timeType = timeType
    self.timeParam = timeParam
    table.clear(self.startTimeParam)
    table.clear(self.endTimeParam)
    self.openStartTime = nil
    self.openEndTime = nil
    local splitedDate = nil
    if timeType == Define.DateOpenType.Day then
        splitedDate = string.split(timeParam, "=")
        if #splitedDate == 2 then
            local timeStr = string.split(splitedDate[2], "-")
            self:ParseDateStr(self.startTimeParam, splitedDate[1], timeStr[1])
            self:ParseDateStr(self.endTimeParam, splitedDate[1], timeStr[2])
        else
            local timeStr = string.split(splitedDate[1], "-")
            --日期缺省
            if #timeStr > 1 then
                self:ParseDateStr(self.startTimeParam, nil, timeStr[1])
                self:ParseDateStr(self.endTimeParam, nil, timeStr[2])
            else
                self:ParseDateStr(self.startTimeParam, splitedDate[1], LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.COMMONDAILYRESETTIME))
                self:ParseDateStr(self.endTimeParam, splitedDate[1], "4:59:59")
            end
        end
    elseif timeType == Define.DateOpenType.Week then
        splitedDate = string.split(timeParam, "=")
        if #splitedDate == 2 then
            local timeStr = string.split(splitedDate[2], "-")
            self:ParseWeekStr(self.startTimeParam, tonumber(splitedDate[1]), timeStr[1])
            self:ParseWeekStr(self.endTimeParam, tonumber(splitedDate[1]), timeStr[2])
        else
            local timeStr = string.split(splitedDate[1], "-")
            if #timeStr == 2 then
                self:ParseWeekStr(self.startTimeParam, -1, timeStr[1])
                self:ParseWeekStr(self.endTimeParam, -1, timeStr[2])
            else
                self:ParseWeekStr(self.startTimeParam, tonumber(splitedDate[1]), LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.COMMONDAILYRESETTIME))
                self:ParseWeekStr(self.endTimeParam, tonumber(splitedDate[1]), "4:59:59")
            end
        end
    elseif timeType == Define.DateOpenType.Time then
        splitedDate = string.split(timeParam, "-")
        local startTimeStr = string.split(splitedDate[1], "=")
        local endTimeStr = string.split(splitedDate[2], "=")
        self:ParseDateStr(self.startTimeParam, startTimeStr[1], startTimeStr[2])
        self:ParseDateStr(self.endTimeParam, endTimeStr[1], endTimeStr[2] and endTimeStr[2] or "4:59:59")
    end
end

---解析
---@param timeParam OpenTimeParam
---@param datestr string 日期字符串，可以缺省，20220803，20220003, 718，14etc。。。
---@param timeStr string 时间字符串，可以缺省，14:00:00，14:30，14etc。。。
function OpenTimePeriod:ParseDateStr(timeParam, dateStr, timeStr)
    dateStr = dateStr and dateStr or "0"
    timeStr = timeStr and timeStr or ""
    local dateInt = tonumber(dateStr)
    timeParam.year = math.floor(dateInt / 10000)
    timeParam.month = math.floor(dateInt / 100 % 100)
    timeParam.day = math.floor(dateInt % 100)
    local startTimeStr = string.split(timeStr, ":")
    timeParam.hour = startTimeStr[1] and tonumber(startTimeStr[1]) or self.dailyResetHour
    timeParam.minute = startTimeStr[2] and tonumber(startTimeStr[2]) or self.dailyResetMinute
    timeParam.second = startTimeStr[3] and tonumber(startTimeStr[3]) or self.dailyResetSecond
end

---解析
---@param timeParam OpenTimeParam
---@param dayOfWeek string 周几，1、2、3、4、5、6 分别表示周一到周六，0 或者 7 均表示周日
---@param timeStr string 时间字符串，可以缺省，14:00:00，14:30，14etc。。。
function OpenTimePeriod:ParseWeekStr(timeParam, dayOfWeek, timeStr)
    timeParam.dayOfWeek = dayOfWeek ~= -1 and dayOfWeek % 7 or dayOfWeek
    local startTimeStr = string.split(timeStr, ":")
    timeParam.hour = startTimeStr[1] and tonumber(startTimeStr[1]) or self.dailyResetHour
    timeParam.minute = startTimeStr[2] and tonumber(startTimeStr[2]) or self.dailyResetMinute
    timeParam.second = startTimeStr[3] and tonumber(startTimeStr[3]) or self.dailyResetSecond
end

---是否在开放时间内
---@param curTimeStamp uint
---@return boolean
function OpenTimePeriod:IsInOpenTime(curTimeStamp)
    self:InternalCheckOpenTime(curTimeStamp)
    if self.openStartTime == 0 and self.openEndTime == 0 then
        return true
    end
    return self.openStartTime <= curTimeStamp and self.openEndTime >= curTimeStamp
end

---获取最近的开启时间段，如果取不到则返回-1,为0表示全天开放
---@param curTimeStamp uint
---@return uint, uint
function OpenTimePeriod:GetNearestOpenTime(curTimeStamp)
    self:InternalCheckOpenTime(curTimeStamp)
    return self.openStartTime, self.openEndTime
end

---检查开启时间，如果已过期则重新计算
---@param curTimeStamp uint
function OpenTimePeriod:InternalCheckOpenTime(curTimeStamp)
    if self.openEndTime == nil or self.openEndTime < curTimeStamp then
        self.openStartTime = -1
        self.openEndTime = -1
        if self.timeType == Define.DateOpenType.Day and string.isnilorempty(self.timeParam) then
            self.openStartTime = 0
            self.openEndTime = 0
        else
            self:CalOpenTime(curTimeStamp)
        end
    end
end

---计算有效开启时间，满足结束时间大于当前时间，如果全部已过期，则返回-1，这个函数一定不是全天开放的情况
---@param curTimeStamp uint
---@return uint, uint
function OpenTimePeriod:CalOpenTime(curTimeStamp)
    local startTime = -1
    local endTime = -1
    local startTimeOffset = nil
    local endTimeOffset = nil
    if self.timeType == Define.DateOpenType.Day then
        startTimeOffset = self:TimeParamToOffset(curTimeStamp, self.startTimeParam)
        endTimeOffset = self:TimeParamToEndTime(startTimeOffset, self.endTimeParam)
        if endTimeOffset:ToUnixTimeSeconds() < curTimeStamp then
            if self.startTimeParam.day == 0 then
                local newStartTimeOffset = startTimeOffset:AddDays(1)
                if (self.startTimeParam.year == 0 or newStartTimeOffset.Year == self.startTimeParam.year)
                    and (self.startTimeParam.month == 0 or newStartTimeOffset.Month == self.startTimeParam.month) then
                    startTimeOffset = newStartTimeOffset
                    endTimeOffset = endTimeOffset:AddDays(1)
                end
            elseif self.startTimeParam.month == 0 then
                local newStartTimeOffset = startTimeOffset:AddMonths(1)
                if self.startTimeParam.year == 0 or newStartTimeOffset.Year == self.startTimeParam.year then
                    startTimeOffset = newStartTimeOffset
                    endTimeOffset = endTimeOffset:AddMonths(1)
                end
            elseif self.startTimeParam.year == 0 then
                startTimeOffset = startTimeOffset:AddYears(1)
                endTimeOffset = endTimeOffset:AddYears(1)
            end
        end
    elseif self.timeType == Define.DateOpenType.Week then
        startTimeOffset = self:WeekTimeParamToOffset(curTimeStamp, self.startTimeParam)
        endTimeOffset = self:TimeParamToEndTime(startTimeOffset, self.endTimeParam)
        if endTimeOffset:ToUnixTimeSeconds() < curTimeStamp then
            startTimeOffset = startTimeOffset:AddDays(self.startTimeParam.dayOfWeek == -1 and 1 or 7)
            endTimeOffset = endTimeOffset:AddDays(self.startTimeParam.dayOfWeek == -1 and 1 or 7)
        end
    elseif self.timeType == Define.DateOpenType.Time then
        startTimeOffset = self:TimeParamToOffset(curTimeStamp, self.startTimeParam)
        endTimeOffset = self:TimeParamToOffset(curTimeStamp, self.endTimeParam)
    end
    startTime = startTimeOffset and startTimeOffset:ToUnixTimeSeconds() or -1
    endTime = endTimeOffset and endTimeOffset:ToUnixTimeSeconds() or -1
    if endTime >= curTimeStamp then
        self.openStartTime = startTime
        self.openEndTime = endTime
    else
        self.openStartTime = -1
        self.openEndTime = -1
    end
end

---时间参数转时间
---@param curTimeStamp uint
---@param openTimeParam OpenTimeParam
---@return CS.System.DateTimeOffset
function OpenTimePeriod:TimeParamToOffset(curTimeStamp, openTimeParam)
    local curTime = CS_DateTimeOffset.FromUnixTimeSeconds(curTimeStamp)
    curTime = curTime:ToOffset(CS_TimeSpan(TimerMgr.GetTimeZone(), 0, 0))
    if curTime.Hour < self.dailyResetHour then
        curTime = curTime:AddHours(-self.dailyResetHour)
    end
    local year = openTimeParam.year == 0 and curTime.Year or openTimeParam.year
    local month = openTimeParam.month == 0 and curTime.Month or openTimeParam.month
    local day = openTimeParam.day == 0 and (month == curTime.Month and curTime.Day or 1) or openTimeParam.day
    local hour = openTimeParam.hour
    local minute = openTimeParam.minute
    local second = openTimeParam.second
    return CS_DateTimeOffset(year, month, day, hour, minute, second, curTime.Offset)
end

---周时间参数转时间
---@param curTimeStamp uint
---@param openTimeParam OpenTimeParam
---@return CS.System.DateTimeOffset
function OpenTimePeriod:WeekTimeParamToOffset(curTimeStamp, openTimeParam)
    local curTime = CS_DateTimeOffset.FromUnixTimeSeconds(curTimeStamp)
    curTime = curTime:ToOffset(CS_TimeSpan(TimerMgr.GetTimeZone(), 0, 0))
    if curTime.Hour < self.dailyResetHour then
        curTime = curTime:AddHours(-self.dailyResetHour)
    end
    local hour = openTimeParam.hour
    local minute = openTimeParam.minute
    local second = openTimeParam.second
    local dayOfWeek = openTimeParam.dayOfWeek == -1 and curTime.DayOfWeek:GetHashCode() or openTimeParam.dayOfWeek
    local dateTimeOffset = CS_DateTimeOffset(curTime.Year, curTime.Month, curTime.Day, hour, minute, second, curTime.Offset)
    dateTimeOffset = dateTimeOffset:AddDays(dayOfWeek % 7 - dateTimeOffset.DayOfWeek:GetHashCode())
    return dateTimeOffset
end

---时间参数转结束时间
---@param startTimeOffset CS.System.DateTimeOffset
---@param openTimeParam OpenTimeParam
---@return CS.System.DateTimeOffset
function OpenTimePeriod:TimeParamToEndTime(startTimeOffset, openTimeParam)
    local endTime = nil
    local endHour = openTimeParam.hour
    local endMinute = openTimeParam.minute
    local endSecond = openTimeParam.second
    endTime = CS_DateTimeOffset(startTimeOffset.Year, startTimeOffset.Month, startTimeOffset.Day, endHour,
            endMinute, endSecond, startTimeOffset.Offset)
    ---跨天了
    if endHour < startTimeOffset.Hour then
        endTime = endTime:AddDays(1)
    end
    return endTime
end

return OpenTimePeriod