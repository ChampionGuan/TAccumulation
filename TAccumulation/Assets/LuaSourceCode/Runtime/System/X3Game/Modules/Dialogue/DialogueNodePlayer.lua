﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/3/16 12:06
---

---一个节点栈，遵循先进后出
---@class DialogueNodePlayer
local DialogueNodePlayer = class("DialogueNodePlayer")

---构造函数
function DialogueNodePlayer:ctor()
    ---@type table<DialogueEntry> 等待播放的节点队列
    self.waitNodeQueue = {}
    ---@type DialogueEntry 剧情播放的结束节点，如果有赋值，则播放到该节点结束剧情
    self.needEndDialogueEntry = nil
    ---@type DialogueEntry 当前的节点数据
    self.curDialogueEntry = nil
    ---@type NodeController 当前正在执行的节点
    self.curNodeController = nil
    ---@type DialogueEnum.NodePlayerState
    self.playerState = DialogueEnum.NodePlayerState.None
    ---@type table<pbcmessage.DialogueRecord> 剧情回顾列表
    self.dialogueRecordList = {}
    ---@type int 已经回放完的数量
    self.recoveredCount = 0
    ---@type int 最后一个有CTS的节点Id，在快播到该节点时需要切换CTS快播模式
    self.lastHasCutSceneNodeId = 0
    ---@type fun 回放模式的Update
    self.dialogueRecoverUpdateCallback = nil
    ---@type fun 回放模式的回调
    self.dialogueRecoverCplCallback = nil
    ---@type int[] 并行模式下子NodePlayer列表
    self.subPlayerList = {}
    ---@type boolean 是否需要记录播放流程
    self.needSaveProcess = true
    ---@type table<int, table<int, bool>> 必选选项已选择记录
    self.selectionRecord = {}

    ---Context
    ---@type int 节点栈Id
    self.playerId = 0
    ---@type DialogueSystem
    self.system = nil
    ---@type DialoguePipeline
    self.pipeline = nil
    ---@type DialogueDatabase
    self.database = nil
end

---设置上下文
---@param playerId int
---@param system DialogueSystem
---@param pipeline DialoguePipeline
---@param database DialogueDatabase
function DialogueNodePlayer:SetContext(playerId, system, pipeline, database)
    self.playerId = playerId
    self.system = system
    self.pipeline = pipeline
    self.database = database
end

---获取PlayerId
---@return int
function DialogueNodePlayer:GetPlayerId()
    return self.playerId
end

---是否需要记录播放流程
---@param value boolean
function DialogueNodePlayer:NeedSaveProcess(value)
    self.needSaveProcess = value
end

---添加一个节点记录
---@param node pbcmessage.DialogueProcessNode
function DialogueNodePlayer:AddProcessNode(node)
    if self.needSaveProcess then
        self.system:AddProcessNode(node)
    end
end

---@param node pbcmessage.DialogueProcessNode
function DialogueNodePlayer:SetLastProcessNode(node)
    if self.needSaveProcess then
        self.system:SetLastProcessNode(node)
    end
end

