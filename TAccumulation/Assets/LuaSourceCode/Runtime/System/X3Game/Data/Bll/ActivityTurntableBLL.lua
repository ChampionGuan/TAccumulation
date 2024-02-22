﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by afan002.
--- DateTime: 2023/11/7 16:09
---

---@class ActivityTurntableBLL:BaseBll
local ActivityTurntableBLL = class("ActivityTurntableBLL", BaseBll)

local ActivityCenterConst = require("Runtime.System.X3Game.GameConst.ActivityCenterConst")

--region Base Func

---统一初始化，只会调用一次
function ActivityTurntableBLL:OnInit(...)
    TimerMgr.DiscardTimerByTarget(self)
    X3DataMgr.Subscribe(X3DataConst.X3Data.Activity, self.OnUpdateActivityActive, self, X3DataConst.X3DataField.Activity.active)
end

---统一检测条件
---@return boolean,int 是否满足条件，返回满足当前条件的数量
function ActivityTurntableBLL:CheckCondition(id, ...)

end

---断线重连
function ActivityTurntableBLL:OnReconnect()
    TimerMgr.DiscardTimerByTarget(self)
end

---红点刷新检测
---@param redId number 红点配置id
function ActivityTurntableBLL:OnRedPointCheck(redId)

end

---@param x3Data X3Data.Activity
function ActivityTurntableBLL:OnUpdateActivityActive(x3Data)
    local activityID = x3Data:GetPrimaryValue()
    if not activityID then
        return
    end

    local activityCenterCfg = LuaCfgMgr.Get("ActivityCenter", activityID)
    if not activityCenterCfg or activityCenterCfg.ActivityType ~= ActivityCenterConst.ActivityEntryType.ActivityTurntable then
        return
    end

    --Debug.LogErrorFormatWithTag("====", "activityID : %s active : %s", activityID, tostring(x3Data:GetActive()))

    BllMgr.GetActivityTurntableBLL():RedPointCheck(X3_CFG_CONST.RED_TURNTABLE_START, activityID)
    BllMgr.GetActivityTurntableBLL():RedPointCheck(X3_CFG_CONST.RED_TURNTABLE_NEWPV, activityID)
    BllMgr.GetActivityTurntableBLL():RedPointCheck(X3_CFG_CONST.RED_TURNTABLE_FREE, activityID)
    BllMgr.GetActivityTurntableBLL():RedPointCheck(X3_CFG_CONST.RED_TURNTABLE_REWARD, activityID)
end

--endregion

--region 红点

---免费抽奖次数红点
---@param activityID int 活动ID
function ActivityTurntableBLL:RefreshFreeResetTimeTimer(activityID)
    if not self.nextFreeTimerDic then
        self.nextFreeTimerDic = {}
    end

    if self.nextFreeTimerDic[activityID] then
        TimerMgr.Discard(self.nextFreeTimerDic[activityID])
    end

    local count = 0

    local cmsCfg = BllMgr.GetActivityCenterBLL():GetActivityCMSConfig(activityID)
    local open = BllMgr.GetActivityCenterBLL():GetOpenState(cmsCfg, true)
    if open then
        local hasFreeTime = SelfProxyFactory.GetActivityTurntableProxy():HasFreeTime(activityID)
        if hasFreeTime then
            count = 1
        else
            local data = SelfProxyFactory.GetActivityTurntableProxy():GetData(activityID)
            local nextFreeTime = data:GetNextFreeResetTime()
            local leftTime = nextFreeTime - TimerMgr.GetCurTimeSeconds()
            if leftTime > 0 then
                self.nextFreeTimerDic[activityID] = TimerMgr.AddTimer(leftTime, function() self:RefreshFreeResetTimeTimer(activityID) end, self)
            else
                count = 1
            end
        end
    end

    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_TURNTABLE_FREE, count, activityID)

    --Debug.LogErrorFormatWithTag("====", "RED_TURNTABLE_FREE activityID : %s count : %s", activityID, count)
end

