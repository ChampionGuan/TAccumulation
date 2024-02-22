---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-08-18 11:02:11
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class DialogueDatabase
---@field data cfg.Dialogue 剧情配置数据
---@field name string 剧情名
local DialogueDatabase = class("DialogueDatabase")

local ActionTemplatePath = "DialogueCfg.Template.Action."
local DialogueStyleTemplatePath = "DialogueCfg.Template.DialogueStyle."
local ChoiceStyleTemplatePath = "DialogueCfg.Template.ChoiceStyle."

local CutSceneCollector = CS.PapeGames.CutScene.CutSceneCollector
local SVCHelper = CS.PapeGames.X3.SVCHelper

---构造函数
function DialogueDatabase:ctor()
    ---@type cfg.Dialogue 剧情配置数据
    self.data = nil
    ---@type string 剧情名
    self.name = nil
    ---@type table<int, DialogueEntry> 剧情节点索引Dict
    self.dialogueEntryDict = {}
    ---@type NodeGraph[] 剧情子树图
    self.nodeGraphList = {}
    ---@type table<int, string> 根据节点ID，反向查找所述NodeGraph
    self.nodeGraphKeyDict = {}
    ---@type table<int, string>
    self.actionTemplatePath = {}
    ---@type table<int, string>
    self.dialogueStyleTemplatePath = {}
    ---@type table<int, string>
    self.choiceStyleTemplatePath = {}
    ---@type table<string, string[]> 每个NodeGraph
    self.svcPreloadDict = {}
end

---剧情数据初始化
---@param assetName string 剧情名字
function DialogueDatabase:Init(assetName)
    self.data = LuaCfgMgr.Get(string.concat("DialogueCfg.", assetName), 1)
    self.name = assetName
    if self.data.nodeGraph then
        for i = 1, #self.data.nodeGraph do
            ---@type NodeGraph
            local nodeGraph = self.data.nodeGraph[i]
            self.nodeGraphList[self.data.nodeGraph[i].uniqueID] = nodeGraph
            if nodeGraph.sequenceNodeList then
                for j = 1, #nodeGraph.sequenceNodeList do
                    self.nodeGraphKeyDict[nodeGraph.sequenceNodeList[j]] = self.data.nodeGraph[i].uniqueID
                end
            end
        end
    end
    --缓存所有DialogueEntry
    if self.data.conversations then
        for i = 1, #self.data.conversations do
            local dialogueEntries = self.data.conversations[i].dialogueEntries
            if dialogueEntries then
                for j = 1, #dialogueEntries do
                    local uniqueID = self:GetUniqueID(dialogueEntries[j].conversationID, dialogueEntries[j].id)
                    self.dialogueEntryDict[uniqueID] = dialogueEntries[j]
                end
            end
        end
    end
    if self.data.actionTemplateList then
        for i = 1, #self.data.actionTemplateList do
            if string.isnilorempty(self.data.actionTemplateList[i].name) == false then
                self.actionTemplatePath[self.data.actionTemplateList[i].id] = string.concat(ActionTemplatePath, self.data.actionTemplateList[i].name)
            end
        end
    end
    if self.data.dialogueStyleTemplateList then
        for i = 1, #self.data.dialogueStyleTemplateList do
            if string.isnilorempty(self.data.dialogueStyleTemplateList[i].name) == false then
                self.dialogueStyleTemplatePath[self.data.dialogueStyleTemplateList[i].id] = string.concat(DialogueStyleTemplatePath, self.data.dialogueStyleTemplateList[i].name)
            end
        end
    end
    if self.data.choiceStyleTemplateList then
        for i = 1, #self.data.choiceStyleTemplateList do
            if string.isnilorempty(self.data.choiceStyleTemplateList[i].name) == false then
                self.choiceStyleTemplatePath[self.data.choiceStyleTemplateList[i].id] = string.concat(ChoiceStyleTemplatePath, self.data.choiceStyleTemplateList[i].name)
            end
        end
    end
end

