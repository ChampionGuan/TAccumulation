﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2023/12/15 15:42
--- 活动剧情数据处理

---@class ActivityDialogueProxy:BaseProxy
local ActivityDialogueProxy = class("ActivityDialogueProxy", BaseProxy)

function ActivityDialogueProxy:Init()

end

---@param activityID int
---@param dialogData_server pbcmessage.ActivityDialogue
function ActivityDialogueProxy:AddActivityDialogueData(activityID, dialogData_server)
    local activityDialogueData_X3 = X3DataMgr.Get(X3DataConst.X3Data.ActivityDialogue, activityID)
    local sourceTab = {
        ActivityId = activityID,
        MaleID = dialogData_server.MaleID,
        UnlockIDs = dialogData_server.UnlockIDs,
        FinishIDs = dialogData_server.FinishIDs
    }
    if activityDialogueData_X3 == nil then
        activityDialogueData_X3 = X3DataMgr.AddByPrimary(X3DataConst.X3Data.ActivityDialogue, sourceTab, activityID)
    else
        X3DataMgr.Update(X3DataConst.X3Data.ActivityDialogue, activityID, sourceTab)
    end
end

---@param activityID int
---@return X3Data.ActivityDialogue
function ActivityDialogueProxy:GetActivityDialogueData(activityID)
    return X3DataMgr.Get(X3DataConst.X3Data.ActivityDialogue, activityID)
end

---@param activityID int
---@return int | nil
function ActivityDialogueProxy:GetActivityDialogueMaleID(activityID)
    if self:GetActivityDialogueData(activityID) == nil then
        return nil
    end
    return self:GetActivityDialogueData(activityID):GetMaleID()
end

---@param activityID int
---@param maleID int
function ActivityDialogueProxy:SetActivityDialogueMaleID(activityID, maleID)
    self:GetActivityDialogueData(activityID):SetMaleID(maleID)
end

---获取解锁剧情列表
---@param activityID int
---@return int[]
function ActivityDialogueProxy:GetActivityDialogueUnlockIDs(activityID)
    return self:GetActivityDialogueData(activityID):GetUnlockIDs()
end

---获取完成剧情列表
---@param activityID int
---@return int[]
function ActivityDialogueProxy:GetActivityDialogueFinishIDs(activityID)
    if (not activityID) or self:GetActivityDialogueData(activityID) == nil then
        return nil
    end
    return self:GetActivityDialogueData(activityID):GetFinishIDs()
end

---@param activityDialogueID int
---@return bool
function ActivityDialogueProxy:IsDialogueUnlock(activityDialogueID)
    ---@type cfg.ActivityDialogue
    local activityDialogueData_cfg = LuaCfgMgr.Get("ActivityDialogue", activityDialogueID)
    local activityID = activityDialogueData_cfg.ActivityID
    local unlockIDs = self:GetActivityDialogueUnlockIDs(activityID)
    for k, v in pairs(unlockIDs) do
        if v == activityDialogueID then
            return true
        end
    end
    return false
end

---@param activityDialogueID int
function ActivityDialogueProxy:IsDialogueFinish(activityDialogueID)
    ---@type cfg.ActivityDialogue
    local activityDialogueData_cfg = LuaCfgMgr.Get("ActivityDialogue", activityDialogueID)
    local activityID = activityDialogueData_cfg and activityDialogueData_cfg.ActivityID
    local finishIDs = self:GetActivityDialogueFinishIDs(activityID)
    if finishIDs == nil then
       return false
    end
    for k, v in pairs(finishIDs) do
        if v == activityDialogueID then
            return true
        end
    end
    return false
end

--region message 活动剧情服务器协议处理

---@param data pbcmessage.ActivityDialogueUnlockRequest
function ActivityDialogueProxy:OnActivityDialogueUnlockReply(data)
    local activityDialogueData_X3 = X3DataMgr.Get(X3DataConst.X3Data.ActivityDialogue, data.ActivityID)
    local index = activityDialogueData_X3:GetUnlockIDs() == nil and 1 or #activityDialogueData_X3:GetUnlockIDs() + 1
    activityDialogueData_X3:AddOrUpdateUnlockIDsValue(index, data.DialogueID)
end

---@param data pbcmessage.ActivityDialogueFinishRequest
---@param reply pbcmessage.ActivityDialogueFinishReply
function ActivityDialogueProxy:OnActivityDialogueFinishReply(data, reply)
    local activityDialogueData_X3 = X3DataMgr.Get(X3DataConst.X3Data.ActivityDialogue, data.ActivityID)
    local index = activityDialogueData_X3:GetFinishIDs() == nil and 1 or #activityDialogueData_X3:GetFinishIDs() + 1
    activityDialogueData_X3:AddOrUpdateFinishIDsValue(index, data.DialogueID)
    --Debug.LogError("OnActivityDialogueFinishReply")
    --Debug.LogErrorTable(data)
    if not table.isnilorempty(reply.RewardList) then
        UICommonUtil.ShowRewardPopTips(reply.RewardList, 2)
    end
end

---@param data pbcmessage.ActivityDialogueChooseMaleReply
function ActivityDialogueProxy:OnActivityDialogueChooseMaleReply(data)
    local activityDialogueData_X3 = X3DataMgr.Get(X3DataConst.X3Data.ActivityDialogue, data.ActivityID)
    activityDialogueData_X3:SetMaleID(data.MaleID)
end

--endregion

return ActivityDialogueProxy