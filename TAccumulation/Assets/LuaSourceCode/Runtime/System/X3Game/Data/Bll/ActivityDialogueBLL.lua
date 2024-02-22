﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2023/12/16 15:30
---
---活动剧情BLL

---@class ActivityDialogueBLL:BaseBll
local ActivityDialogueBLL = class("ActivityDialogueBLL", BaseBll)

local ActivityCenterConst = require("Runtime.System.X3Game.GameConst.ActivityCenterConst")
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")

function ActivityDialogueBLL:Init()

end

---播放剧情

---@param activityDialogueData_Cfg cfg.ActivityDialogue
---@param dialogueEndCallBack function
---@param isPre bool 是否为前置剧情
---@param preDialogueQuitTip string 前置剧情退出的文本 (选传参数)
---@param withoutUnlockCheckAndRequest bool 如果传参为true 则不需要检查剧情解锁条件 (需求: 剧情回顾中仅剧情播放, 没有条件检查和服务器的通信)
---@param stateExitCallback function 如果剧情手动退出不会走到dialogueEndCallback 但是会走到这里 可以用于资源清理
function ActivityDialogueBLL:PlayDialogue(activityDialogueData_Cfg, dialogueEndCallBack, isPre, preDialogueQuitTip, withoutUnlockCheckAndRequest, stateExitCallback)
    ---如果剧情没有解锁 就解锁剧情
    if not withoutUnlockCheckAndRequest then
        if not self:IsActivityDialogueUnlock(activityDialogueData_Cfg.ActivityID, activityDialogueData_Cfg.ID) then
            self:SendDialogueUnlock(activityDialogueData_Cfg.ActivityID, activityDialogueData_Cfg.ID)
        end
    end
    self.isPreDialogue = isPre or false
    self.preDialogueQuitTip = preDialogueQuitTip
    UICommonUtil.WhiteScreenIn(function()
        self:ChangeDialogueState(function()
            self.dialogueController = DialogueManager.InitByName("ActivityDialogue")
            EventMgr.AddListenerOnce("CameraTimelinePlayed", self.CameraTimelinePlayed, self)
            self.system = self.dialogueController:InitDialogue(activityDialogueData_Cfg.DialogueID, Mathf.Random(1, 10000), nil)
            self.dialogueController:StartDialogueById(activityDialogueData_Cfg.DialogueID, activityDialogueData_Cfg.ConversationID, nil, nil, function()
                self:FinishDialogue(activityDialogueData_Cfg.ID, activityDialogueData_Cfg.ActivityID, dialogueEndCallBack, self.dialogueController:PopProcessNodes(), withoutUnlockCheckAndRequest)
            end)
            local settingData = self.system:GetSettingData()
            settingData:SetShowReviewButton(true)
            settingData:SetShowPauseButton(true)
            settingData:SetShowPlaySpeedButton(true)
            settingData:SetShowClickBg(false)
            settingData:SetShowPhotoButton(true)
            self.system:RegisterExitClickHandler(handler(self, self.OnClickBack))
        end, function()
            if stateExitCallback then
                stateExitCallback()
            end
        end)
    end, self.isPreDialogue)
end

function ActivityDialogueBLL:OnClickBack()
    if self.isPreDialogue then
        UICommonUtil.ShowMessageBox(self.preDialogueQuitTip or UITextConst.UI_TEXT_51012, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
            self:QuitDialogue()
            ---序章退出关闭活动主界面
            UIMgr.Close(UIConf.ActivityMainWnd)
        end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
            self.system:ResumeTime()
        end }
        })
    else
        UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_51032, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
            self:QuitDialogue()
        end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
            self.system:ResumeTime()
        end }
        })
    end
end

function ActivityDialogueBLL:QuitDialogue()
    EventMgr.AddListenerOnce(MainHomeConst.Event.MAIN_HOME_ENTER_AND_ACTOR_LOADED, self.EnterMainHome, self)
    UICommonUtil.WhiteScreenIn(function()
        EventMgr.Dispatch(ActivityCenterConst.EventType.RECOVER_VIEW)
        GameStateMgr.Switch(GameState.MainHome, false, false)
    end)
end

