---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-08-26 19:48:01
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local DialogueTextUtil = require("Runtime.System.X3Game.Modules.Dialogue.Util.DialogueTextUtil")
local DialogueDynamicDataUtil = require("Runtime.System.X3Game.Modules.Dialogue.Util.DialogueDynamicDataUtil")

local NodeController = require("Runtime.System.X3Game.Modules.Dialogue.NodeController.NodeController")
---@class ChoiceController:NodeController
local ChoiceController = class("ChoiceController", NodeController, nil, true)

---@class DialogueUIChoiceData
---@field choices table<ChoiceOptionData> choice选择池
---@field choiceStyleSetting ChoiceStyleSetting 选项样式设置
---@field pipelineKey string|int 所属pipelineKey
---@field nodePlayerId int 所属playerId

---@class ChoiceOptionData
---@field text string 选项文本
---@field variableID int 选择该选项同步修改的VariableKey
---@field variableValue int 选择该选项同步修改的VariableValue
---@field weight float 选项权重
---@field link Link 选项对应的link
---@field isSatisfiedCondition boolean 是否满足条件
---@field conditionCheckMessage string 条件不满足时的提示
---@field semanticGroupId int 语义组Id
---@field dynamicUIList table<string> 动态UI切图替换

---初始化数据
function ChoiceController:OnInit()
    self.super.OnInit(self)
    self.nodeControllerType = DialogueEnum.DialogueConditionType.Choice
    ---@type boolean 选项结束
    self.choiceEnd = false
    ---@type boolean 选项初始化完成
    self.choiceInited = false
    ---@type ChoiceOptionData[] 所有满足条件的选项
    self.choicePool = PoolUtil.GetTable()
    ---@type ChoiceOptionData[] 最终显示出来的固定数量的选项列表
    self.showingChoiceList = PoolUtil.GetTable()
    ---@type fun fallback选项
    self.fallbackLink = nil
    ---@type fun 除动态选项外额外加的选项
    self.dynamicClickLink = nil
    ---@type float 记录下文字结束的时间，用来Tick选项的倒计时
    self.dialogueEndDuration = 0
    ---@type Link 最后选择的Link
    self.selectedLink = nil
    ---@type DialogueUIChoiceData
    self.uiChoiceData = nil
end

---节点是否已完成
---@return boolean
function ChoiceController:IsNodeEnd()
    return self.super.IsNodeEnd(self) and self.choiceEnd
end

---是否等待节点结束
---@return boolean
function ChoiceController:IsWaitForEnd()
    return self.super.IsWaitForEnd(self) and self.choiceEnd
end

---是否可以消耗CTS事件帧
---@return boolean
function ChoiceController:CanCostCTSEvent()
    return self.super.CanCostCTSEvent(self) and self.choiceEnd
end

---是否可以隐藏Text
---@return boolean
function ChoiceController:CanHideText()
    return self.super.CanHideText(self) and self.choiceEnd
end

---强制完成接口
function ChoiceController:ForceEnd()
    self.super.ForceEnd(self)
    self:SetChoiceEnd()
end

