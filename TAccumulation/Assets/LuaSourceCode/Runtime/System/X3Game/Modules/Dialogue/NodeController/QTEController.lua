---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-08-28 15:18:13
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local QTEOptionData = require("Runtime.System.X3Game.Modules.Dialogue.Data.QTEOptionData")
local DialogueTextUtil = require("Runtime.System.X3Game.Modules.Dialogue.Util.DialogueTextUtil")

local NodeController = require("Runtime.System.X3Game.Modules.Dialogue.NodeController.NodeController")
---@class QTEController:NodeController
local QTEController = class("QTEController", NodeController, nil ,true)

---@class DialogueUIQTEData
---@field qtes table<QTEOptionData> qte选择池
---@field useQTEProgressDefaultPos boolean qte进度条使用默认位置
---@field qteProgressPos Vector2 qte进度条位置
---@field progress float qte时间进度

---初始化数据
function QTEController:OnInit()
    self.super.OnInit(self)
    self.nodeControllerType = DialogueEnum.DialogueConditionType.QTE
    ---@type boolean qte结束
    self.qteEnd = false
    ---@type boolean qte初始化完成
    self.qteInited = false
    ---@type table<QTEOptionData> 所有满足条件的qte
    self.qtePool = {}
    ---@type table<QTEOptionData> 最终显示出来的固定数量的qte列表
    self.showingQTEList = {}
    ---@type Link fallback选项
    self.fallbackLink = nil
    ---@type Link 除动态选项外额外加的选项
    self.dynamicClickLink = nil
    ---@type float 记录下文字结束的时间，用来Tick选项的倒计时
    self.dialogueEndDuration = 0
    ---@type int 长按Index
    self.longPressingIndex = 0
    ---@type float 已经长按的时长
    self.longPressingTime = 0
    ---@type Link 最后选择的Link
    self.selectedLink = nil
    ---@type DialogueUIQTEData
    self.uiQTEData = nil
end

---节点是否已完成
---@return boolean
function QTEController:IsNodeEnd()
    return self.super.IsNodeEnd(self) and self.qteEnd
end

---是否等待节点结束
---@return boolean
function QTEController:IsWaitForEnd()
    return self.super.IsWaitForEnd(self) and self.qteEnd
end

---是否可以消耗CTS事件帧
---@return boolean
function QTEController:CanCostCTSEvent()
    return self.super.CanCostCTSEvent(self) and self.qteEnd
end

---是否可以隐藏Text
---@return boolean
function QTEController:CanHideText()
    return self.super.CanHideText(self) and self.qteEnd
end

---节点强制结束
function QTEController:ForceEnd()
    self.super.ForceEnd(self)
    self:SetQTEEnd()
end

