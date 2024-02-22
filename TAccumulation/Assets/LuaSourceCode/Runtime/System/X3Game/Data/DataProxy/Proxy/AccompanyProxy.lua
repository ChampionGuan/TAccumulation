﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2022/4/20 20:00
---@type AccompanyConst.AccompanyOfflineType
local AccompanyConst = require("Runtime.System.X3Game.Modules.Accompany.Data.AccompanyConst")
---@class AccompanyProxy
local AccompanyProxy = class("AccompanyProxy", BaseProxy)

function AccompanyProxy:OnInit()
end

---EnterGame 初始化数据
---@param accompanyData pbcmessage.AccompanyData
function AccompanyProxy:Init(accompanyData)
    ---@type X3Data.AccompanyData
    self.accompanyData = X3DataMgr.GetOrAdd(X3DataConst.X3Data.AccompanyData)
    if accompanyData == nil or accompanyData.RoleMap == nil then
        return
    end
    
    for roleId, roleData in pairs(accompanyData.RoleMap) do
        self:AddOrUpdateRoleData(roleId ,
                {
                    RoleID = roleId ,
                    Type = roleData.Type ,
                    StartTime = roleData.StartTime,
                    ExpectDuration = roleData.ExpectDuration,
                    AccumulateTime = roleData.AccumulateTime,
                    OfflineDuration = roleData.OfflineDuration,
                    WaitDuration = roleData.WaitDuration,
                    Records = roleData.Records,
                })
    end
end

---@param roleId number
---@param roleData pbcmessage.AccompanyRoleData
function AccompanyProxy:AddOrUpdateRoleData(roleId, roleData)
    if roleData == nil then
        return
    end
    local roleDecodeData = self:GetAccompanyRoleData(roleId)
    if not roleDecodeData then
        roleDecodeData = X3DataMgr.Get(X3DataConst.X3Data.AccompanyRoleData , roleId)
        if not roleDecodeData then
            roleDecodeData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.AccompanyRoleData , nil , roleId)
        end
        roleDecodeData:DecodeByField(roleData)
    else
        roleDecodeData:DecodeByIncrement(roleData)
    end
    
    self.accompanyData:AddOrUpdateRoleMapValue(roleId, roleDecodeData)
end

---陪伴结束后更新陪伴记录, 这部分是客户端计算
---@param roleId number
---@param duration number
function AccompanyProxy:AddOrUpdateRoleRecord(roleId, duration)
    duration = math.floor(duration / 60 / 1000) 
    ---不足一分钟不做记录
    if duration < 1 then
        return
    end
    local roleData = self:GetAccompanyRoleData(roleId)
    local accompanyType = roleData:GetType()
    
    local curTimeInfo = TimerMgr.GetCurDate()
    local curYear = curTimeInfo.year
    local curDay = curTimeInfo.yday
    
    local yearRecord = PoolUtil.GetTable()
    yearRecord[curYear] = {}
    yearRecord[curYear].Records = {}
    yearRecord[curYear].Records[curDay] = {}
    yearRecord[curYear].Records[curDay].Records = {}
    
    local typeRecord = {Cnt = 1 , Duration = duration}
    local realRecords = roleData:GetRecords()
    if realRecords and realRecords[curYear] then
        local realYearRecord = realRecords[curYear]:GetRecords()
        if realYearRecord and realYearRecord[curDay] then
            local realDayRecord = realYearRecord[curDay]:GetRecords()
            if realDayRecord and realDayRecord[accompanyType] then
                local realRecord = realDayRecord[accompanyType]
                typeRecord.Cnt = typeRecord.Cnt + realRecord:GetCnt()
                typeRecord.Duration = typeRecord.Duration + realRecord:GetDuration()
            end
        end
    end
    yearRecord[curYear].Records[curDay].Records[accompanyType] = typeRecord
    roleData:DecodeByIncrement({Records = {YearRecords = yearRecord}})
    PoolUtil.ReleaseTable(yearRecord)
end

