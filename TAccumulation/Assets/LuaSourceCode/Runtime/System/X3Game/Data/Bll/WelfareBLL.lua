---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-10-26 17:24:48
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class WelfareBLL
local WelfareBLL = class("WelfareBLL", BaseBll)

---@type MonthCardConst
local MonthCardConst = require("Runtime.System.X3Game.GameConst.MonthCardConst")

function WelfareBLL:OnInit()
    self.serverOpenTime = 0
    self.reCostCountData = LuaCfgMgr.GetAll("ResignPrice")
    for i, v1 in ipairs(self.reCostCountData) do
        for j, v2 in ipairs(v1.TimesInterval) do
            if v2 < 0 then
                self.reCostCountData[i].TimesInterval[j] = 100
            end
        end
    end
    EventMgr.AddListener(Const.Event.TIME_TICK_HOUR, self.UpdateStaminaRedPointState, self)
    EventMgr.AddListener("CommonDailyReset", self.CommonDailyReset, self)
    EventMgr.AddListener("WelfareEvent_MonthCard_UpdateMonthCardData", self.UpdateWelfareRed, self)
end

---Update
function WelfareBLL:CommonDailyReset()
    ---updateSign
    self:SignDailyRefresh()
    self:UpdateStaminaRed()
    self:UpdateSignRed()
    --self:UpdateMallMonthRed()
    EventMgr.Dispatch("WelfareEvent_MonthCard_UpdateMonthCardData")
    EventMgr.Dispatch("PowerChangedEventCallBack")
    EventMgr.Dispatch("WelfareEvent_SignIn_UpdateSignInData")
    EventMgr.Dispatch("WelfareEvent_SignIn_CommonDailyReset")
end

