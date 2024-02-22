---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-28 17:59:40
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local NodeController = require("Runtime.System.X3Game.Modules.Dialogue.NodeController.NodeController")
---@class RandomController:NodeController
local RandomController = class("RandomController", NodeController, nil ,true)

---初始化数据
function RandomController:OnInit()
    self.super.OnInit(self)
    self.nodeControllerType = DialogueEnum.DialogueConditionType.Random
    ---@type table<Link> 满足条件的LInk
    self.satisfiedLink = {}
end

---节点流程记录
---@param nextLink table 该节点的下一个
function RandomController:ProcessSave(nextLink)
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
function RandomController:AnalyzeLink()
    self.satisfiedLink = {}
    local needSaveLink = nil
    self.system:CheckResetRandomTimes(self.dialogueEntry.outgoingLinks)
    self.settedNextLink = DialogueManager.GetSettedLink(self.database, self.dialogueEntry.uniqueID)
    if self.settedNextLink ~= nil then
        needSaveLink = self.settedNextLink
    else
        local weightAll = 0
        if self.dialogueEntry.outgoingLinks then
            for _, link in pairs(self.dialogueEntry.outgoingLinks) do
                if DialogueManager.IsMutedLink(self.database.name, link) == false then
                    local nextDialogueEntry = self.database:GetDialogueEntryByLink(link)
                    if ConditionCheckUtil.CheckConditionCheckData(link.conditionData.conditionCheckDatas, self.system:GetDataProvider()) then
                        if self.system:HasLeftRandomTimes(nextDialogueEntry) then
                            weightAll = weightAll + link.conditionData.randomWeight
                        end
                        table.insert(self.satisfiedLink, #self.satisfiedLink + 1, link)
                    end
                end
            end
        end


        if weightAll > 0 then
            local random = math.random(0, weightAll - 1)
            for i = 1, #self.satisfiedLink do
                local curLink = self.satisfiedLink[i]
                if self.system:HasLeftRandomTimes(self.database:GetDialogueEntryByLink(curLink)) then
                    if random < curLink.conditionData.randomWeight then
                        needSaveLink = curLink
                        break
                    else
                        random = random - curLink.conditionData.randomWeight
                    end
                end
            end
        end
    end

    if needSaveLink then
        self.system:AddRandomTimes(self.database:GetDialogueEntryByLink(needSaveLink))
        self:AddWaitNode(needSaveLink)
    end
    self:ProcessSave(needSaveLink)
    self:ResumeUpdate()
end

return RandomController