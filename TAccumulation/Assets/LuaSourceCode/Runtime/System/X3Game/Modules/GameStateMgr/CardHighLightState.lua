---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-27 15:29:44
---------------------------------------------------------------------

local CardHighLightState = class("CardHighLightState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function CardHighLightState:ctor()
	self.Name = "CardHighLightState"
end

function CardHighLightState:OnEnter(prevStateName, cardId)
	self.super.OnEnter(self)
	self.cardId = cardId
	self.cfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
	PerformanceLog.Begin(PerformanceLog.Tag.CardHighlight, UITextHelper.GetUIText(self.cfg.Name))
	self.startTime = CS.UnityEngine.Time.realtimeSinceStartup
	self.holdSceneCfg = PlayerPrefs.GetBool("highlight holdscene", false)
	self.dialogueInitCb = handler(self, self.OnDialogueInited)
	self.dialogueEndCb = handler(self, self.OnDialogueEnd)
	if self.holdSceneCfg then
		SceneMgr.HoldCurSceneGO()
	end
	SceneMgr.SkipGCOnce(true)
	self:PlayDialogue()
end

function CardHighLightState:PlayDialogue()
	UIMgr.Open(UIConf.SpecialDatePlayWnd)
	self:StartDialogueRange()
	if self.cfg.CloseTransNodeID == 0 then
		Debug.LogErrorFormat("高光时刻未配置CloseTransNodeID，CardId:%s", tostring(self.cardId))
		UICommonUtil.ThreeStageMotionOut(GameConst.FullScreenMotionKey.OCX_HighLight_in)
	else
		EventMgr.AddListener("DialogueEntryEnd", self.OnDialogueStart, self)
	end
end

function CardHighLightState:OnDialogueStart(node)
	if node.id == self.cfg.CloseTransNodeID then
		UICommonUtil.ThreeStageMotionOut(GameConst.FullScreenMotionKey.OCX_HighLight_in)
		local lastTime = CS.UnityEngine.Time.realtimeSinceStartup - self.startTime
		Debug.LogFormat("高光时刻开始到剧情开始播放耗时：%s", tostring(lastTime))
	end
end

function CardHighLightState:OnExit(nextStateName)
	EventMgr.RemoveListenerByTarget(self)
	PerformanceLog.End(PerformanceLog.Tag.CardHighlight, UITextHelper.GetUIText(self.cfg.Name))
	UIMgr.Close(UIConf.SpecialDatePlayWnd)
	self.dialogueController = nil
	self.cardId = nil
	self.cfg = nil
	self.holdSceneCfg = nil
	self.startTime = nil
	self.dialogueInitCb = nil
	self.dialogueEndCb = nil
	DialogueManager.ClearByName("DevelopCard")
	self.super.OnExit(self)
end

function CardHighLightState:CanExit(nextStateName)
	return true
end

function CardHighLightState:StartDialogueRange()
	self.dialogueController = DialogueManager.Get("DevelopCard")
	if self.dialogueController == nil then
		self.dialogueController = DialogueManager.InitByName("DevelopCard")
	end

	DialogueManager.SetPreloadStartScene(false)
	local system = self.dialogueController:InitDialogue(self.cfg.DialogueID, nil, nil, self.dialogueInitCb)
	system:RegisterExitHandler(self.dialogueEndCb)
	DialogueManager.SetPreloadStartScene(true)
end

function CardHighLightState:OnDialogueInited()
	local system = self.dialogueController:GetDialogueSystem(self.cfg.DialogueID)
	if system then
		system:GetSettingData():SetShowPauseButton(true)
		system:GetSettingData():SetUseNodeGraph(true)
		system:GetSettingData():SetShowPhotoButton(true)
		system:GetSettingData():SetShowPlaySpeedButton(false)
	end
	self.dialogueController:StartDialogueRange(self.cfg.DialogueID,self.cfg.StartConversation,self.cfg.StartNodeID,self.cfg.EndConversation,self.cfg.EndNodeID,self.dialogueEndCb)
end

function CardHighLightState:OnDialogueEnd()
	if self.holdSceneCfg then
		SceneMgr.ClearHoldingScene()
	end
	SceneMgr.SkipGCOnce(true)
	UICommonUtil.ThreeStageMotionIn(GameConst.FullScreenMotionKey.OCX_HighLight_out, function()
		GameStateMgr.Switch(GameState.MainHome, false, false)
		UICommonUtil.ThreeStageMotionOut(GameConst.FullScreenMotionKey.OCX_HighLight_out)
	end)
end

return CardHighLightState