function AccompanyProxy:AddOrUpdateRoleLastTimes(roleId, accompanyType, time)
    local roleData = self:GetAccompanyRoleData(roleId)
    roleData:AddOrUpdateLastAccompanyTimesValue(roleId * 1000 + accompanyType ,time)
end

---获取所有陪伴
---@return X3Data.AccompanyRoleData
function AccompanyProxy:GetAccompanyMap()
    local roleMap = self.accompanyData:GetRoleMap()
    return roleMap
end

---获取当前角色的陪伴
---@param roleId number
---@return X3Data.AccompanyRoleData
function AccompanyProxy:GetAccompanyRoleData(roleId)
    local roleMap = self:GetAccompanyMap()
    if roleMap then
        return roleMap[roleId]
    end
    return nil
end

---获取上次陪伴时间
---@param roleId number
---@param accompanyType number
---@return number
function AccompanyProxy:GetLastAccompanyTime(roleId , accompanyType)
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then
        return 0
    end
    local lastTimeMap = roleData:GetLastAccompanyTimes()
    if not lastTimeMap then
        return 0
    end
    local lastFitnessTime = lastTimeMap[roleId*1000 + accompanyType]
    if lastFitnessTime == nil then
        return 0
    end
    return lastFitnessTime
end

---获取周陪伴次数
---@param roleId number
---@param accompanyType number
---@return number
function AccompanyProxy:GetAccompanyWeekCnt(roleId , accompanyType)
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then
        return 0
    end
    local weekCntMap = roleData:GetRecords():GetWeekRecordCnt()
    if not weekCntMap then
        return 0
    end
    local cnt = weekCntMap[accompanyType]
    return cnt or 0
end

---获取倒计时
---@param roleId number
---@return number 秒
function AccompanyProxy:GetCountDownTime(roleId)
    ---@type X3Data.AccompanyRoleData
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then
        return 0
    end
    local expectTime = roleData:GetExpectDuration() / 1000
    local startTime = self:GetStartTime(roleId)
    local endTime = startTime + expectTime
    local curTime = TimerMgr.GetCurTimeSeconds()
    Debug.LogFormat("开始时间:%s , 离线时间:%s , 期待时间: %s , 等待时间: %s , 结束时间: %s , 当前时间: %s , 倒计时时间: %s" , roleData:GetStartTime()/ 1000,
            roleData:GetOfflineDuration()/1000, expectTime,roleData:GetWaitDuration()/ 1000,
            endTime,
            curTime,endTime - curTime
    )
    return math.ceil(endTime - curTime)
end

---获取开始时间
---@param roleId number
---@return number 秒
function AccompanyProxy:GetStartTime(roleId)
    ---@type X3Data.AccompanyRoleData
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then
        return 0
    end
    local startTime = roleData:GetStartTime()
    local offlineTime = roleData:GetOfflineDuration()
    local waitTime = roleData:GetWaitDuration()
    return math.floor((startTime + offlineTime + waitTime) / 1000)
end

---获取期待陪伴时间
---@param roleId number
---@return number 秒
function AccompanyProxy:GetExpectTime(roleId)
    ---@type X3Data.AccompanyRoleData
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then
        return 0
    end
    local expectTime = roleData:GetExpectDuration()
    return math.floor(expectTime / 1000)
end

---获取累计陪伴时间
---@param roleId number
---@return number 秒
function AccompanyProxy:GetAccumulateTime(roleId)
    ---@type X3Data.AccompanyRoleData
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then
        return 0
    end
    local accumulateTime = roleData:GetAccumulateTime()
    return math.floor(accumulateTime / 1000)
end