---刷新PV红点
---@param activityID int 活动ID
function ActivityTurntableBLL:RefreshPVRedPoint(activityID)
    local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_TURNTABLE_NEWPV, activityID)
    local curValue = value

    local cmsCfg = BllMgr.GetActivityCenterBLL():GetActivityCMSConfig(activityID)
    local open = BllMgr.GetActivityCenterBLL():GetOpenState(cmsCfg, true)
    if open then
        if curValue < 1 then
            local activityCfg = LuaCfgMgr.Get("ActivityCenter", activityID)
	        if activityCfg then
	            if string.isnilorempty(activityCfg.ActivityPV) then
	                curValue = 1
	            end
	        else
        	    Debug.Log("ActivityCenter cfg is Null!!!,cfgId => ",activityID)
    	    end
        end
    else
        curValue = 1
    end

    if curValue ~= value then
        RedPointMgr.Save(1, X3_CFG_CONST.RED_TURNTABLE_NEWPV, activityID)
    end

    local count = curValue < 1 and 1 or 0
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_TURNTABLE_NEWPV, count, activityID)

    --Debug.LogErrorFormatWithTag("====", "RED_TURNTABLE_NEWPV activityID : %s count : %s", activityID, count)
end

---刷新抽数奖励红点
---@param activityID int 活动ID
function ActivityTurntableBLL:RefreshCountRewardRedPoint(activityID)
    local turntableCfg = LuaCfgMgr.Get("ActivityTurntable", activityID)
    if not turntableCfg then
        return
    end

    local countReward = turntableCfg.CountReward

    --更新抽数奖励ID对应的红点
    local drawCount = SelfProxyFactory.GetActivityTurntableProxy():GetDrawCount(countReward)
    local countRewardCfgList = LuaCfgMgr.GetListByCondition("ActivityCountReward", { RewardGroup = countReward })
    local hasReward = false
    for i, cfg in pairs(countRewardCfgList) do
        local count = 0
        local canGet = cfg.CountGroup <= drawCount and not SelfProxyFactory.GetActivityTurntableProxy():CheckCountRewardIsGot(cfg.ID)
        if canGet then
            count = 1
            hasReward = true
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_TURNTABLE_REWARD, count, cfg.ID)

        --Debug.LogErrorFormatWithTag("====", "RED_TURNTABLE_REWARD ID : %s count : %s", cfg.ID, count)
    end

    --更新所有抽数奖励池为countReward的活动的抽数奖励红点
    ---@type table<int, X3Data.ActivityTurntableData>
    local ret = PoolUtil.GetTable()
    X3DataMgr.GetAll(X3DataConst.X3Data.ActivityTurntableData, ret, function(data)
        return data:GetCountReward() == countReward
    end)

    for _, v in pairs(ret) do
        local count = 0
        if hasReward then
            count = 1
        end
        local curActivityID = v:GetPrimaryValue()
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_TURNTABLE_REWARD, count, curActivityID)

        --Debug.LogErrorFormatWithTag("====", "RED_TURNTABLE_REWARD activityID : %s count : %s", curActivityID, count)
    end

    PoolUtil.ReleaseTable(ret)
end

--endregion

--region protocol

---抽奖
---@param activityID int 活动ID
---@param drawCount int 连抽次数
function ActivityTurntableBLL:SendActivityTurntableDrawRequest(activityID, drawCount, errandDelay)
    if errandDelay then
        ErrandMgr.SetDelay(true)
    end

    local msg = {
        ActivityID = activityID,
        DrawCount = drawCount,
    }
    GrpcMgr.SendRequest(RpcDefines.ActivityTurntableDrawRequest, msg, true)
end

---领取抽数奖励
---@param activityID int 活动ID
function ActivityTurntableBLL:SendActivityTurntableCountRewardRequest(activityID)
    local msg = {
        ActivityID = activityID,
    }
    GrpcMgr.SendRequest(RpcDefines.ActivityTurntableCountRewardRequest, msg, true)
end

--endregion

--region 外调

---红点刷新检测
---@param redId int 红点配置id
---@param activityID int 活动ID
function ActivityTurntableBLL:RedPointCheck(redId, activityID)
    if redId == X3_CFG_CONST.RED_TURNTABLE_START then
        local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_TURNTABLE_START, activityID)
        local count = value < 1 and 1 or 0
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_TURNTABLE_START, count, activityID)

        --Debug.LogErrorFormatWithTag("====", "RED_TURNTABLE_START : %s ", count)
    elseif redId == X3_CFG_CONST.RED_TURNTABLE_FREE then
        self:RefreshFreeResetTimeTimer(activityID)
    elseif redId == X3_CFG_CONST.RED_TURNTABLE_NEWPV then
        self:RefreshPVRedPoint(activityID)
    elseif redId == X3_CFG_CONST.RED_TURNTABLE_REWARD then
        self:RefreshCountRewardRedPoint(activityID)
    end
end

