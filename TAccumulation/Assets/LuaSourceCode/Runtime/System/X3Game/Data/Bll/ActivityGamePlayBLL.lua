﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2023/12/22 11:48
---@class ActivityGamePlayBLL:BaseBll
local ActivityGamePlayBLL = class("ActivityGamePlayBLL", BaseBll)
local ActivityCenterConst = require("Runtime.System.X3Game.GameConst.ActivityCenterConst")
function ActivityGamePlayBLL:OnInit()
    ---@type table<int> 活动玩法的相关Id
    self.gamePlayActivityId = {}
    EventMgr.AddListener("RoleUnlockEvent", self.OnRoleUnlock, self)
end

---@param activityId int
function ActivityGamePlayBLL:AddActivityGamePlay(activityId)
    local activityCenterCfg = LuaCfgMgr.Get("ActivityCenter", activityId)
    if activityCenterCfg.ActivityType == ActivityCenterConst.ActivityEntryType.GamePlay then
        self:RefreshRP(activityId)
        table.insert(self.gamePlayActivityId, activityId)
    end
end

function ActivityGamePlayBLL:RefreshRP(activityId)
    local activityCenterCfg = LuaCfgMgr.Get("ActivityCenter", activityId)
    local activityIsHaveRpNum = 0
    local gamePlayRestRpNum = 0
    if activityCenterCfg.ActivityShowType == ActivityCenterConst.ActivityGamePlayType.KnockMole then
        local unlockRoleList = BllMgr.GetRoleBLL():GetUnlockedRole()
        if unlockRoleList then
            for k, v in pairs(unlockRoleList) do
                local identify_id = string.concat(tostring(activityId), "_", tostring(k))
                local isHave = self:CheckGamePlayIsFirstRp(activityId, k)
                if isHave then
                    activityIsHaveRpNum = activityIsHaveRpNum + 1
                end
                local isHaveRest = self:CheckGamePlayResetRp(activityId, k)
                if isHaveRest then
                    gamePlayRestRpNum = gamePlayRestRpNum + 1
                end
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEATNEW, isHave and 1 or 0, identify_id)
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEAT, self:CheckGamePlayResetRp(activityId, k) and 1 or 0, identify_id)
            end
        end
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.MOLE_ACTIVITY_NEW, activityIsHaveRpNum, activityId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEAT, gamePlayRestRpNum, activityId)
end

---@param gamePlay  pbcmessage.ActivityGamePlay
function ActivityGamePlayBLL:CheckGamePlayResetRp(activityId, roleId)
    local activityBaseData = SelfProxyFactory.GetActivityCenterProxy():GetActivityBaseData(activityId)
    if activityBaseData.GamePlay and activityBaseData.GamePlay.Details and activityBaseData.GamePlay.Details[roleId] then
        local identify_id = activityId * 100 + roleId
        local lastRefTime = RedPointMgr.GetValue(X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEAT, identify_id)
        local serverLastUpdateTime = activityBaseData.GamePlay.Details[roleId].LastUpdateTime
        if serverLastUpdateTime ~= nil and lastRefTime ~= serverLastUpdateTime then
            return true
        end
    end
    return false
end

function ActivityGamePlayBLL:ClearGamePlayRestRp(activityId)
    local activityBaseData = SelfProxyFactory.GetActivityCenterProxy():GetActivityBaseData(activityId)
    if activityBaseData.GamePlay and activityBaseData.GamePlay.Details then
        for k, v in pairs(activityBaseData.GamePlay.Details) do
            local roleId = k
            local identify_id = activityId * 100 + roleId
            local lastRefTime = activityBaseData.GamePlay.Details[roleId].LastUpdateTime
            if lastRefTime ~= nil then
                RedPointMgr.Save(lastRefTime, X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEAT, identify_id)
            end
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEAT, 0, string.concat(tostring(activityId), "_", tostring(roleId)))
        end
        self:RefreshRP(activityId)
    end
end

function ActivityGamePlayBLL:CheckGamePlayIsFirstRp(activityId, roleId)
    local identify_id = activityId * 100 + roleId
    return RedPointMgr.GetValue(X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEATNEW, identify_id) == 0
end

function ActivityGamePlayBLL:ClearGamePlayIsFirstRpByRoleId(activityId, roleId)
    local identify_id = activityId * 100 + roleId
    RedPointMgr.Save(1, X3_CFG_CONST.RED_FIERYFANTASY_HEARTBEATNEW, identify_id)
    self:RefreshRP(activityId)
end

function ActivityGamePlayBLL:OnRoleUnlock()
    for i = 1, #self.gamePlayActivityId do
        local activityId = self.gamePlayActivityId[i]
        self:RefreshRP(activityId)
    end
end

---判断当前活动关卡是否开启
---@param activityGameGroupCfg
---@return boolean,string
function ActivityGamePlayBLL:CheckUnlockTime(activityGameGroupCfg)
    if activityGameGroupCfg and not string.isnilorempty(activityGameGroupCfg.UnlockTime) then
        local unlockTime = TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(activityGameGroupCfg.UnlockTime))
        if TimerMgr.GetCurTimeSeconds() >= unlockTime then
            return true, nil
        else
            return false, UITextHelper.GetUIText(UITextConst.UI_TEXT_51029, GameHelper.GetLeftTimeDes(unlockTime, nil, nil, true))
        end
    end
    return true, nil
end

return ActivityGamePlayBLL