---重新登录后陪伴状态
---@return AccompanyConst.AccompanyOfflineType
function AccompanyProxy:GetAccompanyOfflineType()
    local reconnectTime = LuaCfgMgr.Get("SundryConfig" , X3_CFG_CONST.ACCOMPANYTIMERECONNECTCHECK)
    reconnectTime = reconnectTime * 60 * 1000
    local roleMap = self.accompanyData:GetRoleMap()
    if not roleMap then
        return AccompanyConst.AccompanyOfflineType.NoAccompany
    end
    for _, roleData in pairs(roleMap) do
        local offlineTime = roleData:GetOfflineDuration()
        if offlineTime > 0 then
            local endTime = roleData:GetStartTime() + roleData:GetWaitDuration() + offlineTime + roleData:GetExpectDuration()
            local curTime = TimerMgr.GetCurTimeSeconds()
            Debug.LogFormat("Accompany ReConnect 开始时间: %s , 等待时间: %s , 期待时间: %s  , 离线时间: %s, 结束时间: %s , 当前时间: %s",
                    roleData:GetStartTime() / 1000 , roleData:GetWaitDuration() / 1000 , roleData:GetExpectDuration() / 1000, offlineTime / 1000 , endTime / 1000 , curTime)
            if endTime < curTime * 1000 then
                return AccompanyConst.AccompanyOfflineType.Stop
            end
            if offlineTime < reconnectTime then
                return AccompanyConst.AccompanyOfflineType.ReConnect
            else
                return AccompanyConst.AccompanyOfflineType.Stop
            end
        end
    end
    return AccompanyConst.AccompanyOfflineType.NoAccompany
end

---获取指定时间的陪伴记录
---@param year number 年
---@param month number 月
---@param roleId number 角色id
---@return table<int, X3Data.AccompanyTypeRecord>
function AccompanyProxy:GetCurTimeAccompanyRecord(year, month , roleId)
    ---@type X3Data.AccompanyRoleData
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then
        return nil
    end
    local monthFirDay = tonumber(os.date("!%j", os.time({year= year, month= month, day=1})))
    local monthLastDay = tonumber(os.date("!%j", os.time({year= year, month= month + 1, day=0})))
    local records = roleData:GetRecords()
    if not records then
        return nil
    end
    ---@type X3Data.AccompanyYearRecord
    local records2Year = records:GetYearRecords()
    if not records2Year then
        return nil
    end
    local curYearRecord = records2Year[year]
    if not curYearRecord then
        return nil
    end
    ---@type X3Data.AccompanyDayRecord
    local records2Day = curYearRecord:GetRecords()
    local resultRecord = {}
    for day = monthFirDay , monthLastDay do
        local monthDay = day - monthFirDay + 1
        local dayInfo = records2Day[day]
        if dayInfo ~= nil then
            resultRecord[monthDay] = dayInfo:GetRecords()
        end
    end
    return resultRecord
end

---获取最早的陪伴时间
---@param year number 年
---@param month number 月
---@param roleId number 角色id
---@return bool ,number, number  success ,年份, 月份
function AccompanyProxy:GetFirstTimeAccompanyRecord(roleId)
    ---@type X3Data.AccompanyRoleData
    local roleData = self:GetAccompanyRoleData(roleId)
    if not roleData then    ---没有陪伴记录
        return false
    end
    ---@type X3Data.AccompanyYearRecord
    local records2Year = roleData:GetRecords():GetYearRecords()
    if not records2Year then
        return false
    end
    
    local allYear = PoolUtil.GetTable()
    for year , _ in pairs(records2Year) do
        allYear[#allYear + 1] = year
    end
    local minYear = math.min(table.unpack(allYear))
    if not minYear then     ---没有陪伴记录
        return false
    end

    if not records2Year.Records then
        return false
    end
    
    local record2Day = records2Year.Records[minYear]
    local allDay = PoolUtil.GetTable()
    for day , _ in pairs(record2Day) do
        allDay[#allDay + 1] = day
    end
    local minDay = math.min(table.unpack(allYear))
    if not minDay then      ---没有陪伴记录
        return false 
    end
    local minMonth = os.date("!%m", os.time({year = minYear, month = 1, day = minDay}))
    PoolUtil.ReleaseTable(allYear)
    PoolUtil.ReleaseTable(allDay)
    return true, minYear , minMonth
end

return AccompanyProxy