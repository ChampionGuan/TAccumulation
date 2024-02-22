﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2023/6/28 12:17
---利莫里亚活动Proxy
---@class ActivityScoreProxy:BaseProxy
local ActivityScoreProxy = class("ActivityScoreProxy", BaseProxy)
---@type ActivityScoreConst
local ActivityScoreConst = require("Runtime.System.X3Game.Modules.Activity.ActivityScore.Data.ActivityScoreConst")

function ActivityScoreProxy:OnInit()
    X3DataMgr.Subscribe(X3DataConst.X3Data.Item, self.OnEventBagItemUpdate, self)
end

---获得限时活动任务数据
---@param activityId int 活动id
---@return X3Data.Task[]
function ActivityScoreProxy:GetTaskData(activityId)
    local taskData = {}
    local activityCfg = LuaCfgMgr.Get("ActivityCenter", activityId)
    if activityCfg then
        local groupIds = activityCfg.ActivityTaskGroupID
        for i, groupId in ipairs(groupIds) do
            local isIntegral = activityCfg.ActivityType == 3
            local openDay = (not isIntegral) and 0 or (SelfProxyFactory.GetPlayerInfoProxy():GetCreateRolePassResetDayNum() or 0)
            local openState = SelfProxyFactory.GetActivityCenterProxy():GetActivityActiveState(activityId)
            local isOpen = (not isIntegral) and openState or (openState and openDay >= i)
            local groupConfig = LuaCfgMgr.Get("TaskTableByGroupId", groupId)
            if isOpen and groupConfig then
                for i, taskItem in pairs(groupConfig) do
                    local data = BllMgr.GetTaskBLL():GetTaskInfoById(taskItem.ID)
                    table.insert(taskData, data)
                end
            end
        end
    end
    BllMgr.GetTaskBLL():TaskTabSort(taskData)
    return taskData
end

---@param activityID int
---@param subID int
function ActivityScoreProxy:GetPuzzleData(activityID, subID)
    local activityData = BllMgr.GetActivityCenterBLL():GetActivityBaseData(activityID)
    if activityData and activityData.Jigsaw then
        return activityData.Jigsaw.Progress[subID], activityData.Jigsaw.RewardClaim[subID]
    end
end

---@param activityID int 活动id
---@param subID int 拼图索引
---@param puzzleIndex int 碎片位置索引
function ActivityScoreProxy:SetPuzzleOpenData(activityID, subID, puzzleIndex)
    local activityData = BllMgr.GetActivityCenterBLL():GetActivityBaseData(activityID)
    if activityData and activityData.Jigsaw then
        activityData.Jigsaw.Progress[subID] = activityData.Jigsaw.Progress[subID] and activityData.Jigsaw.Progress[subID] + 2 ^ (puzzleIndex) or 2 ^ (puzzleIndex)
    end
end

---@param activityID int 活动id
---@param subID int 拼图索引
---@param rewardState bool 拼图奖励领取状态
function ActivityScoreProxy:SetPuzzleRewardData(activityID, subID, rewardState)
    local activityData = BllMgr.GetActivityCenterBLL():GetActivityBaseData(activityID)
    if activityData and activityData.Jigsaw then
        activityData.Jigsaw.RewardClaim[subID] = rewardState
    end
end

---@param activityID int 活动id
---@param subID int 拼图索引
function ActivityScoreProxy:IsFinishPuzzleBySubID(activityID, subID)
    local activityData = BllMgr.GetActivityCenterBLL():GetActivityBaseData(activityID)
    local progress = activityData and activityData.Jigsaw and activityData.Jigsaw.Progress[subID] or 0
    local activityCfg = LuaCfgMgr.GetDataByCondition("ActivityMiniPuzzle", { ActivityID = activityID, PageNum = subID })
    local totalCount = activityCfg and activityCfg.PuzzleTotal or 12
    return progress == 2 ^ totalCount - 1
end