---节点Tick
---@param deltaTime float
function DialogueNodePlayer:UpdateNode(deltaTime)
    if self.playerState == DialogueEnum.NodePlayerState.WaitToRunning then
        if DialogueManager.GetUIOpened() then
            self.playerState = DialogueEnum.NodePlayerState.Running
        else
            self.system:OpenUI()
            return
        end
    end
    if self.playerState == DialogueEnum.NodePlayerState.FrameLock then
        self.playerState = DialogueEnum.NodePlayerState.Running
        return
    end
    if self.playerState == DialogueEnum.NodePlayerState.Running then
        if self.curNodeController == nil then
            if #self.waitNodeQueue > 0 then
                self:GotoNextNode(false)
            else
                self.playerState = DialogueEnum.NodePlayerState.Complete
                return
            end
        end
        if self.curNodeController then
            self.curNodeController:ProcessFrame(deltaTime)
            ---在这里有可能因为退出条件的设置剧情直接就结束了
            if self.curNodeController:IsNodeEnd() then
                if UNITY_EDITOR then
                    self.pipeline:AddPlayedRuntimeEntries(self.curDialogueEntry.uniqueID)
                end
                Debug.LogFormat("[DialogueSystem]节点结束-%s-%s", self.system.dialogueInfoId, self.curDialogueEntry.uniqueID)
                self.curNodeController:End()
                self.curNodeController:Dispose()
                ---上一个节点结束了抛个事件出去
                self.curNodeController = nil
                if self.needEndDialogueEntry ~= nil and self.needEndDialogueEntry.conversationID == self.curDialogueEntry.conversationID
                        and self.needEndDialogueEntry.id == self.curDialogueEntry.id then
                    table.clear(self.waitNodeQueue)
                end
                EventMgr.Dispatch("DialogueEntryEnd", self.curDialogueEntry)
                self.curDialogueEntry = nil
                if self.pipeline:IsRunning() then
                    self:GotoNextNode(false)
                    if self.playerState == DialogueEnum.NodePlayerState.Running then
                        self:UpdateNode(0)
                    end
                end
                --[[            --下一次Update的开始再初始化节点，避免上一个节点的Action还没有来得及Tick就直接进入了下一个节点2022/5/16
                            self:GotoNextNode(false)
                            ---抛出事件帧的当帧进行换装会有BUG，先这么处理
                            if self.recoverDialogueMode then
                                --回放模式立即Tick
                                self:Update(0)
                            end]]
            end
        end
    elseif self.playerState == DialogueEnum.NodePlayerState.Waiting then
        local isCpl = true
        for _,playerId in pairs(self.subPlayerList) do
            if self.pipeline:IsPlayerCpl(playerId) == false then
                isCpl = false
            end
        end
        if isCpl then
            self.playerState = DialogueEnum.NodePlayerState.Running
        end
    end
end

