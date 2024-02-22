﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yizhimao002.
--- DateTime: 2023/1/6 19:17
---
---@class MonthlyCardReplaceProxy
local MonthlyCardReplaceProxy = class("MonthlyCardReplaceProxy", BaseProxy)
---@type MonthCardConst
local MonthCardConst = require("Runtime.System.X3Game.GameConst.MonthCardConst")
function MonthlyCardReplaceProxy:OnInit()
    ---@type X3Data.MonthCardData
    self.data = X3DataMgr.GetOrAdd(X3DataConst.X3Data.MonthCardData)
end

---@return X3Data.MonthCardData
function MonthlyCardReplaceProxy:GetData()
    return self.data
end
---全量推
---@param data pbcmessage.MonthCardData
function MonthlyCardReplaceProxy:OnMonthCardDataReply(data)
    for i, v in pairs(data.MonthCardMap) do
        self.data:AddOrUpdateMonthCardTimeMapValue(i, v.Expire)
        self.data:AddOrUpdateDailyRewardFlagMapValue(i, v.DailyRewardFlag)
    end
    --self.data:SetLastRefreshTime(data.LastRefreshTime)
    self:UpdateCardPower()
end
---增量推
---@param data pbcmessage.MonthCardData
function MonthlyCardReplaceProxy:OnMonthCardDataUpdateReply(data)
    for i, v in pairs(data.ActiveMonthCardMap) do
        self.data:AddOrUpdateMonthCardTimeMapValue(i, v.Expire)
        self.data:AddOrUpdateDailyRewardFlagMapValue(i, v.DailyRewardFlag)
    end

    for i, v in pairs(data.DeleteMonthCardMap) do
        self.data:RemoveMonthCardTimeMapValue(i)
    end
    for i, v in pairs(data.ResetDailyRewardFlag) do
        self.data:RemoveDailyRewardFlagMapValue(i)
    end
    --self.data:SetLastRefreshTime(data.LastRefreshTime)
    self:UpdateCardPower()
end

---@param monthCardID number 月卡ID 清除月卡数据
function MonthlyCardReplaceProxy:CleanMonthCardData(monthCardID)
    self:GetData():RemoveMonthCardTimeMapValue(monthCardID)
    self:GetData():RemoveDailyRewardFlagMapValue(monthCardID)
    self:UpdateCardPower()
end
---更新月卡特权
function MonthlyCardReplaceProxy:UpdateCardPower()
    local monthCardMap = self.data:GetMonthCardTimeMap()
    self.data:ClearCardPowerMapValue()
    if monthCardMap ~= nil then
        for k, v in pairs(monthCardMap) do
            local monthlyCarData = BllMgr.GetMonthCardBLLReplace():GetCfgMonthlyCard(k)
            for i, j in ipairs(monthlyCarData.CardPowerGroup) do ---j是MonthlyCardPower里的PowerID
            local cardPowerMap = self.data:GetCardPowerMap()
                if(cardPowerMap ~= nil and #cardPowerMap > 0) then
                    if(cardPowerMap[j] == nil) then
                        self.data:AddOrUpdateCardPowerMapValue(j, 1)
                    else
                        self.data:AddOrUpdateCardPowerMapValue(j, cardPowerMap[j] + 1)
                    end
                else
                    self.data:AddOrUpdateCardPowerMapValue(j, 1)
                end
            end
        end
    end
    EventMgr.Dispatch(MonthCardConst.Event.MonthCardUpdate)
end

function MonthlyCardReplaceProxy:OnClear()

end

---领取每日奖励时的每日领取标志位刷新
---@param monthCardID number
function MonthlyCardReplaceProxy:UpdateCardDailyRewardFlag(monthCardID)
    local nowDay = self:GetNowTimeWithYearMonthDay(TimerMgr.GetCurTimeSeconds()).day
    local dailyRewardTab = self.data:GetDailyRewardFlagMap()
    if not dailyRewardTab then
        local signInFlag = 0 | 1 << nowDay
        self.data:AddOrUpdateDailyRewardFlagMapValue(monthCardID, signInFlag)
        return
    end
    for k, v in pairs(dailyRewardTab) do
        if k == monthCardID then
            v = v | 1 << nowDay
            self.data:UpdateDailyRewardFlagMapValue(k, v)
        end
    end
end

---判断当前时间所属的日期
---@param time int
---@return _date
function MonthlyCardReplaceProxy:GetNowTimeWithYearMonthDay(time)
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

---获取上次的刷新时间
---@return number
function MonthlyCardReplaceProxy:GetLastFreshTime()
    local lastTime = self.data:GetLastRefreshTime()
    return lastTime
end

return MonthlyCardReplaceProxy