---更新消耗红点
function ActivityScoreProxy:UpdatePuzzleGameRed(activityID)
    local puzzleList = LuaCfgMgr.GetListByCondition("ActivityMiniPuzzle", { ActivityID = activityID })
    table.sort(puzzleList, function(a, b)
        return a.PageNum < b.PageNum
    end)
    local count = 0
    local rewardCount = 0
    local pageNum = 0
    self.costIds = {}
    for i, v in pairs(puzzleList) do
        local progress, rewardState = self:GetPuzzleData(v.ActivityID, v.PageNum)
        local isFinish = progress and progress == 2 ^ v.PuzzleTotal - 1
        if not table.containsvalue(self.costIds, v.CostType.ID) then
            table.insert(self.costIds, v.CostType.ID)
        end
        if not isFinish then
            local proBytes, openCount = self:Number2Byte(progress or 0, v.PuzzleTotal)
            local costNum = 0
            if openCount == 0 then
                costNum = v.CostNum[1]
            else
                costNum = openCount + 1 > #v.CostNum and v.CostNum[#v.CostNum] or v.CostNum[openCount + 1]
            end
            local hasNum = BllMgr.GetItemBLL():GetItemNum(v.CostType.ID, v.CostType.Type)
            if hasNum >= costNum then
                count = count + 1
            end
        else
            if not rewardState and v.Reward then
                rewardCount = rewardCount + 1
                pageNum = v.PageNum
            end
        end
        if v.Reward and pageNum == 0 then
            pageNum = v.PageNum
        end
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_ACTIVITY156008_CHIP_AVAILABLE, count)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_ACTIVITY156008_CARD_REWARD, rewardCount)
    return pageNum, rewardCount
end

---更新利莫里亚任务红点
function ActivityScoreProxy:UpdateTaskRewardRed(activityID)
    if activityID ~= ActivityScoreConst.ActivityCardID then
        return
    end
    --判断活动是否生效
    if not SelfProxyFactory.GetActivityCenterProxy():GetActivityActiveState(activityID) then
        return
    end
    local rewardList = LuaCfgMgr.GetListByCondition("ActivityReward", { ActivityID = activityID })
    local baseData = BllMgr.GetActivityCenterBLL():GetActivityBaseData(activityID)
    if not baseData then
        return
    end
    local curProgress = baseData.Point
    local needGet = {}
    local getRewardIds = {}
    local rewardData = nil
    local maxRank = table.nums(rewardList)
    local maxProgress = 0
    local getState = ActivityScoreConst.TaskRewardState.Normal
    for i, v in pairs(rewardList) do
        local notGet = baseData.Reward.Rewarded[v.Rank]
        if curProgress >= v.ConditionCheck[3] then
            needGet[v.Rank] = not notGet
            if not notGet then
                table.insert(getRewardIds, v.Rank)
            end
        end
    end
    if table.nums(needGet) == 0 then
        getState = ActivityScoreConst.TaskRewardState.Normal
    else
        if #getRewardIds > 0 then
            getState = ActivityScoreConst.TaskRewardState.CanGet
        else
            getState = ActivityScoreConst.TaskRewardState.Got
        end
    end
    for i, v in pairs(rewardList) do
        local num = v.ConditionCheck[3]
        if curProgress < num or (v.Rank == maxRank and curProgress > num) then
            maxProgress = num
            rewardData = v.ShowRewards[1]
            break
        end
    end
    local count = 0
    if getState == ActivityScoreConst.TaskRewardState.CanGet then
        count = 1
    end
    local getCount = 0
    local taskData = self:GetTaskData(activityID)
    for i, v in pairs(taskData) do
        if v:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
            getCount = getCount + 1
            break
        end
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_ACTIVITY156008_TASK_REWARD, getCount)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_ACTIVITY156008_TASK_CHIP_REWARD, count)
    return getState, curProgress, maxProgress, getRewardIds, rewardData
end

---@param item_data pbcmessage.Item
function ActivityScoreProxy:OnEventBagItemUpdate(item_data)
    if table.containsvalue(self.costIds, item_data and item_data.Id) then
        self:UpdatePuzzleGameRed(ActivityScoreConst.PuzzleActivityID)
    end
end

---十进制转二进制（算12位）
---@param num number 转换对象
---@param bytes number 位数
function ActivityScoreProxy:Number2Byte(num, bytes)
    local result = {}
    local openCount = 0
    for i = bytes, 1, -1 do
        result[i] = math.floor(num / 2 ^ (i - 1))
        num = num % 2 ^ (i - 1)
        if result[i] == 1 then
            openCount = openCount + 1
        end
    end
    return result, openCount
end

return ActivityScoreProxy