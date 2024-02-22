---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-05-19 11:50:18
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
---@class ConditionCheckUtil
local ConditionCheckUtil = class("ConditionCheckUtil")

---@type table<int, cfg.CommonCondition> 按Group给CommonCondition分类，减少表格的遍历
local conditionGroupDict = nil
---@type table<int, boolean>
local hasExData = nil

--region LocalFunction
---检测条件
---@param id number CommonCondition表中ConditionType类型id
---@return boolean,boolean  1:是否存在bll检测, 2:检测结果
local function CheckCondition(id, ...)
    if not id then
        return nil
    end
    local exist, res
    local num = 0
    local cfg = ConditionTypeClient[id]
    if cfg and not string.isnilorempty(cfg.Bll) then
        local bll = BllMgr.Get(cfg.Bll)
        if bll and bll.CheckCondition then
            exist = true
            res, num = bll:CheckCondition(id, ...)
        else
            Debug.LogError(string.concat(cfg.Bll, "CheckCondition is nil"))
        end
    end
    return exist, res, num
end

---获取CommonCondition的描述
---@param commonConditionId int
---@return string
local function GetDefaultConditionDesc(commonConditionId)
    local commonCondition = LuaCfgMgr.Get("CommonCondition", commonConditionId)
    local desc = nil
    if commonCondition.ConditionType == X3_CFG_CONST.CONDITION_ROLE_LOVELEVEL then
        local roleInfo = LuaCfgMgr.Get("RoleInfo", commonCondition.ConditionPara0)
        desc = UITextHelper.GetUIText(commonCondition.Description,
                roleInfo.Name,
                commonCondition.ConditionPara1,
                commonCondition.ConditionPara2,
                commonCondition.ConditionPara3,
                commonCondition.ConditionPara4)
    elseif commonCondition.ConditionType == X3_CFG_CONST.CONDITION_TIME then
        if commonCondition.ConditionPara0 == 4 then
            local timeNow = GrpcMgr.GetServerTime()
            local startDate = CS.System.DateTimeOffset(timeNow.Year, timeNow.Month,
                    timeNow.Day, math.floor(commonCondition.ConditionPara1 / 10000), math.floor(commonCondition.ConditionPara1 / 100 % 100),
                    commonCondition.ConditionPara1 % 100, timeNow.Offset)
            local endDate = CS.System.DateTimeOffset(timeNow.Year, timeNow.Month,
                    timeNow.Day, math.floor(commonCondition.ConditionPara2 / 10000), math.floor(commonCondition.ConditionPara2 / 100 % 100),
                    commonCondition.ConditionPara2 % 100, timeNow.Offset)
            desc = CS.System.String.Format(UITextHelper.GetUIText(commonCondition.Description),
                    commonCondition.ConditionPara0,
                    startDate,
                    endDate,
                    commonCondition.ConditionPara3,
                    commonCondition.ConditionPara4)
        else
            desc = CS.System.String.Format(UITextHelper.GetUIText(commonCondition.Description),
                    commonCondition.ConditionPara0,
                    commonCondition.ConditionPara1,
                    commonCondition.ConditionPara2,
                    commonCondition.ConditionPara3,
                    commonCondition.ConditionPara4)
        end
    else
        desc = CS.System.String.Format(UITextHelper.GetUIText(commonCondition.Description),
                commonCondition.ConditionPara0,
                commonCondition.ConditionPara1,
                commonCondition.ConditionPara2,
                commonCondition.ConditionPara3,
                commonCondition.ConditionPara4)
    end
    return desc
end

---获取当日固定时分秒的时间戳
---@param hourMinuteSecond int
---@param dayOffset int 天数偏移量
---@return CS.System.DateTimeOffset
local function GetDateTimeOffsetCurrentDay(hourMinuteSecond, dayOffset)
    if hourMinuteSecond == -1 then
        hourMinuteSecond = 235959
    end
    local timeNow = GrpcMgr.GetServerTime()
    local hour = math.modf(hourMinuteSecond / 10000)
    local minute = math.modf(hourMinuteSecond / 100 % 100)
    local second = math.modf(hourMinuteSecond % 100)
    local date = CS.System.DateTimeOffset(timeNow.Year, timeNow.Month, timeNow.Day, hour, minute, second, timeNow.Offset)
    if dayOffset and dayOffset > 0 then
        date = date:AddDays(dayOffset)
    end
    return date
