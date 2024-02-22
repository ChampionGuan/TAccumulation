﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by aoliao.
--- DateTime: 2023/9/14 20:00
---ActivityGrowUpBLL
---@class ActivityGrowUpBLL:BaseBll
local ActivityGrowUpBLL = class("ActivityGrowUpBLL", BaseBll)
local ActivityGrowUpConst = require("Runtime.System.X3Game.Modules.Activity.ActivityGrowUp.Data.ActivityGrowUpConst")
----------------------------------------新版接口Start-----------------------------------------------------
---@param newbieData pbcmessage.NewbieData
function ActivityGrowUpBLL:Init(newbieData)
    newbieData = newbieData or {}
    EventMgr.AddListener("EVENT_LEVEL_UP", self.OnPlayerLevelUp, self)
    self:UpdateNewbieData(newbieData.RewardedList)
end

function ActivityGrowUpBLL:OnInit()
    self.proxy = SelfProxyFactory.GetActivityGrowUpProxy()
end

function ActivityGrowUpBLL:OnClear()
    EventMgr.RemoveListenerByTarget(self)
end

function ActivityGrowUpBLL:OnPlayerLevelUp(level)
    local haveRedPoint = self:CheckRedPoint()
    EventMgr.Dispatch(ActivityGrowUpConst.Event.NewBieRewardUpdate)
end

---@return table 新手成长活动数据
---@return boolean 是否有可领奖励
---@return boolean 是否有未解锁奖励
function ActivityGrowUpBLL:GetGrowUpData()
    local growUpData = {}
    local curLevel = SelfProxyFactory.GetPlayerInfoProxy():GetLevel()
    local rewards = self:GetRewardedList()
    local rawConfig = LuaCfgMgr.GetAll("NewPlayerGrowUp")
    local haveCanReceive = false
    local haveUnlock = false

    for k, v in pairs(rawConfig) do
        local tempTable = table.clone(v,true)
        if table.containsvalue(rewards,tempTable.ID) then
            tempTable.newBieRewardState = ActivityGrowUpConst.NewBieRewardState.Received
        else
            if tempTable.LevelGrade <= curLevel then
                haveCanReceive = true
                tempTable.newBieRewardState = ActivityGrowUpConst.NewBieRewardState.NotReceived
            else
                haveUnlock = true
                tempTable.newBieRewardState = ActivityGrowUpConst.NewBieRewardState.Lock
            end
        end
        table.insert(growUpData,tempTable)
    end
    table.sort(growUpData, function(a,b)
        return a.Rank < b.Rank
    end)
    return growUpData,haveCanReceive,haveUnlock
end

---@return table
function ActivityGrowUpBLL:GetRewardedList()
    return self.proxy:GetRewardedList()
end
---@param newBieRewardId number 奖励ID
---@return boolean 是否领奖了
function ActivityGrowUpBLL:GetIsGetNewBieReward(newBieRewardId)
    local rewards = self:GetRewardedList()
    for i, v in ipairs(rewards) do
        if v == newBieRewardId then
            return true
        end
    end
    return false
end

---@param newbieData pbcmessage.NewbieData
function ActivityGrowUpBLL:UpdateNewbieData(newbieData)
    local rewardedList = self.proxy:GetRewardedList() or {}
    local rewardedListCount = #rewardedList
    for i, v in ipairs(newbieData or {}) do
        self.proxy:AddOrUpdateRewardedListValue(i+rewardedListCount,v)
    end
    self:CheckRedPoint()
end

function ActivityGrowUpBLL:CheckRedPoint()
    local _ , haveCanReceive = self:GetGrowUpData()
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_ACTIVITY_GROWUP_BANNER_REWARD, haveCanReceive and 1 or 0)
    return haveCanReceive
end

---@param param table<int>
function ActivityGrowUpBLL:RequestNewbieReward(param)
    GrpcMgr.SendRequest(RpcDefines.GetNewbieRewardRequest,{NewbieIDList = param},true)
end

---@param id number condition枚举
---@param datas table<int,string> 看表吧CommonCondition
---@return bool 检查是否通过
function ActivityGrowUpBLL:CheckCondition(id, datas)
    if id == X3_CFG_CONST.CONDITION_NEWPLAYERGROWUP_DONE then
        local logicSign = tonumber(datas[1]) == 0  ---玩家在新手成长活动种是否领取完了所有奖励 是1 ，否0，默认0
        local _ , haveCanReceive , haveUnlock = self:GetGrowUpData()
        return (haveCanReceive or haveUnlock) == logicSign
    end
    return false
end

return ActivityGrowUpBLL