---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-28 19:37:25
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SpecialDateProcedureController : DateProcedureController
local SpecialDateProcedureController = class("SpecialDateProcedureController", require "Runtime.System.X3Game.Modules.Date.DateProcedure.DateProcedureController")

function SpecialDateProcedureController:ctor()
    self.super.ctor(self)
    ---@type bool 是否是退出
    self.isExit = false
    ---@type boolean 回放完毕标记
    self.recoverCpl = false
    ---@type boolean CTS开始播放标记
    self.cameraCpl = false
    ---@type boolean 显示倍速标记 只有完成过的特约才显示倍速按钮（NodeType为3的节点已完成）
    self.showPlaySpeedButton = false
end

---约会开始
---@param data
function SpecialDateProcedureController:DateStart()
    self.super.DateStart(self)
    --开个UI直接把外面你的UI顶了
    UIMgr.Open("SpecialDatePlayWnd", true)
    ---@type cfg.SpecialDateEntry
    self.specialDateEntry = LuaCfgMgr.Get("SpecialDateEntry", self.m_StaticData.specialDateEntryID)
    ---@type cfg.DialogueInfo
    self.dialogueInfo = LuaCfgMgr.Get("DialogueInfo", self.specialDateEntry.Drama)
    self.recoverCpl = false
    self.cameraCpl = false
    self.needTempSaveNodeList = {}
    local treeDatas = SelfProxyFactory.GetSpecialDateProxy():GetTree(self.specialDateEntry.ID)
    for _, dateStoryTree in pairs(treeDatas) do
        local uniqueID = dateStoryTree.ActiveConversation * 10000 + dateStoryTree.ActiveNodeID
        if self.needTempSaveNodeList[uniqueID] == nil then
            self.needTempSaveNodeList[uniqueID] = true
        end
        if dateStoryTree.NodeType == SpecialDateTreeDefine.SpecialDateTreeNodeType.Ending then
            local nodeData = SelfProxyFactory.GetSpecialDateProxy():GetNodeData(dateStoryTree.ID)
            if nodeData.status ~= SpecialDateTreeDefine.SpecialDateTreeNodeStatus.Locked then
                self.showPlaySpeedButton = true
            end
        end
    end
    EventMgr.AddListenerOnce("GetSpecialDateTreeReply", self.OnGetSpecialDateTreeReply, self)
    --如果没有点开过剧情树，就需要在这里拉一下剧情树数据缓存快照
    BllMgr.GetSpecialDateBLL():SaveStoryTreeInfo(self.specialDateEntry.ID)
    self:PreloadDialogue(self.dialogueInfo.Name)
end

---如果没有拉取过剧情树，会导致判断不了剧情是否读完过
function SpecialDateProcedureController:OnGetSpecialDateTreeReply()
    local treeDatas = SelfProxyFactory.GetSpecialDateProxy():GetTree(self.specialDateEntry.ID)
    for _, dateStoryTree in pairs(treeDatas) do
        if dateStoryTree.NodeType == SpecialDateTreeDefine.SpecialDateTreeNodeType.Ending then
            local nodeData = SelfProxyFactory.GetSpecialDateProxy():GetNodeData(dateStoryTree.ID)
            if nodeData.status ~= SpecialDateTreeDefine.SpecialDateTreeNodeStatus.Locked then
                self.showPlaySpeedButton = true
                if self:CurrentDialogueSystem() then
                    self:CurrentSettingData():SetShowPlaySpeedButton(self.showPlaySpeedButton)
                end
            end
        end
    end
end

---添加加载资源
function SpecialDateProcedureController:AddResPreload()
    self.super.AddResPreload(self)
    local finalSceneName = self.dialogueInfo.StartScene
    if self.m_StaticData.dialogueRecordList ~= nil and #self.m_StaticData.dialogueRecordList > 0 then
        local changedScene = DialogueUtil.CheckFinalScene(self.dialogueInfo.Name, self.m_StaticData.dialogueRecordList)
        if string.isnilorempty(changedScene) == false then
            finalSceneName = changedScene
        end
    end
    if string.isnilorempty(finalSceneName) == false then
        ResBatchLoader.AddSceneTask(finalSceneName)
    end
end

---加载完毕
---@param batchID int
function SpecialDateProcedureController:OnLoadResComplete(batchID)
    self.super.OnLoadResComplete(self, batchID)
    self.virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.AutoSyncMode)
    self.dialogID = self.dialogueInfo.ID
    EventMgr.AddListener("DialogueEntryEnd", self.DialogueEntryEnd, self)
    EventMgr.AddListener("SpecialDatePlayWndFocus", self.OnSpecialDatePlayWndFocus, self)
    --不用在这里预加载首场景
    DialogueManager.SetPreloadStartScene(false)
    self:InitDialogue(self.dialogueInfo.ID, nil, true, handler(self, self.StartPlayDialogue), 0)
    DialogueManager.SetPreloadStartScene(true)
    self:CurrentSettingData():SetShowPauseButton(true)
    self:CurrentSettingData():SetShowPlaySpeedButton(self.showPlaySpeedButton)
    self:CurrentSettingData():SetShowPhotoButton(true)
    self:CurrentSettingData():SetUseNodeGraph(true)
    self:CurrentDialogueSystem():RegisterExitHandler(handler(self, self.DateExit), UITextHelper.GetUIText(UITextConst.UI_TEXT_7100))
    self:CurrentDialogueSystem():CloseUIWhenEndDialogue(false)
end

