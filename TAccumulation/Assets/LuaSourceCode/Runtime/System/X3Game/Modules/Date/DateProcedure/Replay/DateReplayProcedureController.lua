---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-07 11:42:51
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class DateReplayProcedureController
local DateReplayProcedureController = class("DateReplayProcedureController", require "Runtime.System.X3Game.Modules.Date.DateProcedure.DateProcedureController")

function DateReplayProcedureController:ctor()
    self.super.ctor(self)
end

function DateReplayProcedureController:DateStart(callback)
    self.super.DateStart(self, callback)
    local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", self.m_StaticData.dialogueID)
    self:PreloadDialogue(dialogueInfo.Name)
end

function DateReplayProcedureController:AddResPreload()
    self.super.AddResPreload(self)
    local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", self.m_StaticData.dialogueID)
    if self.m_StaticData.scene ~= nil then
        ResBatchLoader.AddSceneTask(self.m_StaticData.scene)
    end
end

function DateReplayProcedureController:OnLoadResComplete(batchID)
    self.super.OnLoadResComplete(self, batchID)
    self.virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.AutoSyncMode)
    self:Play()
end

function DateReplayProcedureController:Play()
    self:InitDialogue(self.m_StaticData.dialogueID, math.random(1, 5000), true, handler(self, self.ReplayStart), 0)
    DialogueManager.GetDefaultDialogueSystem():RegisterExitHandler(handler(self, self.DateExit),
            UITextHelper.GetUIText(UITextConst.UI_TEXT_5602))
end

function DateReplayProcedureController:ReplayStart()
    if (self.m_StaticData.startConversation == self.m_StaticData.realStartConversation and
            self.m_StaticData.startNodeID == self.m_StaticData.realStartNodeID) or
            self.m_StaticData.realStartConversation == 0 then
        EventMgr.AddListener('CameraTimelinePlayed', self.RecoverComplete, self)
    else
        EventMgr.AddListener('RecoverComplete', self.RecoverComplete, self)
    end
    UIMgr.Open(UIConf.SpecialDatePlayWnd)
    DialogueManager.GetDefaultDialogueSystem():ReplayDialogue(self.m_StaticData,
            handler(self, self.DateRecoverUpdate),
            handler(self, self.DateFinish))
end

function DateReplayProcedureController:RecoverComplete(eb)
    EventMgr.RemoveListener('CameraTimelinePlayed', self.RecoverComplete, self)
    EventMgr.RemoveListener('RecoverComplete', self.RecoverComplete, self)
    UICommonUtil.SetLoadingProgress(1, true)
end

function DateReplayProcedureController:DateExit()
    DateManager.DateFinish()
end

function DateReplayProcedureController:DateClear()
    UIMgr.Close(UIConf.SpecialDatePlayWnd)
    DialogueManager.GetDefaultDialogueSystem():UnregisterExitHandler()
    self.super.DateClear(self)
end

return DateReplayProcedureController