---根据conversationId获取Conversation
---@param conversationId int
---@return Conversation
function DialogueDatabase:GetConversation(conversationId)
    local conversations = self.data.conversations
    if conversations then
        for i = 1, #conversations do
            if conversations[i].id == conversationId then
                return conversations[i]
            end
        end
    end
    return nil
end

---根据Conversation的Description获取Conversation
---@param description string Conversation的描述字段
---@return Conversation
function DialogueDatabase:GetConversationByDescription(description)
    local conversations = self.data.conversations
    if conversations then
        for i = 1, #conversations do
            if conversations[i].description == description then
                return conversations[i]
            end
        end
    end
    return nil
end

---获取Conversation的起始DialogueEntry
---@param conversation Conversation
---@return DialogueEntry
function DialogueDatabase:GetFirstDialogueEntry(conversation)
    if conversation.firstDialogueEntryId ~= nil then
        return self:GetDialogueEntry(conversation.id, conversation.firstDialogueEntryId)
    else
        local dialogueEntries = conversation.dialogueEntries
        if dialogueEntries then
            for i = 1, #dialogueEntries do
                if dialogueEntries[i].title == 'START' then
                    return dialogueEntries[i]
                end
            end
        end
        return nil
    end
end

---根据ConversationId和DialogueEntryId获取DialogueEntry
---@param conversationId int
---@param dialogueEntryId int
---@return DialogueEntry
function DialogueDatabase:GetDialogueEntry(conversationId, dialogueEntryId)
    local uniqueID = self:GetUniqueID(conversationId, dialogueEntryId)
    return self:GetDialogueEntryByUniqueID(uniqueID)
end

---根据Conversation和DialogueEntryID获取DialogueEntry
---@param conversation Conversation
---@param dialogueEntryId int
---@return DialogueEntry
function DialogueDatabase:GetDialogueEntryInConversation(conversation, dialogueEntryId)
    return self:GetDialogueEntry(conversation.id, dialogueEntryId)
end

---根据Link获取DialogueEntry
---@param link Link
---@return DialogueEntry
function DialogueDatabase:GetDialogueEntryByLink(link)
    if link ~= nil then
        return self:GetDialogueEntry(link.destinationConversationID, link.destinationDialogueID)
    end
end

---根据节点uniqueId获取DialogueEntry
---@param uniqueId int
---@return DialogueEntry
function DialogueDatabase:GetDialogueEntryByUniqueID(uniqueId)
    if table.containskey(self.dialogueEntryDict, uniqueId) then
        return self.dialogueEntryDict[uniqueId]
    end
    return nil
end

---获取所有DialogueEntry
---@return DialogueEntry[]
function DialogueDatabase:GetAllDialogueEntry()
    return table.dictoarray(self.dialogueEntryDict)
end

---根据ConversationID和DialogueEntryID获取UniqueID
---@param conversationID int
---@param dialogueEntryID int
---@return int
function DialogueDatabase:GetUniqueID(conversationID, dialogueEntryID)
    return conversationID * 10000 + dialogueEntryID
end

---根据id获取TempObject
---@param id int
---@return TempObject
function DialogueDatabase:GetTempObject(id)
    if self.data.tempObjects then
        for i = 1, #self.data.tempObjects do
            if self.data.tempObjects[i].id == id then
                return self.data.tempObjects[i]
            end
        end
    end
    return nil
end

---根据actor和gameObjectID获取actor数据
---@param actor Actor
---@param gameObjectID int
---@return ActorData
function DialogueDatabase:GetActorData(actor, gameObjectID)
    if actor ~= nil then
        local actorGameObject = nil
        gameObjectID = tonumber(gameObjectID)
        if gameObjectID == nil or gameObjectID == 0 then
            actorGameObject = {}
            actorGameObject.actorType = actor.actorType
            actorGameObject.assetKey = actor.assetKey
            actorGameObject.clothList = actor.clothList
            actorGameObject.id = 0
        else
            if actor.alternateGameObjects then
                for i = 1, #actor.alternateGameObjects do
                    if actor.alternateGameObjects[i].id == gameObjectID then
                        actorGameObject = actor.alternateGameObjects[i]
                    end
                end
            end
        end
        return actorGameObject
    end

    return nil
