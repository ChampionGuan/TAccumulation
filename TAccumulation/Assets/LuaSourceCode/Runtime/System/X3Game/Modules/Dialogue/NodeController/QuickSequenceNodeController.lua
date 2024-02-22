---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-26 16:28:32
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local NodeController = require("Runtime.System.X3Game.Modules.Dialogue.NodeController.NodeController")
---@class QuickSequenceNodeController:NodeController
local QuickSequenceNodeController = class("QuickSequenceNodeController", NodeController, nil ,true)

function QuickSequenceNodeController:OnInit()
    self.super.OnInit(self)
    self.nodeControllerType = DialogueEnum.DialogueConditionType.QuickSequence
    self.quickSequenceMode = true
    self.needSave = true
end

---节点初始化
---@param dialogueEntry DialogueEntry 单节点配置数据
function QuickSequenceNodeController:InitFromEntry(dialogueEntry)
    if self.cutSceneFastMode then
        self.ctsEventOffset = self.pipeline:GetCostedCTSEventCnt()
        self.dialogueEntry = dialogueEntry
        self.startWaitSetting = self.dialogueEntry.startWaitSetting
        self.endWaitSetting = self.dialogueEntry.endWaitSetting
        self:SetCTSEventEnd()
        self:StartNode()
        EventMgr.AddListener("DialogueActionCpl", self.OnDialogueActionEnd, self)
        EventMgr.AddListener("DialogueActionCplExceptAfterText", self.OnDialogueActionExceptAfterTextEnd, self)
    else
        self.super.InitFromEntry(self, dialogueEntry)
    end
end

---播放行为
function QuickSequenceNodeController:PlayAction()
    if DialogueUtil.HasCutScene(self.database, self.dialogueEntry) then
        if self.cutSceneFastMode then
            self.pipeline:SetFastForwardMode(true)
        else
            self.pipeline:SetFastForwardMode(false)
        end
    end
    self.super.PlayAction(self)
end

---侦听CTS事件帧
---@param callback fun
---@param target table
---@param waitCnt int
---@param isCostEvent boolean 是否消耗事件帧
function QuickSequenceNodeController:RegisterCTSEvent(callback, target, waitCnt, isCostEvent)
    if self.cutSceneFastMode == false then
        self.super.RegisterCTSEvent(self, callback, target, waitCnt, isCostEvent)
    end
end

---Wwise逻辑
function QuickSequenceNodeController:WwiseLogic()
    --复写，快速模式下不播语音了
    self.wwisePlayed = true
    self.wwisePlaying = true
end

---记录节点
---@param nextLink Link
function QuickSequenceNodeController:ProcessSave(nextLink)
    if self.needSave then
        self.super.ProcessSave(self, nextLink)
    end
end

---分析Link，判断节点结束后需要去哪个节点
function QuickSequenceNodeController:AnalyzeLink()
    if self.dialogueEntry.conditionType == DialogueEnum.DialogueConditionType.Parallel then
        self.system:SetIgnoreProcessSave(true)
        if self.dialogueEntry.outgoingLinks then
            for i = 1, #self.dialogueEntry.outgoingLinks do
                if self.dialogueEntry.outgoingLinks[i].conditionData.isFallback then
                    self:AddWaitNode(self.dialogueEntry.outgoingLinks[i])
                else
                    if DialogueManager.IsMutedLink(self.database.name, self.dialogueEntry.outgoingLinks[i]) == false then
                        local result, firstFailedCondition = ConditionCheckUtil.CheckConditionCheckData(self.dialogueEntry.outgoingLinks[i].conditionData.conditionCheckDatas,
                                self.system:GetDataProvider())
                        if result then
                            self.pipeline:StartSubPlayer(self.nodePlayer, self.dialogueEntry.outgoingLinks[i])
                        else
                            Debug.LogFormat("[DialogueSystem]ConditionCheck失败-%s-%s-%s-%s-%s", firstFailedCondition.id, firstFailedCondition.paramList[1], firstFailedCondition.paramList[2], firstFailedCondition.paramList[3], firstFailedCondition.paramList[4])
                        end
                    end
                end
            end
        end
        self.system:SetIgnoreProcessSave(false)
    else
        self.super.AnalyzeLink(self)
    end
    self:AfterAnalyzeLink()
end

---快播模式的一些逻辑后处理
function QuickSequenceNodeController:AfterAnalyzeLink()
    if self.dialogueEntry.conditionType == DialogueEnum.DialogueConditionType.QTE
        or self.dialogueEntry.conditionType == DialogueEnum.DialogueConditionType.Choice then
        if self.settedNextLink then
            self:RecordSelection(self.settedNextLink)
        end
    end
end


return QuickSequenceNodeController