---@public 获取体力补领的开始时间
---@return table<number>
function WelfareBLL:GetStaminaTimeStartTime()
    if SysUnLock.IsUnLock(20200) then
        local tab = {}
        ---@type table<StaminaTimeData>
        local staminaTimeTab = SelfProxyFactory.GetSignProxy():GetSignData():GetStaminaTimeTab()
        for i, v in ipairs(staminaTimeTab) do
            tab[#tab + 1] = v.minTime
        end
        return tab
    else
        return nil
    end
end

function WelfareBLL:UpdateStaminaRedPointState(hour)
    if hour == 5 then
        SelfProxyFactory.GetSignProxy():SetStaminaTimeTab()
    end
    self:UpdateStaminaRed()
end

---20200 福利
function WelfareBLL:IsCanSignIn()
    ---LYDJS-32015 【客户端】月签到，月卡领奖均去除主界面拍脸，改为系统界面内领取
    --if SysUnLock.IsUnLock(20200) then
    --    local nowTime = self:GetNowTimeWithYearMonthDay(TimerMgr.GetCurTimeSeconds())
    --    local finishSignIn = self:GetNowDataSignInState(nowTime.day)
    --    --local finishMonthReward, haveMonthCard = self:GetMonthCardDayRewardState(nowTime.day)
    --    if not finishSignIn then
    --        if not ErrandMgr.CheckTipsIsAdd(X3_CFG_CONST.POPUP_WELFARE_SIGNIN) then
    --            ErrandMgr.AddTips(X3_CFG_CONST.POPUP_WELFARE_SIGNIN)
    --        end
    --    end
    --end
end

---判断当前时间所属的日期
---@param time int
---@return _date
function WelfareBLL:GetNowTimeWithYearMonthDay(time)
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


----------------签到  SignIn--------------

---签到日常刷新
function WelfareBLL:SignDailyRefresh()
    self:SetServerOpenTime()
    local curDate = TimerMgr.GetCurDate()
    if curDate.day == 1 then
        SelfProxyFactory.GetSignProxy():GetSignData():SetFreeStaminaComplementNumber(0)
        SelfProxyFactory.GetSignProxy():GetSignData():SetCostReSignInNumber(0)
        SelfProxyFactory.GetSignProxy():GetSignData():SetFreeReSignInNumber(0)
        SelfProxyFactory.GetSignProxy():GetSignData():SetSignInFlag(0)
        SelfProxyFactory.GetSignProxy():GetSignData():SetRewardsFlag({})
    end
    SelfProxyFactory.GetSignProxy():GetSignData():SetStaminaGetMap({})
end

---@param data pbcmessage.SignInData
function WelfareBLL:UpdateSignInData(data)
    SelfProxyFactory.GetSignProxy():SignInUpdateReply(data)
    self:UpdateStaminaRed()
    self:UpdateSignRed()
end

---@param serverOpenTime int
function WelfareBLL:SetServerOpenTime(serverOpenTime)
    if serverOpenTime ~= nil then
        self.serverOpenTime = serverOpenTime
    end
    local IsFirstMonth, openDay = self:IsInSameMonth(self.serverOpenTime)
    SelfProxyFactory.GetSignProxy():GetSignData():SetIsFirstMonth(IsFirstMonth)
    SelfProxyFactory.GetSignProxy():GetSignData():SetOpenDay(openDay)
end

---@param id int
---@return bool
function WelfareBLL:IsGetStaminaReward(id)
    local staminaGetMap = SelfProxyFactory.GetSignProxy():GetSignData():GetStaminaGetMap()
    if staminaGetMap == nil then
        return false
    end
    return staminaGetMap[id] or false
end

---获取免费补签体力数据
---@return int 免费补签次数
---@return int 免费补签上限
function WelfareBLL:IsGetFreeStaminaCount()
    return SelfProxyFactory.GetSignProxy():GetSignData():GetFreeStaminaComplementNumber(), SelfProxyFactory.GetSignProxy():GetSignData():GetFreeStaminaComplementLimit()
end

function WelfareBLL:CanGetStamina()
    -- 体力领取
    local time = TimerMgr.GetCurDate()
    local timeSec = TimerMgr.GetCurTimeSeconds()
    ---@type table<StaminaTimeData>
    local staminaTimeTab = SelfProxyFactory.GetSignProxy():GetSignData():GetStaminaTimeTab()
    for i, v in ipairs(staminaTimeTab) do
        if timeSec >= v.minTime and timeSec <= v.maxTime then
            if not self:IsGetStaminaReward(v.id) then
                return true
            end
        elseif timeSec > v.maxTime then
            if not self:IsGetStaminaReward(v.id) then
                local freeStaminaComplementLimit = SelfProxyFactory.GetSignProxy():GetSignData():GetFreeStaminaComplementLimit()
                local freeStaminaComplementNumber = SelfProxyFactory.GetSignProxy():GetSignData():GetFreeStaminaComplementNumber()
                if (freeStaminaComplementLimit > 0 and freeStaminaComplementNumber < freeStaminaComplementLimit) then
                    return true
                end
            end
        end
    end
    return false
end

---@param nowDay int
---return int  1为 签到 0 为未签
function WelfareBLL:GetNowDataSignInState(nowDay)
    local signInFlag = SelfProxyFactory.GetSignProxy():GetSignData():GetSignInFlag()
    local num = (signInFlag >> nowDay & 1)
    return num == 1
end

---@return int
function WelfareBLL:GetFreeCount()
    return SelfProxyFactory.GetSignProxy():GetSignData():GetFreeReSignInNumber()
end

---@return int
function WelfareBLL:GetFreeCountMax()
    return SelfProxyFactory.GetSignProxy():GetSignData():GetFreeReSignInLimit()
end

---@return int
function WelfareBLL:GetIsFristMonth()
    return SelfProxyFactory.GetSignProxy():GetSignData():GetIsFirstMonth()
end

---@return int
function WelfareBLL:GetOpenDay()
    return SelfProxyFactory.GetSignProxy():GetSignData():GetOpenDay()
end

---@param serverOpenTime int
---@return bool
---@return int
function WelfareBLL:IsInSameMonth(serverOpenTime)
    local nowTime = TimerMgr.GetCurTimeSeconds()
    local nowDate = TimerMgr.GetCurDate()
    local serverOpenTimeDate = TimerMgr.GetDateByUnixTimestamp(serverOpenTime)
    if serverOpenTimeDate.hour < 5 then
        serverOpenTime = serverOpenTime - 2600 * 5
        serverOpenTimeDate = TimerMgr.GetDateByUnixTimestamp(serverOpenTime)
    end
    if nowDate.hour < 5 then
        nowTime = nowTime - 3600 * 5
        nowDate = TimerMgr.GetDateByUnixTimestamp(nowTime)
    end
    return (serverOpenTimeDate.month == nowDate.month and serverOpenTimeDate.year == nowDate.year), serverOpenTimeDate.day
end

---@return int signInCount
function WelfareBLL:GetSignInCount()
    local signInCount = 0
    for i = 1, 31 do
        if self:GetNowDataSignInState(i) then
            signInCount = signInCount + 1
        end
    end
    return signInCount
end

---@return bool isCanFree
function WelfareBLL:GetCanFreeSignIn()
    local freeReSignInNumber = SelfProxyFactory.GetSignProxy():GetSignData():GetFreeReSignInNumber()
    local freeReSignInLimit = SelfProxyFactory.GetSignProxy():GetSignData():GetFreeReSignInLimit()
    local isCanFree = freeReSignInNumber < freeReSignInLimit and freeReSignInLimit ~= 0
    return isCanFree
end

---@return int Price
function WelfareBLL:GetReSignInPrice()
    local costReSignInNumber = SelfProxyFactory.GetSignProxy():GetSignData():GetCostReSignInNumber()
    local reCostCountTab = SelfProxyFactory.GetSignProxy():GetSignData():GetReCostCountTab()
    for i, v in ipairs(reCostCountTab) do
        ---@type ResignPrice
        local tab = v
        if costReSignInNumber + 1 >= tab.timesInterval[1] and costReSignInNumber + 1 <= tab.timesInterval[2] then
            return tab.price
        end
    end
end

---@param yearMonthKey int
---@param num int
---@return int  常态 1   已领取 2  可领取 3
function WelfareBLL:GetRewardState(yearMonthKey, num)
    local signTaskData = LuaCfgMgr.Get("SignTask", yearMonthKey, num)
    local rewardsFlag = SelfProxyFactory.GetSignProxy():GetSignData():GetRewardsFlag()
    for i, v in ipairs(rewardsFlag) do
        if signTaskData.ID == v then
            return 2
        end
    end
    local num = signTaskData.NeedSignTimes
    if num <= self:GetSignInCount() then
        return 3
    else
        return 1
    end
end

---红点逻辑
function WelfareBLL:GetSignInRedPointShow()
    local nowTime = self:GetNowTimeWithYearMonthDay(TimerMgr.GetCurTimeSeconds())
    --当日未签到
    --当日可签到
    if not self:GetNowDataSignInState(nowTime.day) then
        return true
    end
    -- 累计签到可领奖
    if self:GetHaveSignTaskReward(nowTime) then
        return true
    end
    --月卡每日奖励
    if BllMgr.GetMonthCardBLLReplace():IsCanGetDailyReward() then
        return true
    end

    local isHaveSignCount = false
    if self:GetIsFristMonth() then
        isHaveSignCount = nowTime.day >= self:GetSignInCount() + self:GetOpenDay()
    else
        isHaveSignCount = nowTime.day > self:GetSignInCount()
    end
    ---免费补签
    if self:GetFreeCount() < self:GetFreeCountMax() and
            isHaveSignCount and
            self:GetFreeCountMax() > 0 then
        return true
    end

    return false
end

---@return bool
function WelfareBLL:GetHaveSignTaskReward(nowtime)
    local haveReward = false
    local yearMonthKey = nowtime.year * 100 + nowtime.month
    ---@type cfg.SignTask[]
    local signRewardData = LuaCfgMgr.Get("SignTask", yearMonthKey)
    if (not signRewardData) then
        return false
    end
    local rewardsFlag = SelfProxyFactory.GetSignProxy():GetSignData():GetRewardsFlag()
    for k, v1 in pairs(signRewardData) do
        local isGetReward = table.containsvalue(rewardsFlag, v1.ID)
        if not isGetReward then
            if v1.NeedSignTimes <= self:GetSignInCount() then
                haveReward = true
                return haveReward
            end
        end
    end
    return haveReward
end

---@return int[]
function WelfareBLL:UpdateTaskRewardIDRp()
    local nowTime = self:GetNowTimeWithYearMonthDay(TimerMgr.GetCurTimeSeconds())
    local yearMonthKey = nowTime.year * 100 + nowTime.month
    ---@type cfg.SignTask[]
    local signRewardData = LuaCfgMgr.Get("SignTask", yearMonthKey)
    if (not signRewardData) then
        return false
    end
    local rewardsFlag = SelfProxyFactory.GetSignProxy():GetSignData():GetRewardsFlag()
    for k, v1 in pairs(signRewardData) do
        local isHaveReward = false
        local isGetReward = table.containsvalue(rewardsFlag, v1.ID)
        if not isGetReward then
            if v1.NeedSignTimes <= self:GetSignInCount() then
                isHaveReward = true
            end
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_SIGN_REWARD, isHaveReward and 1 or 0, v1.ID)
    end
