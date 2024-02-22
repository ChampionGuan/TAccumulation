﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sms.
--- DateTime: 2023/12/06 17:36

---@class ActivityHangUpProxy 挂机活动功能
local ActivityHangUpProxy = class("ActivityHangUpProxy", BaseProxy)

---@type ActivityHangUpConst
local ActivityHangUpConst = require("Runtime.System.X3Game.GameConst.ActivityHangUpConst")

function ActivityHangUpProxy:OnInit()
    ---@type table<number,pbcmessage.ActivityHangUpData> @ 挂机记录数据
    self.hangUpDataMap = {}
    
    ---@tyep table<number, number> 挂机奖励Map (DIYModel)
    self.rewardItemMap = {}
end

-- 登陆时获取全量数据
---@param hangUpData  pbcmessage.ActivityHangUp @ 挂机活动数据
function ActivityHangUpProxy:SyncAllData(hangUpData)
    if not hangUpData or not hangUpData.HangUpMap then return end
    
    self.hangUpDataMap = table.clone(hangUpData.HangUpMap)
    
    --Debug.LogError("SyncAllData : " .. table.dump({self.hangUpDataMap}))
    
    -- 检查是否有挂机完成的活动进行状态变更
    BllMgr.GetActivityHangUpBLL():CheckRefreshTickTimer()
    
    -- 红点逻辑
    BllMgr.GetActivityHangUpBLL():UpdateAllRedPoint()
end

-- 获取所有挂机数据
---@return table<number,pbcmessage.ActivityHangUpData> @ 挂机记录数据
function ActivityHangUpProxy:GetAllData()
    return self.hangUpDataMap
end

-- 获取指定挂机数据
---@param hangUpId number 挂机Id
function ActivityHangUpProxy:GetDataById(hangUpId)
    return self.hangUpDataMap[hangUpId]
end

-- 挂机加速返回 在这里需要把对应的挂机状态设置为已完成
---@param hangUpId number 挂机Id
function ActivityHangUpProxy:OnHangUpSpeedUp(hangUpId)
    if not hangUpId or table.isnilorempty(self.hangUpDataMap[hangUpId]) then Debug.LogError("ActivityHangUpProxy  数据异常？ " .. tostring(hangUpId)) return end
    
    -- 数据层更新状态
    self.hangUpDataMap[hangUpId].Status = ActivityHangUpConst.HangUpState.Completed
    
    -- 派发事件以通知业务层
    EventMgr.Dispatch(ActivityHangUpConst.EventMap.DataUpdate)
end

-- 领奖返回 这里需要把对应挂机状态改成已领奖
---@param hangUpId number 挂机Id
function ActivityHangUpProxy:OnHangUpRewarded(hangUpId, rewardList)
    if not hangUpId or table.isnilorempty(self.hangUpDataMap[hangUpId]) then Debug.LogError("ActivityHangUpProxy  数据异常？ " .. tostring(hangUpId)) return end

    -- 数据层更新状态
    self.hangUpDataMap[hangUpId].Status = ActivityHangUpConst.HangUpState.Rewarded

    -- 弹出奖励
    UICommonUtil.ShowRewardPopTips(rewardList, 1)

    -- 派发事件以通知业务层
    EventMgr.Dispatch(ActivityHangUpConst.EventMap.DataUpdate)
end

-- 领奖返回 这里需要把对应挂机状态改成进行中
---@param hangUpId number 挂机Id
function ActivityHangUpProxy:OnHangUp(hangUpId, startTime)
    if not hangUpId or not startTime then Debug.LogError("ActivityHangUpProxy  数据异常？ " .. table.dump({hangUpId, startTime})) return end

    -- 数据层更新状态
    self.hangUpDataMap[hangUpId] = {
        Status = ActivityHangUpConst.HangUpState.Progress,
        StartTime = startTime,
    }

    -- 派发事件以通知业务层
    EventMgr.Dispatch(ActivityHangUpConst.EventMap.DataUpdate)
end

-- 登陆时同步全量DIYModel部件Item
function ActivityHangUpProxy:SyncAllDIYModelItem(diyItemMap)
    if table.isnilorempty(diyItemMap) then return end
    
    self.rewardItemMap = diyItemMap
    --Debug.LogError("syncAllDiyModelItem : " .. table.dump({self.rewardItemMap}))
end

-- DIY部件Item奖励发放后数据同步
function ActivityHangUpProxy:SyncDIYModelItem(rewardItems)
    if table.isnilorempty(rewardItems) then return end
    
    self.rewardItemMap = self.rewardItemMap or {}
    for _, itemId in pairs(rewardItems) do
        self.rewardItemMap[itemId] = true
        --Debug.LogError("DIYModel Item 添加: " .. tostring(itemId))
    end
    
    -- 数据更新事件
    EventMgr.Dispatch(ActivityHangUpConst.EventMap.DIYModelItemUpdate)
end

-- 检查DIYModel部件Item是否拥有
function ActivityHangUpProxy:CheckIfDIYModelItemOwned(itemId)
    if not itemId then return end
    
    return self.rewardItemMap[itemId]
end

function ActivityHangUpProxy:OnClear()
    self.hangUpDataMap = {}
end

return ActivityHangUpProxy