end

---获取当周固定天时分秒的时间戳 (这里把周日当做每周的最后一天, 而非第一天)
---@param day int
---@param hourMinuteSecond int
---@param dayOffset int 星期偏移量
---@return CS.System.DateTimeOffset
local function GetDateTimeOffsetCurrentWeek(day, hourMinuteSecond, weekOffset)
    if hourMinuteSecond == -1 then
        hourMinuteSecond = 235959
    end
    local date = GetDateTimeOffsetCurrentDay(hourMinuteSecond)

    local currentDayOfWeek = date.DayOfWeek:GetHashCode()
    local difference = 0  -- Define the difference here

    if day == 0 then
        -- If target day is Sunday
        if currentDayOfWeek ~= 0 then
            -- If today is not Sunday
            difference = 6 - currentDayOfWeek
        end
    else
        difference = day - currentDayOfWeek
        if difference > 0 then
            difference = difference - 7
        end
    end

    date = date:AddDays(difference)

    if weekOffset and weekOffset > 0 then
        date = date:AddDays(weekOffset * 7)
    end
    return date
end

---获取当月固定天时分秒的时间戳
---@param day int
---@param hourMinuteSecond int
---@param monthOffset int 月份偏移量
---@return CS.System.DateTimeOffset
local function GetDateTimeOffsetCurrentMonth(day, hourMinuteSecond, monthOffset)
    if hourMinuteSecond == -1 then
        hourMinuteSecond = 235959
    end
    local timeNow = GrpcMgr.GetServerTime()
    local hour = math.modf(hourMinuteSecond / 10000)
    local minute = math.modf(hourMinuteSecond / 100 % 100)
    local second = math.modf(hourMinuteSecond % 100)
    local date = CS.System.DateTimeOffset(timeNow.Year, timeNow.Month, day, hour, minute, second, timeNow.Offset)
    if monthOffset and monthOffset > 0 then
        date = date:AddMonths(monthOffset)
    end
    return date
end

---获取今年固定月天时分秒的时间戳
---@param monthAndDay int
---@param hourMinuteSecond int
---@param yearOffset int 年数偏移量
---@return CS.System.DateTimeOffset
local function GetDateTimeOffsetCurrentYear(monthAndDay, hourMinuteSecond, yearOffset)
    if hourMinuteSecond == -1 then
        hourMinuteSecond = 235959
    end
    local timeNow = GrpcMgr.GetServerTime()
    local month = math.modf(monthAndDay / 100)
    local day = math.modf(monthAndDay % 100)
    local hour = math.modf(hourMinuteSecond / 10000)
    local minute = math.modf(hourMinuteSecond / 100 % 100)
    local second = math.modf(hourMinuteSecond % 100)
    local date = CS.System.DateTimeOffset(timeNow.Year, month, day, hour, minute, second, timeNow.Offset)
    if yearOffset and yearOffset > 0 then
        date = date:AddYears(yearOffset)
    end
    return date
end

