
-- 男主作息工具类
---@class DailyRoutineUtil 
local DailyRoutineUtil = {}

function DailyRoutineUtil:OnInit()
    
end

function DailyRoutineUtil:OnClear()
    
end

local function __getInitTimeInMonth(yearMonthNumber)
    -- 获取当前时间戳
    local curTime = TimerMgr.GetCurTimeSeconds(true)

    -- 获取当前日期的年、月、日
    local curDate = TimerMgr.GetCurDate()
    
    -- 如果有传入月份和年份 则覆盖当前日期
    if yearMonthNumber then
        local specificYear = math.floor(yearMonthNumber / 100)
        local specificMonth = yearMonthNumber % 100
        curDate.year = specificYear
        curDate.month = specificMonth
    end

    -- 设置日期为本月的第一天，时间为0点
    curDate.day = 1
    curDate.hour = 0
    curDate.min = 0
    curDate.sec = 0

    -- 获取本月第一天0点的时间戳
    local firstDayTimestamp = TimerMgr.GetUnixTimestamp(curDate)

    -- 计算下个月第一天0点的时间戳
    if curDate.month == 12 then
        curDate.year = curDate.year + 1
        curDate.month = 1
    else
        curDate.month = curDate.month + 1
    end
    local nextMonthInitTimeStamp = TimerMgr.GetUnixTimestamp(curDate)

    return firstDayTimestamp, nextMonthInitTimeStamp - 1
end

DailyRoutineUtil.GetInitTimeInMonth = __getInitTimeInMonth

-- 将固定格式的number转换为timestamp (unix)
-- 特殊日期日程 年月日小时(2023092100：2023年09月21日0点 or 2023092105： 2023年09月21日5点)
local function __convertYearMonthDayHour2UTCTimeStamp(self, YearMonthDayHour)
    -- 解析年、月、日和小时
    local year = math.floor(YearMonthDayHour / 1000000)
    local month = math.floor((YearMonthDayHour % 1000000) / 10000)
    local day = math.floor((YearMonthDayHour % 10000) / 100)
    local hour = YearMonthDayHour % 100

    local curDate = TimerMgr.GetCurDate()
    curDate.year = year
    curDate.month = month
    curDate.day = day
    curDate.hour = hour
    curDate.min = 0
    curDate.sec = 0

    local utcTimestamp = TimerMgr.GetUnixTimestamp(curDate)

    return utcTimestamp
end
DailyRoutineUtil.ConvertYearMonthDayHour2UTCTimeStamp = __convertYearMonthDayHour2UTCTimeStamp

-- 返回当前是星期几 星期一返回1 星期日返回7 (正常cs date那一套规则是星期日返回1， 星期1返回2 这样的)
local function __getWeekDay(timeStamp)
    local date
    if timeStamp then
        date = TimerMgr.GetDateByServerTimestamp(timeStamp)
    else
        date = TimerMgr.GetCurDate()
    end
    
    -- 获取当前日期的星期
    local wday = date.wday

    -- 调整星期的返回值，使星期一返回1，星期日返回7
    local adjustedWday
    if wday == 1 then
        adjustedWday = 7
    else
        adjustedWday = wday - 1
    end

    return adjustedWday
end
DailyRoutineUtil.GetWeekDay = __getWeekDay

-- 返回当前月份数
local function __getCurMonthIdx()
    -- 获取当前时间戳
    local curTime = TimerMgr.GetCurTimeSeconds(true)

    -- 获取当前日期的月份
    local month = TimerMgr.GetCurDate().month

    return month
end
DailyRoutineUtil.GetCurMonthIdx = __getCurMonthIdx

-- 根据给定时间戳 获取当天的最后1s
local function __getEndDayTimestamp(_timeStamp)
    local date = TimerMgr.GetDateByUnixTimestamp(_timeStamp)
    date.hour = 23
    date.min = 59
    date.sec = 59
    return TimerMgr.GetUnixTimestamp(date)
end
DailyRoutineUtil.GetEndDayTimestamp = __getEndDayTimestamp

-- 根据给定时间戳 获取当日开始时间戳
local function __getStartDayTimestamp(_timeStamp)
    local date = TimerMgr.GetDateByUnixTimestamp(_timeStamp)
    date.hour = 0
    date.min = 0
    date.sec = 0
    return TimerMgr.GetUnixTimestamp(date)
end
DailyRoutineUtil.GetStartDayTimestamp = __getStartDayTimestamp

-- 根据配置返回作息
local function __convertCfg2TimeStamp(curCfg, nextCfg)
    
end
DailyRoutineUtil.ConvertCfg2TimeStamp = __convertCfg2TimeStamp


return DailyRoutineUtil