---CTS事件后的初始化逻辑
function ChoiceController:StartNode()
    self.super.StartNode(self)
    local selectedAll, fallbackLink = self:SelectedAllKeySelections()
    if self.dialogueEntry.loopSelection and selectedAll then
        self.selectedLink = fallbackLink
        self:ClearSelectionRecord()
        self:SetChoiceEnd()
        return
    end
    table.clear(self.choicePool)
    if self.dialogueEntry.outgoingLinks then
        for _, link in pairs(self.dialogueEntry.outgoingLinks) do
            if link.conditionData.isFallback == false then
                local nextDialogueEntry = self.database:GetDialogueEntryByLink(link)
                local isSatisfiedCondition = ConditionCheckUtil.CheckConditionCheckData(link.conditionData.conditionCheckDatas,
                        self.system:GetDataProvider())
                if self:IsValidLink(link, isSatisfiedCondition) then
                    if self.dialogueEntry.choiceType == DialogueEnum.ChoiceType.Default or link.conditionData.isPlusOption then
                        ---@type ChoiceOptionData
                        local optionData = { variableID = 0, variableValue = 0 }
                        if self.fallbackLink == nil then
                            self.fallbackLink = link
                        end
                        optionData.text = DialogueTextUtil.GetMenuText(self.dialogueId, nextDialogueEntry)
                        optionData.weight = math.floor(link.conditionData.randomWeight)
                        optionData.link = link
                        optionData.isSatisfiedCondition = isSatisfiedCondition
                        optionData.semanticGroupID = link.conditionData.semanticGroupID
                        optionData.dynamicUIList = link.conditionData.choiceSetting and string.split(link.conditionData.choiceSetting.dynamicUI, "|") or nil
                        local desc = { }
                        if link.conditionData.conditionCheckDatas then
                            for i = 1, #link.conditionData.conditionCheckDatas do
                                if link.conditionData.conditionCheckDatas[i].id == X3_CFG_CONST.CONDITION_COMMONCONDITION then
                                    local conditionGroup = tonumber(link.conditionData.conditionCheckDatas[i].paramList[1])
                                    table.insert(desc, #desc + 1, ConditionCheckUtil.GetAllConditionDescByGroupId(conditionGroup))
                                end
                            end
                        end

                        optionData.conditionCheckMessage = table.concat(desc, ',')
                        table.insert(self.choicePool, #self.choicePool + 1, optionData)
                    else
                        self.dynamicClickLink = link
                    end
                end
            else
                self.fallbackLink = link
            end
        end
    end
    if self.dialogueEntry.choiceType ~= DialogueEnum.ChoiceType.Default then
        self.showingChoiceList = DialogueDynamicDataUtil.GetDialogueDataList(self.dialogueEntry.choiceType)
        for i = 1, #self.choicePool do
            table.insert(self.showingChoiceList, #self.showingChoiceList + 1, self.choicePool[i])
        end
    else
        self:GetShowingChoiceList()
    end
    EventMgr.AddListener("DialoguePanelChoiceClicked", self.OnChoiceClick, self)
end

---节点的Tick
---@param deltaTime float update函数传过来的时长
function ChoiceController:ProcessFrame(deltaTime)
    self.super.ProcessFrame(self, deltaTime)
    if self.choiceEnd == false and self.dialogueEnd and self.voiceEnd and self.CTSEventEnd and self.eventEnd then
        if self.choiceInited == false then
            self.choiceInited = true
            EventMgr.Dispatch("DialoguePanelChoiceShow", self:GetUIData())
            self.dialogueEndDuration = self.dialogueTime
            if self.dialogueEntry.hideDialogueWhenShowChoice or string.isnilorempty(self.mainDialogue) then
                self:HideText()
            end
            if self.dialogueEntry.qteDuration == 0 then
                self.system:CheckAutoMode()
            end
            if DialogueManager.GetAutoTestMode() then
                local deltaTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DIALOGUEAUTOTIME)
                self.autoTestTimer = TimerMgr.AddTimer(deltaTime, self.AutoTestSelect, self)
            end
        end
        --Debug长按快播模式下自动跳过单一选项
        if DEBUG_GM and DialogueManager.GetLongPressSkipBranch()
                and self.system:IsInSkipMode() and #self.showingChoiceList <= 1 then
            self:OnChoiceClick(1)
            return
        else
            self.system:StopSkipMode()
        end
        self.clickState = DialogueEnum.TextClickState.None
        if self.dialogueEntry.qteDuration > 0 then
            local normalizedTime = (self.dialogueTime - self.dialogueEndDuration) / self.dialogueEntry.qteDuration
            if normalizedTime > 1 then
                self.selectedLink = self.fallbackLink
                EventMgr.Dispatch("DialoguePanelChoiceHide", self:GetUIData())
                self:SetChoiceEnd()
            else
                EventMgr.Dispatch("DialoguePanelChoiceUpdate", 1 - normalizedTime)
            end
        else
            self:PauseUpdate()
            EventMgr.Dispatch("DialoguePanelChoiceUpdate", 0)
        end
    end
end

---节点流程记录
---@param nextLink Link 该节点的下一个
function ChoiceController:ProcessSave(nextLink)
    local node = {}
    node.Id = self.dialogueEntry.uniqueID
    local nextDialogueEntry = self.database:GetDialogueEntryByLink(nextLink)
    node.NextId = nextDialogueEntry.uniqueID
    node.VariableMap = self:ProcessNodeVariableChange()
    self.nodePlayer:AddProcessNode(node)
end

---分析Link，判断节点结束后需要去哪个节点
function ChoiceController:AnalyzeLink()
    self.settedNextLink = DialogueManager.GetSettedLink(self.database, self.dialogueEntry.uniqueID)
    if self.settedNextLink == nil then
        self:RecordSelection(self.selectedLink)
        self:AddWaitNode(self.selectedLink)
        self:ProcessSave(self.selectedLink)
    else
        self:RecordSelection(self.settedNextLink)
        self:AddWaitNode(self.settedNextLink)
        self:ProcessSave(self.settedNextLink)
        self:SetChoiceEnd()
    end
end

---链接是否有效
---@param link Link
---@param isSatisfiedCondition bool 是否满足条件
---@return bool
function ChoiceController:IsValidLink(link, isSatisfiedCondition)
    local conditionValid = (self.dialogueEntry.qteCount == 0 and (isSatisfiedCondition or link.conditionData.falseConditionHide == false)) or isSatisfiedCondition
    local debugMutedValid = DialogueManager.IsMutedLink(self.database.name, link) == false
    local loopSelectionValild = not self.dialogueEntry.loopSelection or self.nodePlayer:IsLinkSelected(self.dialogueEntry, link) == false
    return conditionValid and debugMutedValid and loopSelectionValild
end

---选项回调
---@param index int 选择了哪个选项
function ChoiceController:OnChoiceClick(index)
    local selectedDialogue = self.showingChoiceList[index]
    --动态选项中有填入variableID和variableValue的
    self.system:ChangeVariableState(selectedDialogue.variableID, selectedDialogue.variableValue)
    if selectedDialogue.link ~= nil then
        self.selectedLink = selectedDialogue.link
    else
        self.selectedLink = self.dynamicClickLink
    end

    self:SetChoiceEnd()
end

---自动测试选择
function ChoiceController:AutoTestSelect()
    for i = 1, #self.showingChoiceList do
        if self.showingChoiceList[i].isSatisfiedCondition then
            self:OnChoiceClick(i)
            Debug.LogFormat("[DialogueSystem]自动模式选项选择-%s", i)
            return
        end
    end
end

---
function ChoiceController:CheckPlayerOperation()
    self:SetChoiceEnd()
end

---选项结束
function ChoiceController:SetChoiceEnd()
    if self.autoTestTimer then
        TimerMgr.Discard(self.autoTestTimer)
        self.autoTestTimer = 0
    end
    self.choiceEnd = true
    self:CheckCostCTSEvent()
    self:CheckHideText()
    self.system:EndAutoTimer()
    EventMgr.Dispatch("DialoguePanelChoiceHide", self:GetUIData())
    EventMgr.RemoveListener("DialoguePanelChoiceClicked", self.OnChoiceClick, self)
    self:ResumeUpdate()
end

---如果有配置显示数量就需要做一下随机筛选
function ChoiceController:GetShowingChoiceList()
    if (self.dialogueEntry.qteCount == 0) or (#self.choicePool <= self.dialogueEntry.qteCount) then
        self.showingChoiceList = self.choicePool
    else
        local randomPool = table.clone(self.choicePool)
        self.showingChoiceList = {}
        for i = 1, self.dialogueEntry.qteCount do
            local randomChoice = self:RandomChoice(randomPool)
            table.removebyvalue(randomPool, randomChoice)
            table.insert(self.showingChoiceList, #self.showingChoiceList + 1, randomChoice)
        end
    end
end

---根据配置权重随机选择一个选项
---@param randomPool table<ChoiceOptionData> 选项随机池
---@return ChoiceOptionData
function ChoiceController:RandomChoice(randomPool)
    local weightAll = 0
    for _, optionData in pairs(randomPool) do
        weightAll = weightAll + optionData.weight
    end

    local random = self:GetRandom(0, weightAll)
    for i = 1, #randomPool do
        if random < randomPool[i].weight then
            return randomPool[i]
        else
            random = random - randomPool[i].weight
        end
    end

    return nil
end

---传给UI的初始化数据
---@return DialogueUIChoiceData
function ChoiceController:GetUIData()
    if self.uiChoiceData == nil then
        ---@type DialogueUIChoiceData
        self.uiChoiceData = { }
        self.uiChoiceData.choices = self.showingChoiceList
        self.uiChoiceData.choiceStyleSetting = self.database:GetChoiceStyleSetting(self.dialogueEntry.choiceStyleSetting)
        if self.uiChoiceData.choiceStyleSetting.choicePositionType == DialogueEnum.DialoguePositionType.Target then
            self.uiChoiceData.followTarget = self.system:GetDynamicTarget(self.textData.choiceStyleSetting.choiceTarget)
        end
        self.uiChoiceData.pipelineKey = self.pipeline:GetUniqueId()
        self.uiChoiceData.nodePlayerId = self.nodePlayer:GetPlayerId()
    end
    return self.uiChoiceData
end

---@param semanticDict table<int, string>
function ChoiceController:PackSemanticGroupIDList(semanticDict)
    for _, v in pairs(self.showingChoiceList) do
        if v.semanticGroupID ~= 0 then
            semanticDict[v.semanticGroupID] = self.pipeline:GetUniqueId()
        end
    end
end

---@param id int 命中的语义组Id
function ChoiceController:HitSemanticGroupID(id)
    if #self.showingChoiceList > 0 then
        for i = 1, #self.showingChoiceList do
            if self.showingChoiceList[i].semanticGroupID == id then
                EventMgr.Dispatch("DialoguePanelChoiceSelect", i)
                break
            end
        end
    end
end

---自动点击
function ChoiceController:OnDialogueAutoClicked()
    self.super.OnDialogueAutoClicked(self)
    if self.choiceInited and #self.showingChoiceList <= 1 then
        EventMgr.Dispatch("DialoguePanelChoiceSelect", 1)
    end
end

---销毁逻辑
function ChoiceController:Dispose()
    if self.choiceEnd == false then
        EventMgr.Dispatch("DialoguePanelChoiceHide", self:GetUIData())
    end
    PoolUtil.ReleaseTable(self.choicePool)
    self.choicePool = nil
    PoolUtil.ReleaseTable(self.showingChoiceList)
    self.showingChoiceList = nil
    EventMgr.RemoveListener("DialoguePanelChoiceClicked", self.OnChoiceClick, self)
    self.super.Dispose(self)
end

return ChoiceController