function ActivityDialogueBLL:EnterMainHome()
    UICommonUtil.WhiteScreenOut(function()
        EventMgr.Dispatch(ActivityCenterConst.EventType.FANTASY_DIALOGUE_END)
    end)
end

function ActivityDialogueBLL:IsActivityDialogueUnlock(activityID, activityDialogueID)
    local unlockIDs = SelfProxyFactory.GetActivityDialogueProxy():GetActivityDialogueUnlockIDs(activityID)
    if unlockIDs == nil then
        return false
    end
    for i, v in ipairs(unlockIDs) do
        if v == activityDialogueID then
            return true
        end
    end
    return false
end

---@param activityDialogueData_Cfg cfg.ActivityDialogue
---@param timeLockTip string 未到解锁时间的tip 可以不传有默认值
---@param preNotFinishTip string 前置剧情未解锁的tip 可以不传有默认值
---@return bool,int
function ActivityDialogueBLL:IsCanUnlock(activityDialogueData_Cfg, timeLockTip, preNotFinishTip)
    local unlockTime = GameHelper.GetDateByStr(activityDialogueData_Cfg.UnlockTime)
    if TimerMgr.GetCurTimeSeconds() < TimerMgr.GetUnixTimestamp(unlockTime) then
        return false, timeLockTip or UITextConst.UI_TEXT_51011
    end
    ---没有前置剧情不需要解锁
    if activityDialogueData_Cfg.PreID == 0 then
        return true
    end
    local finishIDs = SelfProxyFactory.GetActivityDialogueProxy():GetActivityDialogueFinishIDs(activityDialogueData_Cfg.ActivityID)
    if finishIDs == nil then
        return false, preNotFinishTip or UITextConst.UI_TEXT_51004
    end
    for i, v in ipairs(finishIDs) do
        if v == activityDialogueData_Cfg.PreID then
            return true
        end
    end
    return false, preNotFinishTip or UITextConst.UI_TEXT_51004
end

function ActivityDialogueBLL:CameraTimelinePlayed()
    ---取消剧情白屏
    UICommonUtil.WhiteScreenOut()
end

function ActivityDialogueBLL:ChangeDialogueState(enterCallback, exitCallback)
    if GameStateMgr.GetCurStateName() == GameState.ActivityDialogue then
        enterCallback()
    else
        GameStateMgr.Switch(GameState.ActivityDialogue, function()
            enterCallback()
        end, nil, exitCallback)
    end
end

function ActivityDialogueBLL:FinishDialogue(dialogueID, activityID, callback, checkList, withoutRequest)
    if not withoutRequest then
        self:SendDialogueFinish(activityID, dialogueID, checkList)
    end
    if callback ~= nil then
        callback()
    end
end

function ActivityDialogueBLL:IsPreDialogue()
    return self.isPreDialogue
end

function ActivityDialogueBLL:GetPreDialogueQuitTip()
    return self.preDialogueQuitTip
end

---sendMessage
---
---选择男主
---@param activityID int
---@param roleID int
function ActivityDialogueBLL:SendChooseMale(activityID, roleID)
    local req = {}
    req.ActivityID = activityID
    req.MaleID = roleID
    GrpcMgr.SendRequest(RpcDefines.ActivityDialogueChooseMaleRequest, req, true)
    SelfProxyFactory.GetActivityDialogueProxy():SetActivityDialogueMaleID(activityID, roleID)
end

---活动完成
---@param activityID int
---@param activityDialogueID int
function ActivityDialogueBLL:SendDialogueFinish(activityID, activityDialogueID, checkList)
    local req = {}
    req.ActivityID = activityID
    req.DialogueID = activityDialogueID
    req.CheckList = checkList
    GrpcMgr.SendRequest(RpcDefines.ActivityDialogueFinishRequest, req, true)
end

---活动解锁
---@param activityID int
---@param activityDialogueID int
function ActivityDialogueBLL:SendDialogueUnlock(activityID, activityDialogueID)
    local req = {}
    req.ActivityID = activityID
    req.DialogueID = activityDialogueID
    GrpcMgr.SendRequest(RpcDefines.ActivityDialogueUnlockRequest, req, true)
end

return ActivityDialogueBLL