---初始化剧情完毕、开始播放
function SpecialDateProcedureController:StartPlayDialogue()
    if self.m_StaticData.dialogueRecordList ~= nil and #self.m_StaticData.dialogueRecordList > 0 then
        EventMgr.AddListenerOnce("RecoverComplete", self.RecoverComplete, self)
        EventMgr.AddListenerOnce("CameraTimelinePlayed", self.CameraTimelinePlayed, self)
        self:CurrentDialogueSystem():RecoverDialogue(self.m_StaticData.dialogueRecordList, handler(self, self.DateRecoverUpdate), handler(self, self.DateFinish))
        self.m_StaticData.dialogueRecordList = nil
    else
        self.recoverCpl = true
        EventMgr.AddListenerOnce("CameraTimelinePlayed", self.CameraTimelinePlayed, self)
        self:PlayDialogueAppend(self.dialogueInfo.ID, self.dialogueInfo.StartConversation, nil, handler(self, self.DateFinish))
    end
end

---第一个CTS开始播放了
function SpecialDateProcedureController:CameraTimelinePlayed()
    self.cameraCpl = true
    self:CheckHideLoading()
end

---剧情回放完成
function SpecialDateProcedureController:RecoverComplete()
    self.recoverCpl = true
    self:CheckHideLoading()
end

---检查是否隐藏Loading
function SpecialDateProcedureController:CheckHideLoading()
    if self.recoverCpl and self.cameraCpl then
        UICommonUtil.SetLoadingProgress(1, true)
    end
end

---单个节点播放结束
---@param curEntry DialogueEntry
function SpecialDateProcedureController:DialogueEntryEnd(curEntry)
    if curEntry ~= nil and self.needTempSaveNodeList[curEntry.uniqueID] ~= nil then
        self:CurrentDialogueSystem():PauseUpdate()
        self:CheckDialogue(handler(self, self.SaveComplete))
    end
end

---剧情流程记录结束
function SpecialDateProcedureController:SaveComplete()
    self:CurrentDialogueSystem():ResumeUpdate()
end

---约会退出
function SpecialDateProcedureController:DateExit()
    --屏蔽情报弹窗
    ErrandMgr.SetDelay(true)
    UIMgr.SetCanRestoreHistory(false)
    self.isExit = true
    self:DateFinish()
end

---约会结束
function SpecialDateProcedureController:DateFinish()
    BllMgr.GetSpecialDateBLL():SetBackFromDateId(self.specialDateEntry.ID)
    UICommonUtil.SetLoadingEnableWithOpenParam({ MoveInCallBack = handler(self, self.FinishAfterLoadingMovein), MoveOutCallBack = function()
    end }, GameConst.LoadingType.MainHome, true)
end

---Loading起来后逻辑
function SpecialDateProcedureController:FinishAfterLoadingMovein()
    --屏蔽情报弹窗
    ErrandMgr.SetDelay(true)
    self:CheckDialogue(handler(self, self.Finish))
end

---
function SpecialDateProcedureController:Finish()
    if self.isExit == false then
        self:GetReward()
    else
        UIMgr.Close("SpecialDatePlayWnd", true)
        self.super.DateFinish(self)
    end

    self.isExit = false
end

---特约剧情校验
---@param callback fun
function SpecialDateProcedureController:CheckDialogue(callback)
    if self:CurrentDialogueController() and self:CurrentDialogueController():HasSavedProcessNode() then
        self.checkDialogueHandler = callback
        EventMgr.AddListener("CheckSpecialDateDialogueReply", self.CheckDialogueCallback, self)
        local request = {}
        request.CurrentId = self.m_StaticData.specialDateEntryID
        request.CheckList = self:CurrentDialogueController():PopProcessNodes()
        GrpcMgr.SendRequest(RpcDefines.CheckSpecialDateDialogueRequest, request)
    else
        if callback ~= nil then
            callback()
        end
    end
end

---剧情校验回调
function SpecialDateProcedureController:CheckDialogueCallback()
    EventMgr.RemoveListener("CheckSpecialDateDialogueReply", self.CheckDialogueCallback, self)
    if self.checkDialogueHandler ~= nil then
        self.checkDialogueHandler()
    end
    self.checkDialogueHandler = nil
end

---特约结算
function SpecialDateProcedureController:GetReward()
    EventMgr.AddListenerOnce("GetSpecialDateRewardReply", self.GetRewardCallback, self)
    local messageBody = PoolUtil.GetTable()
    messageBody.IsGiveUp = false
    GrpcMgr.SendRequest(RpcDefines.GetSpecialDateRewardRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

---@param msg pbcmessage.GetSpecialDateRewardReply
function SpecialDateProcedureController:GetRewardCallback(msg)
    --UICommonUtil.SetLoadingProgress(1, true)
    UIMgr.SetCanRestoreHistory(false)
    UIMgr.Close("SpecialDatePlayWnd", true)
    self.super.DateFinish(self)
end

---侦听UI的失焦，应该只会出现在断线重连弹窗
---@param value boolean
function SpecialDateProcedureController:OnSpecialDatePlayWndFocus(value)
    ---只有断线重连才触发这个逻辑
    if UIMgr.IsOpened(UIConf.GrabFocusWnd) then
        if value then
            self:CurrentDialogueController():ResumeDialogue("WndFocus")
        else
            self:CurrentDialogueController():PauseDialogue("WndFocus")
        end
    end
end

---清理逻辑
function SpecialDateProcedureController:DateClear()
    if self:CurrentDialogueSystem() then
        self:CurrentDialogueSystem():UnregisterExitHandler()
    end
    EventMgr.RemoveListener("DialogueEntryEnd", self.DialogueEntryEnd, self)
    UIMgr.Close("SpecialDatePlayWnd", true)
    GlobalCameraMgr.DestroyVirtualCamera(self.virtualCamera)
    self.super.DateClear(self)
end

return SpecialDateProcedureController