﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2022/3/25 14:57
---

---@class SignProxy:BaseProxy
local SignProxy = class("SignProxy", BaseProxy)
local HOUR_SECS = 3600

function SignProxy:OnInit()
    self.data = require("Runtime.System.X3Game.Data.DataProxy.Data.SignData").new()
    self:SetStaminaTimeTab()
    self:SetReCostCountTab()
end

function SignProxy:SetReCostCountTab()
    local cfgResignPrice = LuaCfgMgr.GetAll("ResignPrice")
    ---@type table<ResignPrice>
    local reCostCountTab = {}
    for i, v1 in ipairs(cfgResignPrice) do
        ---@type ResignPrice
        local resignPrice = {}
        resignPrice.id = v1.ID
        ---适配表格s3int[]
        if v1.Cost ~= nil then
            resignPrice.price = v1.Cost[1]
        end
        resignPrice.timesInterval = {}
        for j, v2 in ipairs(v1.TimesInterval) do
            resignPrice.timesInterval[#resignPrice.timesInterval + 1] = v2 < 0 and 100 or v2
        end
        reCostCountTab[#reCostCountTab + 1] = resignPrice
    end
    self.data:SetReCostCountTab(reCostCountTab)
end

function SignProxy:SetStaminaTimeTab()
    local replaceDatas = LuaCfgMgr.GetAll("Stamina")
    local date = TimerMgr.GetCurDate()
    ---@type table<StaminaTimeData>
    local staminaTimeTab = {}
    for i, v in ipairs(replaceDatas) do
        ---@type StaminaTimeData
        local tab = {}
        tab.id = v.ID
        local timeTab1 = string.split(v.SignTime, "|")
        local timeMin = self:GetTimeFromString(timeTab1[1])
        local timeMax = self:GetTimeFromString(timeTab1[2])
        tab.minTime = self:GetTime(date, timeMin)
        tab.maxTime = self:GetTime(date, timeMax)
        staminaTimeTab[#staminaTimeTab + 1] = tab
    end
    self.data:SetStaminaTimeTab(staminaTimeTab)
end

function SignProxy:GetLocalTimeZone()
    local timestamp = os.time()
    local localTime = os.date("*t", timestamp)
    return localTime.hour - os.date("!*t", timestamp).hour
end

function SignProxy:GetTime(nowTime, TimeTab)
    local day = nowTime.hour < 5 and nowTime.day - 1 or nowTime.day
    return TimerMgr.GetUnixTimestamp({ year = nowTime.year, month = nowTime.month, day = day, hour = TimeTab.hour, min = TimeTab.min, sec = TimeTab.sec })
end

--- @param timeStr string 时间字符串格式："HH:MM:SS"
--- @return table 返回格式 {hour = 0, min = 0,sec = 0}
function SignProxy:GetTimeFromString(timeStr)
    local time = {}
    local timeTab = string.split(timeStr, ":")
    time.hour = tonumber(timeTab[1])
    time.min = tonumber(timeTab[2])
    time.sec = tonumber(timeTab[3])
    return time
end

---@param data pbcmessage.SignInData
function SignProxy:SignInUpdateReply(data)
    self.data:SetSignInFlag(data.SignInFlag)
    self.data:SetCostReSignInNumber(data.CostReSignInNumber)
    self.data:SetStaminaGetMap(data.StaminaGetMap)
    self.data:SetFreeStaminaComplementNumber(data.FreeStaminaComplementNumber)
    self.data:SetFreeReSignInNumber(data.FreeReSignInNumber)
    self.data:SetRewardsFlag(data.RewardsFlag)
end

---
---@param FreeReSignInLimit int
---@param FreeStaminaComplementLimit int
---@param FreeStaminaComplementLimit table<int,bool>
function SignProxy:DailyUpdate(FreeReSignInLimit, FreeStaminaComplementLimit, StaminaGetMap)
    self.data:SetFreeReSignInLimit(FreeReSignInLimit)
    self.data:SetFreeStaminaComplementLimit(FreeStaminaComplementLimit)
    self.data:SetStaminaGetMap(StaminaGetMap)
end

---@return SignData
function SignProxy:GetSignData()
    return self.data
end

function SignProxy:OnClear()
    self.data = nil
end

----根据返回结果更新数据

---更新签到奖励数据
---@param id int
function SignProxy:UpdateSignTaskReward(id)
    local rewardsFlag = self.data:GetRewardsFlag()
    rewardsFlag[#rewardsFlag + 1] = id
    self.data:SetRewardsFlag(rewardsFlag)
end

---更新体力免费补领数量
function SignProxy:UpdateFreeStaminaComplementNumber()
    local count = self.data:GetFreeStaminaComplementNumber()
    count = count + 1
    local freeStaminaComplementLimit = self.data:GetFreeStaminaComplementLimit()
    self.data:SetFreeStaminaComplementNumber(math.min(freeStaminaComplementLimit, count))
end

---体力领取更新
function SignProxy:UpdateStaminaGetData(id)
    local staminaGetMap = self.data:GetStaminaGetMap()
    if staminaGetMap == nil then
        staminaGetMap = {}
    end
    staminaGetMap[id] = true
    self.data:SetStaminaGetMap(staminaGetMap)
    BllMgr.GetWelfareBLL():UpdateStaminaRed()
end

---根据结果修改免费补签次数
function SignProxy:UpdateFreeReSignInNumber()
    local freeCount = self.data:GetFreeReSignInNumber()
    local costCount = self.data:GetCostReSignInNumber()
    local freeReSignInLimit = self.data:GetFreeReSignInLimit()
    if freeReSignInLimit > freeCount and freeReSignInLimit ~= 0 then
        freeCount = freeCount + 1
        self.data:SetFreeReSignInNumber(math.min(freeReSignInLimit, freeCount))
    else
        costCount = costCount + 1
        self.data:SetCostReSignInNumber(costCount)
    end
end

---补签根据结果修改签到标志位
function SignProxy:UpdateReSignFlag()
    local signInFlag = self.data:GetSignInFlag()
    local nowDay = self:GetNowTimeWithYearMonthDay(TimerMgr.GetCurTimeSeconds()).day
    for i = 1, nowDay do
        if (signInFlag >> i & 1) == 0 then
            signInFlag = signInFlag | 1 << i
            break
        end
    end
    self.data:SetSignInFlag(signInFlag)
end

---签到根据结果修改签到标志位
function SignProxy:UpdateSignFlag()
    local signInFlag = self.data:GetSignInFlag()
    local nowDay = self:GetNowTimeWithYearMonthDay(TimerMgr.GetCurTimeSeconds()).day
    ---按位标记为已经领取
    signInFlag = signInFlag | 1 << nowDay
    self.data:SetSignInFlag(signInFlag)
end

---判断当前时间所属的日期
---@param time int
---@return _date
function SignProxy:GetNowTimeWithYearMonthDay(time)
    local nowtime = TimerMgr.GetDateByUnixTimestamp(time)
    if nowtime.hour < 5 then
        nowtime.day = nowtime.day - 1
        if nowtime.day == 0 then
            nowtime.month = nowtime.month - 1
            if nowtime.month == 0 then
                nowtime.month = 12
                nowtime.year = nowtime.year - 1
            end
            nowtime.day = tonumber(os.date("%d", os.time({ year = nowtime.year, month = nowtime.month + 1, day = 0 })))
        end
    end
    return nowtime
end

return SignProxy