end

---获取Actor预加载数量
---@return int
function DialogueDatabase:GetPreloadActorCount()
    local count = 0
    local actors = self.data.actors
    if actors then
        for i = 1, #actors do
            local actor = actors[i]
            local syncActor = self:GetActor(actor.syncActor)
            if not syncActor and (actor.dontInitOnStart == false) then
                if string.isnilorempty(actor.assetKey) == false then
                    count = count + 1
                end
                if actor.alternateGameObjects then
                    for j = 1, #actor.alternateGameObjects do
                        if string.isnilorempty(actor.alternateGameObjects[j].assetKey) == false
                                and actor.actorType == DialogueEnum.ActorType.ModelAsset then
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    return count
end

---获取TempObject预加载数量
---@return int
function DialogueDatabase:GetPreloadTempObjectCount()
    local count = 0
    local tempObjects = self.data.tempObjects
    if tempObjects then
        for i = 1, #tempObjects do
            if string.isnilorempty(tempObjects[i].resKey) == false
                    and not tempObjects[i].loadDirectly then
                count = count + 1
            end
        end
    end

    return count
end

---获取Actor的Key
---@param actor Actor
---@return string
function DialogueDatabase:GetActorUniqueKey(actor)
    local syncActor = nil
    if actor ~= nil then
        if actor.syncActor > 0 then
            syncActor = self:GetActor(actor.syncActor)
        end
        if syncActor == nil then
            syncActor = actor
        end

        local assetID = syncActor.assetID
        if assetID ~= 0 then
            return assetID
        elseif syncActor.description ~= nil then
            return syncActor.description
        else
            return string.concat("Actor", syncActor.id)
        end
    end

    return nil
end

---获取动态目标名字
---@param dynamicTarget DynamicTarget
---@return string
function DialogueDatabase:GetDynamicTargetName(dynamicTarget)
    local name = nil
    if dynamicTarget.targetType == DialogueEnum.DynamicTargetType.Actor then
        local actor = self:GetActor(dynamicTarget.id)
        name = actor ~= nil and self:GetActorUniqueKey(actor) or nil
    elseif dynamicTarget.targetType == DialogueEnum.DynamicTargetType.ActorTag then
        local actor = self:GetActorByTag(dynamicTarget.key)
        name = actor ~= nil and self:GetActorUniqueKey(actor) or nil
    elseif dynamicTarget.targetType == DialogueEnum.DynamicTargetType.TempObject then
        name = dynamicTarget.id
    end
    return name
end

---获取动态目标名字
---@param dynamicTarget DynamicTarget
---@return int
function DialogueDatabase:GetDynamicTargetAssetId(dynamicTarget)
    local assetId = 0
    if dynamicTarget.targetType == DialogueEnum.DynamicTargetType.Actor then
        local actor = self:GetActor(dynamicTarget.id)
        assetId = actor ~= nil and self:GetActorUniqueKey(actor) or 0
    elseif dynamicTarget.targetType == DialogueEnum.DynamicTargetType.ActorTag then
        local actor = self:GetActorByTag(dynamicTarget.key)
        assetId = actor ~= nil and self:GetActorUniqueKey(actor) or 0
    end
    return assetId
end

---获取行为配置
---@param actionCfg DialogueActionCfg
---@return DialogueActionCfg
function DialogueDatabase:GetAction(actionCfg)
    if actionCfg.type == DialogueEnum.DialogueActionType.Template then
        if actionCfg.templateSelection ~= nil then
            return LuaCfgMgr.Get(self.actionTemplatePath[actionCfg.templateSelection.templateId], actionCfg.templateSelection.subId)
        else
            return actionCfg
        end
    else
        return actionCfg
    end
end

---获取对话样式
---@param setting DialogueStyleSetting
---@return DialogueStyleSetting
function DialogueDatabase:GetDialogueStyleSetting(setting)
    if setting and setting.dialogueType == DialogueEnum.DialogueType.Template then
        return LuaCfgMgr.Get(self.dialogueStyleTemplatePath[setting.templateSelection.templateId], setting.templateSelection.subId)
    else
        return setting
    end