end

--------------福利红点相关-----------------
function WelfareBLL:UpdateWelfareRed()
    self:UpdateSignRed()
    self:UpdateStaminaRed()
end

---签到
function WelfareBLL:UpdateSignRed()
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_SIGN, self:GetSignInRedPointShow() and 1 or 0)
    self:UpdateTaskRewardIDRp()
end

----体力补领
function WelfareBLL:UpdateStaminaRed()
    -- 体力领取
    local timeSec = TimerMgr.GetCurTimeSeconds()
    ---@type table<StaminaTimeData>
    local staminaTimeTab = SelfProxyFactory.GetSignProxy():GetSignData():GetStaminaTimeTab()
    for i, v in ipairs(staminaTimeTab) do
        local num = 0
        if timeSec >= v.minTime and timeSec < v.maxTime then
            if not self:IsGetStaminaReward(v.id) then
                num = 1
            end
        elseif timeSec >= v.maxTime then
            if not self:IsGetStaminaReward(v.id) then
                local freeStaminaComplementLimit = SelfProxyFactory.GetSignProxy():GetSignData():GetFreeStaminaComplementLimit()
                local freeStaminaComplementNumber = SelfProxyFactory.GetSignProxy():GetSignData():GetFreeStaminaComplementNumber()
                if (freeStaminaComplementLimit > 0 and freeStaminaComplementNumber < freeStaminaComplementLimit) then
                    num = 1
                end
            end
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_ENERGY_GET, num, v.id)
    end
end

---------跳转----------------------

local OPENTYPE = {
    ---福利界面
    OPEN_WELFARE = 2,
    ---体力领取界面
    OPEN_POWER = 3,
}

---跳转到福利窗口
function WelfareBLL:JumpWelfareView()
    UIMgr.Open(UIConf.WelfareMainWnd, OPENTYPE.OPEN_WELFARE)
end

---跳转到体力领取界面
function WelfareBLL:JumpReplacePowerView()
    UIMgr.Open(UIConf.WelfareMainWnd, OPENTYPE.OPEN_POWER)
end

return WelfareBLL