local function Init()
    if conditionGroupDict == nil then
        conditionGroupDict = {}
        local commonConditionTable = LuaCfgMgr.GetAll("CommonCondition")
        for _, v in pairs(commonConditionTable) do
            if conditionGroupDict[v.GroupID] == nil then
                conditionGroupDict[v.GroupID] = {}
            end
            table.insert(conditionGroupDict[v.GroupID], #conditionGroupDict[v.GroupID] + 1, v)
        end
    end
    if hasExData == nil then
        hasExData = {}
        local commoncConditionExTable = LuaCfgMgr.GetAll("CommonConditionExCheck")
        for k, _ in pairs(commoncConditionExTable) do
            hasExData[k] = true
        end
    end
end
--endregion
local emptyTable = {}
---根据groupId返回CommonCondition列表
---@param groupId
---@return cfg.CommonCondition[]
function ConditionCheckUtil.GetCommonConditionListByGroupId(groupId)
    if table.containskey(conditionGroupDict, groupId) then
        return conditionGroupDict[groupId]
    else
        if groupId ~= 0 and groupId ~= nil then
            Debug.LogErrorFormat("[CommonCondition]发现不存在的GroupId:%s", groupId)
        end
        if UNITY_EDITOR and not table.isnilorempty(emptyTable) then
            Debug.LogFatal("ConditionCheckUtil GetCommonConditionListByGroupId emptyTable is not empty")
        end
        return emptyTable
    end
end

---根据CommonCondition组做条件检查，都为“或”检查，没有填额外值的需要全部满足才返回True
---@param commonConditionGroupId Int @对应CommonCondition表的GroupID字段
---@param paramList int[]
---@param notPassCondition int[] 检查未通过的ConditionId List
---@return boolean
function ConditionCheckUtil.CheckConditionByCommonConditionGroupId(commonConditionGroupId, paramList, notPassCondition)
    if commonConditionGroupId == 0 then
        return true
    end
    if paramList ~= nil then
        paramList = GameHelper.ToTable(paramList)
    end
    local commonConditions = ConditionCheckUtil.GetCommonConditionListByGroupId(commonConditionGroupId)
    local hasExData = ConditionCheckUtil.HasExData(commonConditionGroupId)
    local needNum = #commonConditions
    if hasExData then
        local exCheck = LuaCfgMgr.Get("CommonConditionExCheck", commonConditionGroupId)
        needNum = exCheck.NeedNum
    end
    local passedCount = 0
    for _, v in pairs(commonConditions) do
        if ConditionCheckUtil.CheckCommonCondition(v.ID, paramList) then
            passedCount = passedCount + 1
        else
            if notPassCondition then
                table.insert(notPassCondition, v.ID)
            end
        end
    end
    return passedCount >= needNum and (needNum ~= 0), notPassCondition
end

---是否配置了Ex数据
---@param commonConditionGroupId Int @对应CommonCondition表的GroupID字段
---@return boolean
function ConditionCheckUtil.HasExData(commonConditionGroupId)
    if hasExData[commonConditionGroupId] then
        return true
    end
    return false
end

---根据CommonConditionId做条件检查
---@param commonConditionId Int @对应CommonCondition表的Id字段
---@param paramList int[]
---@return boolean
function ConditionCheckUtil.CheckCommonCondition(commonConditionId, params)
    local commonCondition = LuaCfgMgr.Get("CommonCondition", commonConditionId)
    if not commonCondition then
        Debug.LogError("[ConditionCheckUtil.CheckCommonCondition]--condition not exist:", commonConditionId)
        return
    end
    local tempParamList = PoolUtil.GetTable()
    local paramList = tempParamList
    if params ~= nil then
        paramList = table.clone(params)
    end
    if table.isnilorempty(paramList) then
        table.insert(paramList, #paramList + 1, commonCondition.ConditionPara0)
        table.insert(paramList, #paramList + 1, commonCondition.ConditionPara1)
        table.insert(paramList, #paramList + 1, commonCondition.ConditionPara2)
        table.insert(paramList, #paramList + 1, commonCondition.ConditionPara3)
        table.insert(paramList, #paramList + 1, commonCondition.ConditionPara4)
    end
    local result = ConditionCheckUtil.SingleConditionCheck(commonCondition.ConditionType, paramList)
    PoolUtil.ReleaseTable(tempParamList)
    return result
end

---静态表里配置的int[]，第一位为ConditionType，后面为参数列表，etc:[1001,1,1]...
---@param list int[]
---@return boolean
function ConditionCheckUtil.CheckConditionByIntList(list)
    if list == nil or #list <= 0 then
        return true
    end
    local id = list[1]
    local listTemp = PoolUtil.GetTable()
    for i = 2, #list do
        table.insert(listTemp, #listTemp + 1, list[i])
    end
    local result = ConditionCheckUtil.SingleConditionCheck(id, listTemp)
    PoolUtil.ReleaseTable(listTemp)
    return result
end

---单个条件检查函数
---会先去BllMgr里查找检查函数是否配置在了ConditionType表的Bll字段中，如果是，会执行对应Bll的CheckCondition函数
---否则会调用ConditionCheckType里注册的函数做条件检查
---缺省为false
---@param id int ConditionCheckType
---@param datas int[] 检查的参数
---@param iDataProvider IDataProvider 部分条件检查所需特殊参数的提供者
---@return boolean
function ConditionCheckUtil.SingleConditionCheck(id, datas, iDataProvider)
    local result = false
    local exist = false
    local num = 0
    datas = GameHelper.ToTable(datas)
    --补足缺省参数
    local conditionType = LuaCfgMgr.Get("ConditionType", id)
    if conditionType then
        for i = #datas + 1, 5 do
            table.insert(datas, #datas + 1, conditionType[string.concat("DefaultPara", i - 1)])
        end
    end
    exist, result, num = CheckCondition(id, datas, iDataProvider)
    if not exist then
        Debug.LogWarning("未添加的ConditionID：", id)
    end
    return result or false, num or 0
end

---通过传入一个CommonConditionGroupID，获得第一个不满足条件的描述提示
---@param commonConditionGroupId Int 对应CommonCondition表的GroupID字段
---@return string
function ConditionCheckUtil.GetConditionDescByGroupId(commonConditionGroupId)
    local conditions = ConditionCheckUtil.GetCommonConditionListByGroupId(commonConditionGroupId)
    for _, v in pairs(conditions) do
        if ConditionCheckUtil.CheckCommonCondition(v.ID, nil) == false then
            return ConditionCheckUtil.GetConditionDesc(v.ID)
        end
    end
    return ""
end

---通过传入一个CommonConditionGroupID，获得所有不满足条件的描述提示
---@param commonConditionGroupId Int 对应CommonCondition表的GroupID字段
---@return string
function ConditionCheckUtil.GetAllConditionDescByGroupId(commonConditionGroupId)
    local conditions = ConditionCheckUtil.GetCommonConditionListByGroupId(commonConditionGroupId)
    local desc = {}
    for _, v in pairs(conditions) do
        if ConditionCheckUtil.CheckCommonCondition(v.ID) == false then
            table.insert(desc, ConditionCheckUtil.GetConditionDesc(v.ID))
        end
    end
    return table.concat(desc, ',')
end

---传入CommonConditionID，获得条件的描述提示
---@param commonConditionId Int 对应CommonCondition表的Id字段
---@return string
function ConditionCheckUtil.GetConditionDesc(commonConditionId)
    local tips = ""
    tips = GetDefaultConditionDesc(commonConditionId)
    return tips
end

---判断是否在范围内
---@param cur number 当前值
---@param min number 最小为0
---@param max number 填-1代表无穷大
---@return boolean
function ConditionCheckUtil.IsInRange(cur, min, max)
    cur = cur or 0
    local maxNum = max < 0 and Mathf.Infinity or max
    local minNum = min < 0 and 0 or min
    return cur >= minNum and cur <= maxNum
end

---根据参数获取时间范围
---@param datas string[] 时间参数
---@param getNextTime bool 是否获取下一个时间点 (用于获取埋点时间戳) 如果当前时间不在当前获取的时间范围内, 则返回下一个周期的时间段
function ConditionCheckUtil.GetTimeRangeByDatas(datas, getNextTime)
    local nowTime = GrpcMgr.GetServerTime()
    local startTime
    local endTime
    local timeType = tonumber(datas[1])

    local function __checkIfInTimeRange(_startTime, _endTime)
        return nowTime:CompareTo(_startTime) >= 0 and nowTime:CompareTo(_endTime) <= 0
    end

    if timeType == 1 then
        startTime = GetDateTimeOffsetCurrentYear(tonumber(datas[2]), tonumber(datas[3]))
        endTime = GetDateTimeOffsetCurrentYear(tonumber(datas[4]), tonumber(datas[5]))

        if getNextTime and not __checkIfInTimeRange(startTime, endTime) then
            -- 加一个周期 加一年
            startTime = GetDateTimeOffsetCurrentYear(tonumber(datas[2]), tonumber(datas[3]), nowTime:CompareTo(startTime) < 0 and 0 or 1)
            endTime = GetDateTimeOffsetCurrentYear(tonumber(datas[4]), tonumber(datas[5]), nowTime:CompareTo(startTime) < 0 and 0 or 1)
        end
    elseif timeType == 2 then
        startTime = GetDateTimeOffsetCurrentMonth(tonumber(datas[2]), tonumber(datas[3]))
        endTime = GetDateTimeOffsetCurrentMonth(tonumber(datas[4]), tonumber(datas[5]))

        if getNextTime and not __checkIfInTimeRange(startTime, endTime) then
            -- 加一个周期 加一个月
            startTime = GetDateTimeOffsetCurrentMonth(tonumber(datas[2]), tonumber(datas[3]), nowTime:CompareTo(startTime) < 0 and 0 or 1)
            endTime = GetDateTimeOffsetCurrentMonth(tonumber(datas[4]), tonumber(datas[5]), nowTime:CompareTo(startTime) < 0 and 0 or 1)
        end
    elseif timeType == 3 then
        local dayList = {}
        local day = tonumber(datas[2])
        while day > 0 do
            table.insert(dayList, day % 10)
            day = math.modf(day / 10)
        end
        local isInCurRange = false
        for i = 1, #dayList do
            startTime = GetDateTimeOffsetCurrentWeek(dayList[i], tonumber(datas[3]))
            endTime = GetDateTimeOffsetCurrentWeek(dayList[i], tonumber(datas[4]))

            if nowTime:CompareTo(startTime) >= 0 and nowTime:CompareTo(endTime) <= 0 then
                isInCurRange = true
                break
            end
        end

        if not isInCurRange and getNextTime then
            -- 走到这里就是说当前时间不在周期内的了, 现在就找个未来最近的时间返回
            local curTime = TimerMgr.GetCurTimeSeconds()    -- 当前时间
            local minStartTime, minEndTime, minStartTimeStamp
            for i = 1, #dayList do
                local _startTime = GetDateTimeOffsetCurrentWeek(dayList[i], tonumber(datas[3]))
                local _startTimeStamp = _startTime and _startTime:ToUnixTimeSeconds()

                if _startTimeStamp and _startTimeStamp > curTime and ((not minStartTimeStamp) or (_startTimeStamp < minStartTimeStamp)) then
                    minStartTimeStamp = _startTimeStamp
                    minStartTime = _startTime
                    minEndTime = GetDateTimeOffsetCurrentWeek(dayList[i], tonumber(datas[4]))
                end
            end

            -- 走到这里说明本周都没找到合适的时间, 那就找个下周的最早的合适的时间吧 smf
            if not minStartTime then
                local minWeekDay
                for _, _weekDay in pairs(dayList) do
                    minWeekDay = math.min(minWeekDay or _weekDay, _weekDay)
                end

                minStartTime = GetDateTimeOffsetCurrentWeek(minWeekDay, tonumber(datas[3]), 1)
                minEndTime = GetDateTimeOffsetCurrentWeek(minWeekDay, tonumber(datas[4]), 1)
            end

            -- 终于拿到了结果
            startTime = minStartTime
            endTime = minEndTime
        end
    elseif timeType == 4 then
        startTime = GetDateTimeOffsetCurrentDay(tonumber(datas[2]))
        endTime = GetDateTimeOffsetCurrentDay(tonumber(datas[3]))

        if getNextTime and not __checkIfInTimeRange(startTime, endTime) then
            -- 加一个周期 加一天
            startTime = GetDateTimeOffsetCurrentDay(tonumber(datas[2]), nowTime:CompareTo(startTime) < 0 and 0 or 1)
            endTime = GetDateTimeOffsetCurrentDay(tonumber(datas[3]), nowTime:CompareTo(startTime) < 0 and 0 or 1)
        end
    elseif timeType == 5 then
        startTime = ConditionCheckUtil.GetDateTimeOffsetCurrentOffset(tonumber(datas[2]), tonumber(datas[3]))
        endTime = ConditionCheckUtil.GetDateTimeOffsetCurrentOffset(tonumber(datas[4]), tonumber(datas[5]))

        -- 这种固定类型的没有埋点 
    end

    return startTime, endTime
end

---判断是否在时间范围内
---@param datas string[]
---@return boolean
function ConditionCheckUtil.IsInTimeRange(datas)
    local nowTime = GrpcMgr.GetServerTime()
    local startTime, endTime
    startTime, endTime = ConditionCheckUtil.GetTimeRangeByDatas(datas)

    return nowTime:CompareTo(startTime) >= 0 and nowTime:CompareTo(endTime) <= 0
end

---获取时间的DateTimeOffset
---@param yearMonthDay int 年月日
---@param hourMinuteSecond int 时分秒
---@return CS.System.DateTimeOffset
function ConditionCheckUtil.GetDateTimeOffsetCurrentOffset(yearMonthDay, hourMinuteSecond)
    if hourMinuteSecond == -1 then
        hourMinuteSecond = 235959
    end
    local timeNow = GrpcMgr.GetServerTime()
    local year = math.modf(yearMonthDay / 10000)
    local month = math.modf(yearMonthDay / 100 % 100)
    local day = math.modf(yearMonthDay % 100)
    local hour = math.modf(hourMinuteSecond / 10000)
    local minute = math.modf(hourMinuteSecond / 100 % 100)
    local second = math.modf(hourMinuteSecond % 100)
    local date = CS.System.DateTimeOffset(year, month, day, hour, minute, second, timeNow.Offset)
    return date
end

--TODO
---根据ConditionCheckData做条件检查，目前剧情里在用，考虑干掉
---id : 1
---paramList {"1","1","1","1","1"}
---暂时剧情中在使用
---@param list string[]
---@param dataProvider IDataProvider
---@return boolean, ConditionCheckData
function ConditionCheckUtil.CheckConditionCheckData(list, dataProvider)
    local result = true
    local firstFailedCondition = nil
    if list ~= nil then
        list = GameHelper.ToTable(list)
        if list == nil or #list == 0 then
            return true
        end

        for i = 1, #list do
            local conditionType = list[i].id
            --TODO 批量刷新剧情Lua前 临时
            local paramList = PoolUtil.GetTable()
            for j = 1, #list[i].paramList do
                table.insert(paramList, #paramList + 1, tonumber(list[i].paramList[j]))
            end
            if ConditionCheckUtil.SingleConditionCheck(conditionType, paramList, dataProvider) == false then
                if result == true then
                    firstFailedCondition = list[i]
                end
                result = false
            end
            PoolUtil.ReleaseTable(paramList)
        end
    end

    return result, firstFailedCondition
end
---通过GM命令获得服务器Check结果，编辑器用
function ConditionCheckUtil.SendServerCheckByType(conditionID, paramlist)
    local messageBody = {}
    local params = GameHelper.ToTable(paramlist)
    messageBody.Params = {
        "condition",
        "params",
        tostring(conditionID),
        params[1] and tostring(params[1]),
        params[2] and tostring(params[2]),
        params[3] and tostring(params[3]),
        params[4] and tostring(params[4]),
        params[5] and tostring(params[5]),
    }
    GrpcMgr.SendRequest(RpcDefines.GmSendRequest, messageBody, true)
    if UNITY_EDITOR then
        EventMgr.AddListenerOnce("OnServerConditionCheck", function(result)
            EventMgr.DispatchEventToCS("OnServerConditionCheck", result.Response)
        end)
    end
end

---通过GM命令获得服务器Check结果，编辑器用
function ConditionCheckUtil.SendServerCheckByGroup(conditionGroupID)
    local messageBody = {}
    messageBody.Params = {
        "condition",
        "group",
        tostring(conditionGroupID),
    }
    GrpcMgr.SendRequest(RpcDefines.GmSendRequest, messageBody, true)
    if UNITY_EDITOR then
        EventMgr.AddListenerOnce("OnServerConditionCheck", function(result)
            EventMgr.DispatchEventToCS("OnServerConditionCheck", result.Response)
        end)
    end
end

Init()

return ConditionCheckUtil

