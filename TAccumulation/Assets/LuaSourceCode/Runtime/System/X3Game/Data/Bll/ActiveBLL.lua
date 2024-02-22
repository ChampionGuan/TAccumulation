---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-05-14 12:04:16
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class ActiveBLL
local ActiveBLL = class("ActiveBLL", BaseBll)
function ActiveBLL:Init(active)
    self.activeData = active
    self.dayTimerId = 0
    self.weekTimerId = 0
    self.activeData.DayNextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(active.DayLastRefreshTime, Define.DateRefreshType.Day)
    self.activeData.WeekNextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(active.WeekLastRefreshTime, Define.DateRefreshType.Week)
    self:RefreshActiveRed()
    self:AddTimer()
end

function ActiveBLL:ActiveUpdateCallBack(data)
    self.activeData = data.Active
    self.activeData.DayNextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(data.Active.DayLastRefreshTime, Define.DateRefreshType.Day)
    self.activeData.WeekNextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(data.Active.WeekLastRefreshTime, Define.DateRefreshType.Week)
    self:RefreshActiveRed()
end

function ActiveBLL:GetActiveByType(type)
    local retTab = {}
    if type == 1 then
        retTab["ActiveNum"] = self.activeData.DayActive
        retTab["NextRefreshTime"] = self.activeData.DayNextRefreshTime
    else
        retTab["ActiveNum"] = self.activeData.WeekActive
        retTab["NextRefreshTime"] = self.activeData.WeekNextRefreshTime
    end
    return retTab
end

function ActiveBLL:GetMaxGiftRewardIsGet(type)
    local activeRewardList = self:GetGiftDataTabByType(type)
    local ret = true
    for i = 1, #activeRewardList do
        if not self:IsGetAciveReward(activeRewardList[i].ID) then
            return false
        end
    end
    return ret
end

function ActiveBLL:GetGiftDataTabByType(type)
    local retTab = {}
    local allActiveRewardCfg = LuaCfgMgr.GetAll("ActiveReward")
    for k, v in pairs(allActiveRewardCfg) do
        if v.RewardCycle == type then
            table.insert(retTab, v)
        end
    end
    table.sort(retTab, function(a, b)
        if a.ConditionCount == b.ConditionCount then
            return a.ID < b.ID
        else
            return a.ConditionCount < b.ConditionCount
        end
    end)
    return retTab
end

function ActiveBLL:IsHaveGetReward(type)
    local ret = false
    local curActiveNum = 0
    if type == 1 then
        curActiveNum = self.activeData.DayActive
    else
        curActiveNum = self.activeData.WeekActive
    end
    local giftDataTab = self:GetGiftDataTabByType(type)
    for i = 1, #giftDataTab do
        if not self:IsGetAciveReward(giftDataTab[i].ID) then
            if curActiveNum >= giftDataTab[i].ConditionCount then
                if type == 1 then
                    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_TASK_DAY_ACTIVITY, 1, giftDataTab[i].ID)
                else
                    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_TASK_WEEK_ACTIVITY, 1, giftDataTab[i].ID)
                end
                ret = true
            else
                if type == 1 then
                    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_TASK_DAY_ACTIVITY, 0, giftDataTab[i].ID)
                else
                    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_TASK_WEEK_ACTIVITY, 0, giftDataTab[i].ID)
                end
            end
        else
            if type == 1 then
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_TASK_DAY_ACTIVITY, 0, giftDataTab[i].ID)
            else
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WELFARE_TASK_WEEK_ACTIVITY, 0, giftDataTab[i].ID)
            end
        end
    end
    return ret
end

function ActiveBLL:RestReward(type)
    if self.activeData.RewardMap == nil then
        return
    end
    local giftDataTab = self:GetGiftDataTabByType(type)
    for i = 1, #giftDataTab do
        self.activeData.RewardMap[giftDataTab[i].ID] = nil
    end
end

function ActiveBLL:GetActiveRewardList(activeId)
    local activeRewardCfg = LuaCfgMgr.Get("ActiveReward", activeId)
    local rewardGroupTab = self:GetActiveRewardGroupTab(activeRewardCfg.RewardContent)
    local retRewardTab = nil
    local allRewardTab = {}
    for i = 1, #rewardGroupTab do
        local tempRewardGroupCfg = rewardGroupTab[i]
        if self:CheckRewardTime(tempRewardGroupCfg) then
            table.insert(allRewardTab, tempRewardGroupCfg)
        end
    end
    table.sort(allRewardTab, function(a, b)
        return a.Priority > b.Priority
    end)
    if #allRewardTab > 0 then
        retRewardTab = allRewardTab[1]
    end
    if retRewardTab ~= nil then
        return retRewardTab.RewardItem
    end
    return retRewardTab
end

function ActiveBLL:CheckRewardTime(rewardGroupCfg)
    local startTime = nil
    local endTime = nil
    if tonumber(rewardGroupCfg.StartTime) ~= -1 or tonumber(rewardGroupCfg.EndTime) ~= -1 then
        if tonumber(rewardGroupCfg.StartTime) ~= -1 then
            startTime = TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(tostring(rewardGroupCfg.StartTime)))
        end
        if tonumber(rewardGroupCfg.EndTime) ~= -1 then
            endTime = TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(tostring(rewardGroupCfg.EndTime)))
        end
        local curTime = TimerMgr.GetCurTimeSeconds()

        if startTime ~= nil and endTime ~= nil then
            if startTime < curTime and endTime > curTime then
                ret = true
            end
        elseif startTime ~= nil then
            if startTime < curTime then
                return true
            end
        else
            if endTime > curTime then
                return true
            end
        end
    else
        return true
    end
    return false