---
---@param playerId int
function DialogueNodePlayer:WaitSubPlayer(playerId)
    if table.indexof(self.subPlayerList, playerId) == false then
        table.insert(self.subPlayerList, #self.subPlayerList + 1, playerId)
    end
    self.playerState = DialogueEnum.NodePlayerState.Waiting
end

---是否正在运行中
---@return boolean
function DialogueNodePlayer:IsRunning()
    return self.playerState ~= DialogueEnum.NodePlayerState.None
            and self.playerState ~= DialogueEnum.NodePlayerState.Complete
end

---是否播放完成
---@return boolean
function DialogueNodePlayer:IsComplete()
    return self.playerState == DialogueEnum.NodePlayerState.None
            or self.playerState == DialogueEnum.NodePlayerState.Complete
end

---以某种退出方式暂停播放
function DialogueNodePlayer:PauseWithExitKey()
    if self.curDialogueEntry then
        --下次需要以当前节点继续播放
        self:AddWaitNodeByEntry(self.curDialogueEntry)
        self.curNodeController = nil
        self.curDialogueEntry = nil
    end
end

---
function DialogueNodePlayer:CheckPlayerOperation()
    if self.curNodeController then
        self.curNodeController:CheckPlayerOperation()
    end
end

---@return bool
function DialogueNodePlayer:CanStartSkipMode()
    if self.database and self.curDialogueEntry then
        if self.curDialogueEntry.conditionType == DialogueEnum.DialogueConditionType.Choice
                or self.curDialogueEntry.conditionType == DialogueEnum.DialogueConditionType.QTE
                or self.curDialogueEntry.conditionType == DialogueEnum.DialogueConditionType.CommonStage then
            return false
        else
            return true
        end
    else
        return false
    end
end

---取得最后一个有CutScene的节点Id
---@return int
function DialogueNodePlayer:CheckLastHasCutSceneNodeId()
    local lastCutSceneNodeId = 0
    local waitNodeQueue = {}
    local curDialogueEntry = nil
    local checkedCnt = 0
    local cloneDialogueRecordList = table.clone(self.dialogueRecordList)
    if cloneDialogueRecordList and #cloneDialogueRecordList > 0 then
        while #cloneDialogueRecordList > 0 do
            checkedCnt = checkedCnt + 1
            if checkedCnt >= 10000 then
                Debug.LogError("[DialogueSystem]出现死循环，请检查")
                return lastCutSceneNodeId
            end
            if #waitNodeQueue > 0 then
                curDialogueEntry = waitNodeQueue[#waitNodeQueue]
                if DialogueUtil.HasCutScene(self.database, curDialogueEntry) then
                    lastCutSceneNodeId = curDialogueEntry.uniqueID
                end
                table.remove(waitNodeQueue, #waitNodeQueue)
                local settedNextLink = nil
                local dialogueRecord = cloneDialogueRecordList[1]
                local nextDialogueEntry = nil
                if curDialogueEntry.uniqueID == dialogueRecord.Id then
                    table.remove(cloneDialogueRecordList, 1)
                    if curDialogueEntry.outgoingLinks ~= nil then
                        for i = 1, #curDialogueEntry.outgoingLinks do
                            if self.database:GetDialogueEntryByLink(curDialogueEntry.outgoingLinks[i]).uniqueID == dialogueRecord.NextID then
                                settedNextLink = curDialogueEntry.outgoingLinks[i]
                            end
                        end
                    end
                end
                if settedNextLink then
                    nextDialogueEntry = self.database:GetDialogueEntryByLink(settedNextLink)
                    table.insert(waitNodeQueue, #waitNodeQueue + 1, nextDialogueEntry)
                else
                    if curDialogueEntry.outgoingLinks ~= nil then
                        for i, link in pairs(curDialogueEntry.outgoingLinks) do
                            nextDialogueEntry = self.database:GetDialogueEntryByLink(curDialogueEntry.outgoingLinks[i])
                            table.insert(waitNodeQueue, #waitNodeQueue + 1, nextDialogueEntry)
                        end
                    end
                end
            else
                local dialogueRecord = cloneDialogueRecordList[1]
                table.insert(waitNodeQueue, #waitNodeQueue + 1, self.database:GetDialogueEntryByUniqueID(dialogueRecord.Id))
            end
        end
    end
    return lastCutSceneNodeId
end

---根据配置数据重新播放一个剧情
---@param replayData table
---@param recoverUpdateCallback fun 恢复过程回调
function DialogueNodePlayer:ReplayDialogue(replayData, recoverUpdateCallback)
    local realStartEntry = self.database:GetDialogueEntry(replayData.realStartConversation, replayData.realStartNodeID)
    local startEntry = self.database:GetDialogueEntry(replayData.startConversation, replayData.startNodeID)
    if nil ~= startEntry then
        if replayData.realStartConversation == 0 or realStartEntry == startEntry then
            table.insert(self.waitNodeQueue, #self.waitNodeQueue + 1, startEntry)
            self.needEndDialogueEntry = self.database:GetDialogueEntry(replayData.endConversation, replayData.endNodeID)
            self.playerState = DialogueEnum.NodePlayerState.WaitToRunning
            self:GotoNextNode(true)
        else
            self.system:SaveVolume()
            self.dialogueRecoverUpdateCallback = recoverUpdateCallback
            self.recoveredCount = 0
            self.dialogueRecordList = {}
            local startRecord = {}
            startRecord.Id = startEntry.uniqueID
            table.insert(self.dialogueRecordList, #self.dialogueRecordList + 1, startRecord)
            if nil ~= realStartEntry then
                local realStartRecord = {}
                realStartRecord.Id = realStartEntry.uniqueID
                realStartRecord.realStartNode = true
                table.insert(self.dialogueRecordList, #self.dialogueRecordList + 1, realStartRecord)
            end
            self.lastHasCutSceneNodeId = self:CheckLastHasCutSceneNodeId()
            self.system:ChangeDialogueSpeed(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DIALOGUEQUICKSPEED))
            self.system:OpenUI()
            self.playerState = DialogueEnum.NodePlayerState.WaitToRunning
            self:GotoNextNode(true)
        end
        return true
    else
        return false
    end
end

---根据配置数据恢复一个剧情并且继续播放
---@param dialogueRecordList pbcmessage.DialogueRecord[]
---@param recoverUpdateCallback fun 恢复过程回调
---@return bool
function DialogueNodePlayer:RecoverDialogue(dialogueRecordList, recoverUpdateCallback, recoverCplCallback)
    self.dialogueRecoverUpdateCallback = recoverUpdateCallback
    self.dialogueRecoverCplCallback = recoverCplCallback
    self.recoveredCount = 0
    self.dialogueRecordList = GameHelper.ToTable(dialogueRecordList)
    self.lastHasCutSceneNodeId = self:CheckLastHasCutSceneNodeId()
    self.system:ChangeDialogueSpeed(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DIALOGUEQUICKSPEED))
    self.system:OpenUI()
    self.playerState = DialogueEnum.NodePlayerState.WaitToRunning
    self:GotoNextNode(false)
end

---播放某一段Conversation
---@param startConversationId int 起始ConversationID
---@param startNodeId int 起始节点ID
---@param endConversationId int 结束ConversationID
---@param endNodeId int 结束节点ID
---@return bool
function DialogueNodePlayer:StartDialogueRange(startConversationId, startNodeId,
                                              endConversationId, endNodeId)
    local startConversation = self.database:GetConversation(startConversationId)
    if startConversation ~= nil then
        local startEntry = self.database:GetDialogueEntry(startConversationId, startNodeId)
        if startEntry ~= nil then
            table.insert(self.waitNodeQueue, #self.waitNodeQueue + 1, startEntry)
            self.needEndDialogueEntry = self.database:GetDialogueEntry(endConversationId, endNodeId)
            self.system:OpenUI()
            self.playerState = DialogueEnum.NodePlayerState.WaitToRunning
            self:GotoNextNode(true)
        end
        return true
    else
        return false
    end
end

---剧情恢复结束
function DialogueNodePlayer:RecoverDialogueComplete()
    self:CreateNodeController()
    if self.dialogueRecoverCplCallback then
        self.dialogueRecoverCplCallback()
        self.dialogueRecoverCplCallback = nil
    end
    --此时会有速度恢复，锁一帧再播放逻辑
    self.playerState = DialogueEnum.NodePlayerState.FrameLock
end

---开始播放一个Conversation
---@param startConversation Conversation 开始Conversation
---@param nodeId int 节点Id
---@return bool
function DialogueNodePlayer:StartDialogue(startConversation, nodeId)
    if nil ~= startConversation then
        local startEntry = nil
        if nodeId == nil or nodeId == 0 then
            startEntry = self.database:GetFirstDialogueEntry(startConversation)
        else
            startEntry = self.database:GetDialogueEntryInConversation(startConversation, nodeId)
        end

        table.insert(self.waitNodeQueue, #self.waitNodeQueue + 1, startEntry)
        self.system:OpenUI()
        self.playerState = DialogueEnum.NodePlayerState.WaitToRunning
        self:GotoNextNode(true)
        return true
    else
        return false
    end
end

---取得下个节点
---@param isDialogueStartNode boolean
function DialogueNodePlayer:GotoNextNode(isDialogueStartNode)
    if #self.waitNodeQueue > 0 then
        self.curDialogueEntry = self.waitNodeQueue[#self.waitNodeQueue]
        self.pipeline:ChangeNodeGraph(self.curDialogueEntry.nodeGraphKey, self.curDialogueEntry.uniqueID)
        if self.curDialogueEntry.sequenceTime > 0 then
            self.pipeline:AddPlayedActionNodeList(self.curDialogueEntry.uniqueID)
        end
        table.remove(self.waitNodeQueue, #self.waitNodeQueue)
        if self.pipeline:GetRecoverDialogueMode() then
            if #self.dialogueRecordList <= 0 then
                self:RecoverDialogueComplete()
            else
                local dialogueRecord = self.dialogueRecordList[1]
                if self.curDialogueEntry.uniqueID == dialogueRecord.Id and dialogueRecord.realStartNode then
                    self:RecoverDialogueComplete()
                else
                    self.curNodeController = DialogueManager.CreateNodeController(DialogueEnum.DialogueConditionType.QuickSequence)
                    self.curNodeController:OnInit()
                    self.curNodeController.needSave = false
                    if self.curDialogueEntry.uniqueID == dialogueRecord.Id then
                        self.recoveredCount = self.recoveredCount + 1
                        table.remove(self.dialogueRecordList, 1)
                        if self.curDialogueEntry.outgoingLinks then
                            for i = 1, #self.curDialogueEntry.outgoingLinks do
                                if self.database:GetDialogueEntryByLink(self.curDialogueEntry.outgoingLinks[i]).uniqueID == dialogueRecord.NextID then
                                    self.curNodeController.settedNextLink = self.curDialogueEntry.outgoingLinks[i]
                                end
                            end
                        end
                    end
                    if self.curDialogueEntry.uniqueID == self.lastHasCutSceneNodeId then
                        self.curNodeController.cutSceneFastMode = false
                        self.lastHasCutSceneNodeId = 0
                    elseif self.lastHasCutSceneNodeId > 0 then
                        self.curNodeController.cutSceneFastMode = true
                    end
                end
            end
            local recoverProgressRate = #self.dialogueRecordList > 0 and (self.recoveredCount / (self.recoveredCount + #self.dialogueRecordList)) or 1
            if self.dialogueRecoverUpdateCallback ~= nil then
                self.dialogueRecoverUpdateCallback(recoverProgressRate)
            end
        else
            self:CreateNodeController()
        end

        self.curNodeController.isDialogueStartNode = isDialogueStartNode
        self.curNodeController:SetContext(self.system, self.pipeline, self)
        Debug.LogFormat("[DialogueSystem]节点开始-%s-%s", self.system.dialogueInfoId, self.curDialogueEntry.uniqueID)
        self.curNodeController:InitFromEntry(self.curDialogueEntry)
    elseif self.pipeline:GetRecoverDialogueMode() then
        if #self.dialogueRecordList > 0 then
            local dialogueRecord = self.dialogueRecordList[1]
            table.insert(self.waitNodeQueue, #self.waitNodeQueue + 1, self.database:GetDialogueEntryByUniqueID(dialogueRecord.Id))
            self:GotoNextNode(false)
        end
    end
end

---根据当前节点使用不同的Controller控制
function DialogueNodePlayer:CreateNodeController()
    if self.debugQuickSequenceMode then
        self.curNodeController = DialogueManager.CreateNodeController(DialogueEnum.DialogueConditionType.QuickSequence)
    else
        self.curNodeController = DialogueManager.CreateNodeController(self.curDialogueEntry.conditionType)
    end
    self.curNodeController:OnInit()
end

---队列中增加一个节点
---@param link Link
function DialogueNodePlayer:AddWaitNode(link)
    local nextDialogueEntry = self.database:GetDialogueEntryByLink(link)
    self:AddWaitNodeByEntry(nextDialogueEntry)
end

---队列中增加一个节点
---@param dialogueEntry DialogueEntry
function DialogueNodePlayer:AddWaitNodeByEntry(dialogueEntry)
    table.insert(self.waitNodeQueue, #self.waitNodeQueue + 1, dialogueEntry)
end

---选项选择记录
---@param dialogueEntry DialogueEntry
---@param link Link
function DialogueNodePlayer:RecordSelection(dialogueEntry, link)
    local nextDialogueEntry = self.database:GetDialogueEntryByLink(link)
    if self.selectionRecord ~= nil then
        if self.selectionRecord[dialogueEntry.uniqueID] == nil then
            self.selectionRecord[dialogueEntry.uniqueID] = {}
        end
        self.selectionRecord[dialogueEntry.uniqueID][nextDialogueEntry.uniqueID] = true
    end
end

---选项是否选择过
---@param dialogueEntry DialogueEntry
---@param link Link
---@return bool
function DialogueNodePlayer:IsLinkSelected(dialogueEntry, link)
    if self.selectionRecord == nil or self.selectionRecord[dialogueEntry.uniqueID] == nil then
        return false
    end
    local nextDialogueEntry = self.database:GetDialogueEntryByLink(link)
    return self.selectionRecord[dialogueEntry.uniqueID][nextDialogueEntry.uniqueID] == true
end

---清理选项记录
---@param dialogueEntry DialogueEntry
function DialogueNodePlayer:ClearSelectionRecord(dialogueEntry)
    if self.selectionRecord ~= nil then
        self.selectionRecord[dialogueEntry.uniqueID] = nil
    end
end

---打包当前需要侦听的语义组Id
---@param semanticDict table<int, string>
function DialogueNodePlayer:PackSemanticGroupIDList(semanticDict)
    if self.curNodeController then
        self.curNodeController:PackSemanticGroupIDList(semanticDict)
    end
end

---尝试命中语义组Id
---@param id int 命中的语义组Id
function DialogueNodePlayer:HitSemanticGroupID(id)
    if self.curNodeController then
        self.curNodeController:HitSemanticGroupID(id)
    end
end

---销毁
function DialogueNodePlayer:Dispose()
    if self.curNodeController ~= nil then
        self.curNodeController:Dispose()
        self.curNodeController = nil
    end
    self.curDialogueEntry = nil
    self.dialogueRecordList = nil
    table.clear(self.selectionRecord)
end

return DialogueNodePlayer