end

---获取选项样式
---@param setting ChoiceStyleSetting
---@return ChoiceStyleSetting
function DialogueDatabase:GetChoiceStyleSetting(setting)
    if setting.choiceStyle == DialogueEnum.ChoiceStyle.Template then
        return LuaCfgMgr.Get(self.choiceStyleTemplatePath[setting.templateSelection.templateId], setting.templateSelection.subId)
    else
        return setting
    end
end

---获取QTE样式
---@param setting QTEStyleSetting
---@return QTEStyleSetting
function DialogueDatabase:GetQTEStyleSetting(setting)
    return setting
    --没有模板功能了
    --[[    if setting and setting.qteStyle == DialogueEnum.QTEStyle.Template then
            return LuaCfgMgr.Get(self.qteStyleTemplatePath, setting.templateID)
        else
            return setting
        end]]
end

---根据id获取actor
---@param id int
---@return Actor
function DialogueDatabase:GetActor(id)
    if self.data.actors then
        for i = 1, #self.data.actors do
            if self.data.actors[i].id == id then
                return self.data.actors[i]
            end
        end
    end
    return nil
end

---根据tag获取actor
---@param tag string
---@return Actor
function DialogueDatabase:GetActorByTag(tag)
    if self.data.actors then
        for i = 1, #self.data.actors do
            if self.data.actors[i].assetTag == tag and self.data.actors[i].syncActor <= 0 then
                return self.data.actors[i]
            end
        end
    end
    return nil
end

---返回第一个Node
---@return NodeGraph
function DialogueDatabase:GetFirstNodeGraph()
    return self.data.nodeGraph and self.data.nodeGraph[1] or nil
end

---获取一个Node
---@param key string
---@return NodeGraph
function DialogueDatabase:GetNodeGraph(key)
    return self.nodeGraphList[key]
end

---根据NodeGraphKey获得链接的所有NodeGraph的SVC列表
---@param key string
---@return string[]
function DialogueDatabase:GetWarmupSVCList(key)
    if self.svcPreloadDict[key] == nil then
        local list = {}
        self.svcPreloadDict[key] = list
        local nodeGraph = self.nodeGraphList[key]
        if nodeGraph then
            if nodeGraph.nextNodes then
                for _, v in pairs(nodeGraph.nextNodes) do
                    local nextNode = self.nodeGraphList[v]
                    if nextNode.sequenceNodeList then
                        for _, uniqueId in pairs(nextNode.sequenceNodeList) do
                            local dialogueEntry = self:GetDialogueEntryByUniqueID(uniqueId)
                            self:InsertDialogueEntryToSVCList(list, dialogueEntry)
                        end
                    end
                end
            end
        end
    end
    return self.svcPreloadDict[key]
end

---单个节点找SVC列表
---@param list string[]
---@param dialogueEntry DialogueEntry
function DialogueDatabase:InsertDialogueEntryToSVCList(list, dialogueEntry)
    if dialogueEntry.actions then
        for _, action in pairs(dialogueEntry.actions) do
            local realAction = self:GetAction(action)
            if realAction then
                if realAction.type == DialogueEnum.DialogueActionType.ActionGroup then
                    local subAction = realAction
                    for i = 1, #realAction.dialogueActions do
                        subAction = realAction.dialogueActions[i]
                        if subAction.overrideActions and subAction.overrideActions[realAction.dialogueActions[i].id] then
                            subAction = subAction.overrideActions[realAction.dialogueActions[i].id]
                            if subAction.type == DialogueEnum.DialogueActionType.CTSPlay then
                                self:InsertToSVCList(list, subAction.assetName)
                            end
                            if subAction.type == DialogueEnum.DialogueActionType.Anim then
                                if subAction.stateType == DialogueEnum.AnimStateType.CutScene then
                                    self:InsertToSVCList(list, subAction.stateName)
                                end
                            end
                        end
                    end
                else
                    if realAction.type == DialogueEnum.DialogueActionType.CTSPlay then
                        self:InsertToSVCList(list, realAction.assetName)
                    end
                    if realAction.type == DialogueEnum.DialogueActionType.Anim then
                        if realAction.stateType == DialogueEnum.AnimStateType.CutScene then
                            self:InsertToSVCList(list, realAction.stateName)
                        end
                    end
                end
            end
        end
    end