---发起转盘抽奖
---@param activityID int 活动ID
---@param isMultiDraw bool 是否是多抽
function ActivityTurntableBLL:TurntableDraw(activityID, isMultiDraw, errandDelay)
    local activityTurntableCfg = LuaCfgMgr.Get("ActivityTurntable", activityID)

    local costItemID = activityTurntableCfg.CostTicket.ID
    local costItemCfg = LuaCfgMgr.Get("Item", costItemID)
    --已有
    local costItemNum = BllMgr.GetItemBLL():GetItemNum(costItemID)
    --消耗
    local costCount
    local drawTimes
    if isMultiDraw then
        drawTimes = activityTurntableCfg.DrawTimes
        costCount = activityTurntableCfg.Cost
    else
        drawTimes = 1
        local hasFreeTimes = SelfProxyFactory.GetActivityTurntableProxy():HasFreeTime(activityID)
        costCount = hasFreeTimes and 0 or activityTurntableCfg.Cost1
    end

    local canDraw = costItemNum >= costCount
    if canDraw then
        self:SendActivityTurntableDrawRequest(activityID, drawTimes, errandDelay)
    else
        if costItemID == X3_CFG_CONST.ITEM_TYPE_JEWEL then
            -- 星钻不够去兑换
            UICommonUtil.BuyItemWithJewel(costCount, function()
                self:SendActivityTurntableDrawRequest(activityID, drawTimes, errandDelay)
            end)
        elseif costItemID == X3_CFG_CONST.ITEM_TYPE_STARDIAMOND then
            UICommonUtil.ShowBuyStarDiamond(costCount)
        else
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9477, UITextHelper.GetUIText(costItemCfg.Name))
        end
    end
end


---检查是否需要显示转化提示弹窗
---@param activityID int 活动ID
function ActivityTurntableBLL:CheckShowTransferTips(activityID, callBack)
    if not activityID then
        return
    end

    local turnTableCfg = LuaCfgMgr.Get("ActivityTurntable", activityID)
    if not turnTableCfg then
        return
    end

    local transferDropIDList = {}
    local persistentData = SelfProxyFactory.GetActivityTurntableProxy():GetPersistentData(activityID)
    local transferData = persistentData:GetTransferData()
    local dropCfgList = LuaCfgMgr.GetListByCondition("ActivityTurntableDrop", { Drop = turnTableCfg.Drop })
    for i, dropCfg in ipairs(dropCfgList) do
        local dropState = self:GetDropState(activityID, dropCfg.ID)
        if (not transferData or not transferData[dropCfg.ID]) and dropState == X3DataConst.ActivityTurntableDropState.ActivityTurntableDropStateTransfer then
            table.insert(transferDropIDList, dropCfg.ID)
            persistentData:AddOrUpdateTransferDataValue(dropCfg.ID, true)
        end
    end

    if #transferDropIDList > 0 then
        local activityCenterCfg = LuaCfgMgr.Get("ActivityCenter", activityID)
        if activityCenterCfg then
            local params = {
                prefabName = activityCenterCfg.ActivityPrefab[2],
                activityID = activityID,
                transferDropIDList = transferDropIDList,
                callBack = callBack,
            }
            ErrandMgr.Add(X3_CFG_CONST.POPUP_ACTIVITY_TURNTABLE_TRANSFER, params)
        end
    end
end

---获取奖励状态
---@param activityID int 活动ID
---@param dropID int ActivityTurntableDrop.ID
function ActivityTurntableBLL:GetDropState(activityID, dropID)
    local dropState = X3DataConst.ActivityTurntableDropState.ActivityTurntableDropStateNormal

    local dropCfg = LuaCfgMgr.Get("ActivityTurntableDrop", dropID)
    if not dropCfg then
        return dropState
    end

    --条件检测
    if dropCfg.ConditionCheck and ConditionCheckUtil.CheckConditionByIntList(dropCfg.ConditionCheck) then
        dropState = X3DataConst.ActivityTurntableDropState.ActivityTurntableDropStateTransfer
    end

    --抽中次数检测
    if dropCfg.ItemLimit and dropCfg.ItemLimit > 0 then
        local dropCount = SelfProxyFactory.GetActivityTurntableProxy():GetDropCount(activityID, dropID)
        if dropCount >= dropCfg.ItemLimit then
            if dropCfg.ItemRemove == 1 then
                dropState = X3DataConst.ActivityTurntableDropState.ActivityTurntableDropStateRemove
            else
                dropState = X3DataConst.ActivityTurntableDropState.ActivityTurntableDropStateTransfer
            end
        end
    end

    return dropState
end

--endregion

return ActivityTurntableBLL