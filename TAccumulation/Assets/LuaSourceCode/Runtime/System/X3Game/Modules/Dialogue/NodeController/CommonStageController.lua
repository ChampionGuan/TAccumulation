---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-28 14:28:08
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class CommonStageController
local NodeController = require("Runtime.System.X3Game.Modules.Dialogue.NodeController.NodeController")
local CommonStageController = class("NodeController", NodeController, nil ,true)

---初始化数据
function CommonStageController:OnInit()
	self.super.OnInit(self)
	self.nodeControllerType = DialogueEnum.DialogueConditionType.CommonStage
end

function CommonStageController:ProcessSave(nextLink)
	local node = {}
	node.Id = self.dialogueEntry.uniqueID
	local nextDialogueEntry = self.database:GetDialogueEntryByLink(nextLink)
	node.NextId = nextDialogueEntry.uniqueID
	node.VariableMap = self:ProcessNodeVariableChange()
	self.nodePlayer:AddProcessNode(node)
end

--[[function CommonStageController:ProcessFrame(time)
	local stageID = self.dialogueEntry.stageID
	if BllMgr.GetSpecialDateBLL():GetFightResult(stageID) ~= 0 then
		self:AnalyzeLink()
	else
		self.super.ProcessFrame(self, time)
	end
end

function CommonStageController:AnalyzeLink()
	self.super.AnalyzeLink(self)
	local stageID = self.dialogueEntry.stageID
	if BllMgr.GetSpecialDateBLL():GetFightResult(stageID) ~= 0 then
		self.super.AnalyzeLink(self)
	else
		EventMgr.Dispatch("DialogueCommonStage", stageID)
	end
end]]

return CommonStageController