end

---
---@param list string[]
---@param stateName string
function DialogueDatabase:InsertToSVCList(list, stateName)
    local ctsPath = CutSceneCollector.GetPath(stateName)
    if string.isnilorempty(ctsPath) == false then
        local svcPath = SVCHelper.GetCtsSVCPath(ctsPath)
        table.insert(list, svcPath)
    end
end

---剧情时间预测，分支已经在线下做了拆分，这里顺序累加即可
---@param nodeGraph NodeGraph
---@param playedSequenceNode int[]
---@param endID int
---@return float
function DialogueDatabase:EstimateRemainingTime(nodeGraph, playedSequenceNode)
    local remainingTime = CutSceneMgr.GetCurCutSceneLeftTime()
    if nodeGraph.sequenceNodeList then
        for _, v in pairs(nodeGraph.sequenceNodeList) do
            if table.indexof(playedSequenceNode, v) == false then
                local nextEntry = self:GetDialogueEntryByUniqueID(v)
                if nextEntry then
                    remainingTime = remainingTime + nextEntry.sequenceTime
                end
            end
        end
    end
    return remainingTime
end

---根据NodeGraphKey预测剩余时间
---@param playedSequenceNode int[]
---@param nodeGraphKey string
---@return float
function DialogueDatabase:EstimateRemainingTimeByNodeGraph(playedSequenceNode, nodeGraphKey)
    local nodeGraph = self.nodeGraphList[nodeGraphKey]
    --当前节点块的剩余时间
    local remainingTime = self:EstimateRemainingTime(nodeGraph, playedSequenceNode)
    if nodeGraph.nextNodes ~= nil then
        nodeGraph = self.nodeGraphList[nodeGraph.nextNodes[1]]
    else
        nodeGraph = nil
    end
    --累加剩余的节点块时间
    while nodeGraph do
        remainingTime = remainingTime + nodeGraph.sequenceTime
        if nodeGraph.nextNodes ~= nil then
            --预测第一个分支的时间
            nodeGraph = self.nodeGraphList[nodeGraph.nextNodes[1]]
        else
            nodeGraph = nil
        end
    end
    return remainingTime
end

---判断是否是Node的起始节点
---@param nodeGraphKey string
---@return boolean
function DialogueDatabase:IsNodeGraphStart(nodeGraphKey)
    return self.nodeGraphList[nodeGraphKey] ~= nil
end

---查询节点ID对应的NodeGraphKey
---@param entryId int
function DialogueDatabase:GetNodeGraphKey(entryId)
    return self.nodeGraphKeyDict[entryId]
end

---把NodeGraph添加到节点树中去
function DialogueDatabase:AppendBatchLink()
    for _, v in pairs(self.nodeGraphList) do
        if v.nextNodes then
            for i = 1, #v.nextNodes do
                local nextNode = self.nodeGraphList[v.nextNodes[i]]
                local params = string.split(v.uniqueID, "-")
                PreloadBatchMgr.AppendBatchLink(v.type, v.uniqueID, nextNode.type, nextNode.uniqueID, params)
            end
        end
    end
end

---重新加载
function DialogueDatabase:Reload()
    if self.data then
        LuaCfgMgr.UnLoad(string.concat("DialogueCfg.", self.name))
        self.data = nil
    end
    table.clear(self.nodeGraphList)
    table.clear(self.dialogueEntryDict)
    self:Init(self.name)
end

---销毁逻辑
function DialogueDatabase:Dispose()
    if self.data then
        LuaCfgMgr.UnLoad(string.concat("DialogueCfg.", self.name))
        self.data = nil
    end
    self.nodeGraphList = nil
    self.dialogueEntryDict = nil
end

return DialogueDatabase