---CTS事件后的初始化逻辑
function QTEController:StartNode()
    self.super.StartNode(self)
    local selectedAll, fallbackLink = self:SelectedAllKeySelections()
    if self.dialogueEntry.loopSelection and selectedAll then
        self.selectedLink = fallbackLink
        self:ClearSelectionRecord()
        self:SetQTEEnd()
        return
    end
    self.qtePool = {}
    if self.dialogueEntry.outgoingLinks then
        for _, link in pairs(self.dialogueEntry.outgoingLinks) do
            if link.conditionData.isFallback == false then
                local nextDialogueEntry = self.database:GetDialogueEntryByLink(link)
                local isSatisfiedCondition = ConditionCheckUtil.CheckConditionCheckData(link.conditionData.conditionCheckDatas, self.system:GetDataProvider())
                if self:IsValidLink(link, isSatisfiedCondition) then
                    ---@type QTEOptionData
                    local optionData = QTEOptionData.new()
                    if self.fallbackLink == nil then
                        self.fallbackLink = link
                    end
                    optionData.text = DialogueTextUtil.GetMenuText(self.dialogueId, nextDialogueEntry)
                    optionData.weight = link.conditionData.randomWeight
                    optionData.link = link
                    optionData.isSatisfiedCondition = isSatisfiedCondition
                    local desc = {}
                    if link.conditionData.conditionCheckDatas then
                        for i = 1, #link.conditionData.conditionCheckDatas do
                            if link.conditionData.conditionCheckDatas[i].id == X3_CFG_CONST.CONDITION_COMMONCONDITION then
                                local conditionGroup = tonumber(link.conditionData.conditionCheckDatas[i].paramList[1])
                                table.insert(desc, #desc + 1, ConditionCheckUtil.GetAllConditionDescByGroupId(conditionGroup))
                            end
                        end
                    end
                    optionData.semanticGroupID = link.conditionData.semanticGroupID
                    optionData.conditionCheckMessage = table.concat(desc, ',')
                    self:SetQTESetting(optionData, link.conditionData)
                    table.insert(self.qtePool, #self.qtePool + 1, optionData)
                end
            else
                self.fallbackLink = link
            end
        end
    end

    self:GetShowingQTEList()

    EventMgr.AddListener("DialoguePanelQTEClicked", self.OnQTEClick, self)
    EventMgr.AddListener("DialoguePanelQTETouchDown", self.OnQTETouchDown, self)
    EventMgr.AddListener("DialoguePanelQTETouchUp", self.OnQTETouchUp, self)
end

---节点的Tick
---@param deltaTime float update函数传过来的时长
function QTEController:ProcessFrame(deltaTime)
    self.super.ProcessFrame(self, deltaTime)
    if self.qteEnd == false and self.dialogueEnd and self.voiceEnd and self.CTSEventEnd and self.eventEnd then
        if self.qteInited == false then
            EventMgr.Dispatch("DialoguePanelQTEShow", self:GetUIData())
            self.qteInited = true
            self.dialogueEndDuration = self.dialogueTime
            if self.dialogueEntry.hideDialogueWhenShowChoice then
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
        --Debug长按快播模式下自动跳过单一QTE
        if DEBUG_GM and DialogueManager.GetLongPressSkipBranch()
                and self.system:IsInSkipMode() and #self.showingQTEList <= 1 then
            self:OnQTEClick(1)
            return
        else
            self.system:StopSkipMode()
        end
        self.clickState = DialogueEnum.TextClickState.None
        local progress = -1
        local longPressProgress = -1
        if self.longPressingIndex > 0 then
            self.longPressingTime = self.longPressingTime + deltaTime
            self.dialogueTime = self.dialogueTime - deltaTime --长按时需要停止计时
            longPressProgress = self.longPressingTime / self.showingQTEList[self.longPressingIndex].longPressDuration
        end
        if self.dialogueTime - self.dialogueEndDuration >= self.dialogueEntry.qteDelay then
            if self.dialogueEntry.qteDuration > 0 then
                local normalizedTime = (self.dialogueTime - self.dialogueEndDuration - self.dialogueEntry.qteDelay) / self.dialogueEntry.qteDuration
                if normalizedTime > 1 then
                    self.selectedLink = self.fallbackLink
                    EventMgr.Dispatch("DialoguePanelQTEHide", self:GetUIData())
                    self:SetQTEEnd()
                else
                    progress = 1 - normalizedTime
                    EventMgr.Dispatch("DialoguePanelQTEUpdate", progress, longPressProgress, self.longPressingIndex)
                end
            else
                EventMgr.Dispatch("DialoguePanelQTEUpdate", progress, longPressProgress, self.longPressingIndex)
            end
        end
    end
end

---节点流程记录
---@param nextLink Link 该节点的下一个
function QTEController:ProcessSave(nextLink)
    local node = {}
    node.Id = self.dialogueEntry.uniqueID
    local nextDialogueEntry = self.database:GetDialogueEntryByLink(nextLink)
    node.NextId = nextDialogueEntry.uniqueID
    node.VariableMap = self:ProcessNodeVariableChange()
    self.system:AddProcessNode(node)
end

---分析Link，判断节点结束后需要去哪个节点
function QTEController:AnalyzeLink()
    self.settedNextLink = DialogueManager.GetSettedLink(self.database, self.dialogueEntry.uniqueID)
    if self.settedNextLink == nil then
        self:RecordSelection(self.selectedLink)
        self:AddWaitNode(self.selectedLink)
        self:ProcessSave(self.selectedLink)
    else
        self:RecordSelection(self.settedNextLink)
        self:AddWaitNode(self.settedNextLink)
        self:ProcessSave(self.settedNextLink)
        self:SetQTEEnd()
    end
end

---qte回调
---@param index int 选择了哪个qte
function QTEController:OnQTEClick(index)
    self.longPressingIndex = 0
    self.longPressingTime = 0
    local selectedQTE = self.showingQTEList[index]
    self.system:ChangeVariableState(selectedQTE.variableID, selectedQTE.variableValue)
    if selectedQTE.link ~= nil then
        self.selectedLink = selectedQTE.link
    else
        self.selectedLink = self.dynamicClickLink
    end
    self:SetQTEEnd()
end

---自动测试选择
function QTEController:AutoTestSelect()
    for i = 1, #self.showingQTEList do
        if self.showingQTEList[i].isSatisfiedCondition then
            self:OnQTEClick(i)
            Debug.LogFormat("[DialogueSystem]自动模式QTE选择-%s", i)
            return
        end
    end
end

---
function QTEController:CheckPlayerOperation()
    self:SetQTEEnd()
end

---qte按下事件，长按用
---@param index int 长按了哪个qte
function QTEController:OnQTETouchDown(index)
    self.longPressingIndex = index
    self.longPressingTime = 0
end

---qte抬起事件，终止长按
function QTEController:OnQTETouchUp()
    self.longPressingIndex = 0
end

---qte结束
function QTEController:SetQTEEnd()
    if self.autoTestTimer then
        TimerMgr.Discard(self.autoTestTimer)
        self.autoTestTimer = 0
    end
    self.qteEnd = true
    self:CheckCostCTSEvent()
    self:CheckHideText()
    self.system:EndAutoTimer()
    EventMgr.Dispatch("DialoguePanelQTEHide", self:GetUIData())
    EventMgr.RemoveListener("DialoguePanelQTEClicked", self.OnQTEClick, self)
    self:ResumeUpdate()
end

---如果有配置显示数量就需要做一下随机筛选
function QTEController:GetShowingQTEList()
    if self.dialogueEntry.qteCount == 0 or #self.qtePool <= self.dialogueEntry.qteCount then
        self.showingQTEList = self.qtePool
    else
        local randomPool = {}
        for i = 1, #self.qtePool + 1 do
            table.insert(randomPool, #randomPool + 1, self.qtePool[i])
        end
        self.showingQTEList = {}
        for i = 1, self.dialogueEntry.qteCount do
            local randomQTE = self:RandomQTE(randomPool)
            table.removebyvalue(randomPool, randomQTE)
            table.insert(self.showingQTEList, #self.showingQTEList + 1, randomQTE)
        end
    end
end

---根据配置权重随机选择一个选项
---@param randomPool QTEOptionData[] 选项随机池
---@return QTEOptionData
function QTEController:RandomQTE(randomPool)
    local weightAll = 0
    for i, qteData in pairs(randomPool) do
        weightAll = weightAll + qteData.weight
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

---给QTEData设置位置及跟随数据
---@param qteData QTEOptionData
---@param conditionData ConditionData
function QTEController:SetQTESetting(qteData, conditionData)
    local nodeStyleSetting = self.database:GetQTEStyleSetting(self.dialogueEntry.qteStyleSetting)
    if self.dialogueEntry.qteClickType ~= DialogueEnum.QTEClickType.DIY and nodeStyleSetting.qteStyle ~= DialogueEnum.QTEStyle.DIY then
        qteData.qteClickType = self.dialogueEntry.qteClickType
        qteData.qteStyleSetting = nodeStyleSetting
        qteData.qtePositionType = conditionData.qteSetting.qtePositionType
        if qteData.qtePositionType == DialogueEnum.QTEPositionType.Position then
            qteData.qtePosition = Vector2.new(conditionData.qteSetting.qtePosition.x, conditionData.qteSetting.qtePosition.y)
        elseif qteData.qtePositionType == DialogueEnum.QTEPositionType.Target then
            local qteTarget = self.system:GetDynamicTarget(qteData.qteTarget)
            if qteTarget then
                qteData.followTransform = qteTarget.transform
                qteData.followOffset = conditionData.qteSetting.followOffset
            end
        end
        qteData.isQTEFollow = conditionData.qteSetting.isQTEFollow
    else
        qteData.qteClickType = conditionData.qteSetting.qteClickType
        qteData.qteStyleSetting = self.database:GetQTEStyleSetting(conditionData.qteSetting.qteStyleSetting)
        qteData.qtePositionType = conditionData.qteSetting.qtePositionType
        if qteData.qtePositionType == DialogueEnum.QTEPositionType.Position then
            qteData.qtePosition = Vector2.new(conditionData.qteSetting.qtePosition.x, conditionData.qteSetting.qtePosition.y)
        elseif qteData.qtePositionType == DialogueEnum.QTEPositionType.Target then
            local qteTarget = self.system:GetDynamicTarget(conditionData.qteSetting.qteTarget)
            if qteTarget then
                qteData.followTransform = qteTarget.transform
                qteData.followOffset = conditionData.qteSetting.followOffset
            end
        end
        qteData.isQTEFollow = conditionData.qteSetting.isQTEFollow
    end

    --qteSetting是一个静态配置，不要直接引用
    qteData.slideStartPosition = conditionData.qteSetting.slideStartPosition
    qteData.slideStartPosRange = conditionData.qteSetting.slideStartPosRange
    qteData.slideBezierPosition = conditionData.qteSetting.slideBezierPosition
    qteData.slideEndPosition = conditionData.qteSetting.slideEndPosition
    qteData.slideRotation = conditionData.qteSetting.slideRotation
    qteData.slideSpeed = conditionData.qteSetting.slideSpeed
    qteData.useTextDefaultPosition = conditionData.qteSetting.useTextDefaultPosition
    qteData.textPosition = conditionData.qteSetting.textPosition
    qteData.textRotation = conditionData.qteSetting.textRotation
    if not conditionData.qteSetting.useDefaultBlowSetting then
        qteData.blowVolume = conditionData.qteSetting.blowVolume
        qteData.frameCount = conditionData.qteSetting.frameCount
    else
        --TODO 配Sundry表？
        qteData.blowVolume = 3
        qteData.frameCount = 10
    end
    if qteData.qteClickType == DialogueEnum.QTEClickType.Blow then
        qteData.longPressDuration = qteData.frameCount * 1 / GameMgr.GetFps()
    else
        qteData.longPressDuration = conditionData.qteSetting.longPressDuration
    end
    qteData.continuousClickTimes = conditionData.qteSetting.continuousClickTimes and conditionData.qteSetting.continuousClickTimes or 0
    qteData.touchTimes = conditionData.qteSetting.touchTimes
    qteData.touchOffset = conditionData.qteSetting.touchOffset
    qteData.touchFX = conditionData.qteSetting.touchFX
    qteData.voiceGroupID = conditionData.qteSetting.voiceGroupID
end

---传给UI的初始化数据
---@return DialogueUIQTEData
function QTEController:GetUIData()
    if self.uiQTEData == nil then
        self.uiQTEData = {}
        self.uiQTEData.qtes = self.showingQTEList
        self.uiQTEData.useQTEProgressDefaultPos = self.dialogueEntry.useQTEProgressDefaultPos
        self.uiQTEData.qteProgressPos = self.dialogueEntry.qteProgressPos
        self.uiQTEData.pipelineKey = self.pipeline:GetUniqueId()
        self.uiQTEData.nodePlayerId = self.nodePlayer:GetPlayerId()
    end
    return self.uiQTEData
end

---打包当前需要侦听的语义组Id
---@param semanticDict table<int, string>
function QTEController:PackSemanticGroupIDList(semanticDict)
    for _, v in pairs(self.showingQTEList) do
        if v.semanticGroupID ~= 0 then
            semanticDict[v.semanticGroupID] = self.pipeline:GetUniqueId()
        end
    end
end

---尝试命中语义组Id
---@param id int 命中的语义组Id
function QTEController:HitSemanticGroupID(id)
    if #self.showingQTEList > 0 then
        for i = 1, #self.showingQTEList do
            if self.showingQTEList[i].semanticGroupID == id then
                EventMgr.Dispatch("DialoguePanelQTESelect", i)
                break
            end
        end
    end
end

---自动点击
function QTEController:OnDialogueAutoClicked()
    self.super.OnDialogueAutoClicked(self)
    if self.qteInited and #self.showingQTEList <= 1 then
        EventMgr.Dispatch("DialoguePanelQTESelect", 1)
    end
end

---销毁
function QTEController:Dispose()
    if self.qteEnd == false then
        EventMgr.Dispatch("DialoguePanelQTEHide", self:GetUIData())
    end
    self.super.Dispose(self)
end

return QTEController