end

function ActiveBLL:GetActiveRewardGroupTab(groupId)
    local retTab = {}
    local allRewardGroupTab = LuaCfgMgr.GetAll("ActiveRewardGroup")

    for k, v in pairs(allRewardGroupTab) do
        if v.GroupID == groupId then
            table.insert(retTab, v)
        end
    end
    return retTab
end

function ActiveBLL:IsGetAciveReward(activeId)
    if table.containskey(self.activeData.RewardMap, activeId) then
        if self.activeData.RewardMap[activeId] ~= nil then
            return true
        end
    end
    return false
end

---发送服务器消息
function ActiveBLL:SendGetActiveRewardById(activeId)
    local messageBody = PoolUtil.GetTable()
    local idList = PoolUtil.GetTable()
    table.insert(idList, activeId)
    messageBody.ActiveIDList = idList
    GrpcMgr.SendRequest(RpcDefines.GetActiveRewardRequest, messageBody)
    PoolUtil.ReleaseTable(idList)
    PoolUtil.ReleaseTable(messageBody)
end

function ActiveBLL:SendGetActiveRewardOneKey(dayOrWeek, taskIdList)
    local messageBody = PoolUtil.GetTable()
    messageBody.DayOrWeek = dayOrWeek
    messageBody.TaskIDList = taskIdList
    GrpcMgr.SendRequestAsync(RpcDefines.GetActiveRewardOneKeyRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

function ActiveBLL:SendAskReset(resetType)
    if resetType == nil then
        resetType = 0
    end
    local messageBody = PoolUtil.GetTable()
    messageBody.ResetType = 0
    GrpcMgr.SendRequestAsync(RpcDefines.AskResetRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

function ActiveBLL:SendGetActiveRewardByList(idList)
    local messageBody = PoolUtil.GetTable()
    messageBody.ActiveIDList = idList
    GrpcMgr.SendRequest(RpcDefines.GetActiveRewardRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

------------------活跃度红点相关-----------------------------
function ActiveBLL:RefreshActiveRed(checkType)
    if checkType then
        local is_can_get_reward = self:IsHaveGetReward(checkType)
        BllMgr.GetTaskBLL():RefreshActiveRed(checkType, is_can_get_reward and 1 or 0)
    else
        local check_types = { Define.EumTaskType.Day, Define.EumTaskType.Week }
        for k, v in pairs(check_types) do
            local is_can_get_reward = self:IsHaveGetReward(k)
            BllMgr.GetTaskBLL():RefreshActiveRed(k, is_can_get_reward and 1 or 0)
        end
    end
end

function ActiveBLL:AddTimer()
    if self.dayTimerId ~= 0 then
        TimerMgr.Discard(self.dayTimerId)
    end
    local curTime = TimerMgr.GetCurTimeSeconds()
    local nextTime = self.activeData.DayNextRefreshTime - curTime
    self.dayTimerId = TimerMgr.AddTimer(nextTime,
            function()
                self:RefreshActiveData()
            end)
end

function ActiveBLL:RefreshActiveData()
    local isHaveWeek = false
    local curTime = TimerMgr.GetCurTimeSeconds()
    if self.activeData.WeekNextRefreshTime - curTime <= 1 then
        isHaveWeek = true
    end
    self:CheckSendGetReward(isHaveWeek)
    self.activeData.DayActive = 0
    self.activeData.DayNextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(TimerMgr.GetCurTimeSeconds(), Define.DateRefreshType.Day)
    if isHaveWeek then
        self.activeData.WeekActive = 0
        self.activeData.WeekNextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(TimerMgr.GetCurTimeSeconds(), Define.DateRefreshType.Week)
    end
    if isHaveWeek then
        self.activeData.RewardMap = nil
        self:RefreshActiveRed()
    else
        self:RestReward(Define.EumTaskType.Day)
        self:RefreshActiveRed(Define.EumTaskType.Day)
    end
    EventMgr.Dispatch("TaskDayRefEvent", isHaveWeek)
    EventMgr.Dispatch("OnActiveUpdateCallBack")
    self:AddTimer()
end

---刷新时检测是否有可领取 奖励
function ActiveBLL:CheckSendGetReward(isHaveWeek)
    if self:IsHaveReward(isHaveWeek) then
        ---@type cfg.s2int
        local randomS2Int = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DAILYWEEKLYREFRESHDELAY)
        local delayTime = math.random(randomS2Int.ID, randomS2Int.Num)
        TimerMgr.AddTimer(delayTime, function()
            self:SendAskReset()
        end)
    end
end

function ActiveBLL:IsHaveReward(isHaveWeek)
    if self:IsHaveGetReward(Define.EumTaskType.Day) then
        return true
    end
    if isHaveWeek and self:IsHaveGetReward(Define.EumTaskType.Week) then
        return true
    end
    return false
end

return ActiveBLL