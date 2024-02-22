---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-08-28 14:55:03
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local NodeController = require("Runtime.System.X3Game.Modules.Dialogue.NodeController.NodeController")
---@class ConditionBranchController:NodeController
local ConditionBranchController = class("ConditionBranchController", NodeController, nil ,true)

---初始化数据
function ConditionBranchController:OnInit()
    self.super.OnInit(self)
    self.nodeControllerType = DialogueEnum.DialogueConditionType.ConditionBranch
end

---节点流程记录
---@param nextLink table 该节点的下一个
function ConditionBranchController:ProcessSave(nextLink)
    local node = {}
    node.Id = self.dialogueEntry.uniqueID
    if nextLink ~= nil then
        local nextDialogueEntry = self.database:GetDialogueEntryByLink(nextLink)
        node.NextId = nextDialogueEntry.uniqueID
    end
    node.VariableMap = self:ProcessNodeVariableChange()
    self.nodePlayer:AddProcessNode(node)
end

---分析Link，判断节点结束后需要去哪个节点
function ConditionBranchController:AnalyzeLink()
    local nextLink = nil
    self.settedNextLink = DialogueManager.GetSettedLink(self.database, self.dialogueEntry.uniqueID)
    if self.settedNextLink ~= nil then
        nextLink = self.settedNextLink
    else
        if self.dialogueEntry.outgoingLinks then
            for i = 1, #self.dialogueEntry.outgoingLinks do
                local conditionData = self.dialogueEntry.outgoingLinks[i].conditionData
                if DialogueManager.IsMutedLink(self.database.name, self.dialogueEntry.outgoingLinks[i]) == false then
                    local result, firstFailedCondition = ConditionCheckUtil.CheckConditionCheckData(conditionData.conditionCheckDatas, self.system:GetDataProvider())
                    if result then
                        if conditionData.isFallback == false then
                            nextLink = self.dialogueEntry.outgoingLinks[i]
                            break
                        end
                    else
                        Debug.LogFormat("[DialogueSystem]ConditionCheck失败-%s-%s-%s-%s-%s", firstFailedCondition.id, firstFailedCondition.paramList[1], firstFailedCondition.paramList[2], firstFailedCondition.paramList[3], firstFailedCondition.paramList[4])
                    end
                end

                if conditionData.isFallback then
                    nextLink = self.dialogueEntry.outgoingLinks[i]
                end
            end
        end
    end

    if nextLink ~= nil then
        self:AddWaitNode(nextLink)
    end
    self:ProcessSave(nextLink)
    self:ResumeUpdate()
end

return ConditionBranchController