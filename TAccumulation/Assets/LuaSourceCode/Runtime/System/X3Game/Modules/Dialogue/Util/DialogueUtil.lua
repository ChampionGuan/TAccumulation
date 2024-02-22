---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-02-25 11:47:31
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class DialogueUtil
local DialogueUtil = class("DialogueUtil")

local CameraUtility = CS.X3Game.CameraUtility
local DialogueTextUtil = require("Runtime.System.X3Game.Modules.Dialogue.Util.DialogueTextUtil")
local CutSceneCollector = CS.PapeGames.CutScene.CutSceneCollector

---获取字符串的长度（任何单个字符长度都为1）
---@param inputStr string
---@return int
function DialogueUtil.GetStrLength(inputStr)
    if type(inputStr) ~= "string" or string.isnilorempty(inputStr) then
        return 0
    end
    local length = 0 -- 字符的个数
    local i = 1
    local byteCount = 1
    local lenInByte = string.len(inputStr)
    while i <= lenInByte do
        byteCount = DialogueUtil.GetByteCount(inputStr, i)
        i = i + byteCount
        length = length + 1
    end
    byteCount = DialogueUtil.GetByteCount(inputStr, lenInByte)
    return length
end

---获取字符占用字节数
---@param str string
---@param index int
---@return int
function DialogueUtil.GetByteCount(str, index)
    local byteValue = string.byte(str, index)
    local byteCount = 0
    if byteValue == nil then
        byteCount = 0
    elseif byteValue > 239 then
        byteCount = 4-- 4字节字符
    elseif byteValue > 223 then
        byteCount = 3-- 汉字
    elseif byteValue > 128 then
        byteCount = 2-- 双字节字符
    else
        byteCount = 1-- 单字节字符
    end
    return byteCount
end

---获取剧情资源的Key
---@param assetId int
---@param resKey string
---@return string
function DialogueUtil.GetResKey(assetId, resKey)
    if string.isnilorempty(assetId) == false and assetId > 0 then
        return string.concat(assetId, "_", resKey)
    else
        return resKey
    end
end

---获得最后一个场景
---@param dialogueName string
---@param dialogueRecordList pbcmessage.DialogueRecord[]
---@return string
function DialogueUtil.CheckFinalScene(dialogueName, dialogueRecordList)
    local finalSceneName = nil
    local waitNodeQueue = {}
    local curDialogueEntry = nil
    local cloneDialogueRecordList = table.clone(dialogueRecordList)
    local database = DialogueManager.LoadDatabase(dialogueName)
    local checkedCnt = 0
    if cloneDialogueRecordList and #cloneDialogueRecordList > 0 then
        while #cloneDialogueRecordList > 0 do
            checkedCnt = checkedCnt + 1
            if checkedCnt >= 10000 then
                Debug.LogError("[DialogueSystem]出现死循环，请检查")
                return finalSceneName
            end
            if #waitNodeQueue > 0 then
                curDialogueEntry = waitNodeQueue[#waitNodeQueue]
                if curDialogueEntry.actions then
                    for _, action in pairs(curDialogueEntry.actions) do
                        local realAction = database:GetAction(action)
                        if realAction then
                            if realAction.type == DialogueEnum.DialogueActionType.ActionGroup then
                                local subAction = nil
                                for i = 1, #realAction.dialogueActions do
                                    subAction = realAction.dialogueActions[i]
                                    if action.overrideActions and action.overrideActions[realAction.dialogueActions[i].id] then
                                        subAction = action.overrideActions[realAction.dialogueActions[i].id]
                                        if subAction.type == DialogueEnum.DialogueActionType.ChangeScene then
                                            finalSceneName = subAction.sceneName
                                        elseif subAction.type == DialogueEnum.DialogueActionType.Transition3D then
                                            if subAction.changeSceneType == DialogueEnum.ChangeSceneType.Scene3D then
                                                finalSceneName = subAction.sceneName
                                            end
                                        end
                                    end
                                end
                            else
                                if realAction.type == DialogueEnum.DialogueActionType.ChangeScene then
                                    finalSceneName = realAction.sceneName
                                elseif realAction.type == DialogueEnum.DialogueActionType.Transition3D then
                                    if realAction.changeSceneType == DialogueEnum.ChangeSceneType.Scene3D then
                                        finalSceneName = realAction.sceneName
                                    end
                                end
                            end
                        end
                    end
                end
                table.remove(waitNodeQueue, #waitNodeQueue)

                local settedNextLink = nil
                local dialogueRecord = cloneDialogueRecordList[1]
                local nextDialogueEntry = nil
                if curDialogueEntry.uniqueID == dialogueRecord.Id then
                    table.remove(cloneDialogueRecordList, 1)
                    if curDialogueEntry.outgoingLinks ~= nil then
                        for i = 1, #curDialogueEntry.outgoingLinks do
                            if database:GetDialogueEntryByLink(curDialogueEntry.outgoingLinks[i]).uniqueID == dialogueRecord.NextID then
                                settedNextLink = curDialogueEntry.outgoingLinks[i]
                            end
                        end
                    end
                end
                if settedNextLink then
                    nextDialogueEntry = database:GetDialogueEntryByLink(settedNextLink)
                    table.insert(waitNodeQueue, #waitNodeQueue + 1, nextDialogueEntry)
                else
                    if curDialogueEntry.outgoingLinks ~= nil then
                        for i, link in pairs(curDialogueEntry.outgoingLinks) do
                            nextDialogueEntry = database:GetDialogueEntryByLink(curDialogueEntry.outgoingLinks[i])
                            table.insert(waitNodeQueue, #waitNodeQueue + 1, nextDialogueEntry)
                        end
                    end
                end
            else
                local dialogueRecord = cloneDialogueRecordList[1]
                table.insert(waitNodeQueue, #waitNodeQueue + 1, database:GetDialogueEntryByUniqueID(dialogueRecord.Id))
            end
        end
    end
    return finalSceneName
end

---是否有CTS
---@param database DialogueDatabase
---@param dialogueEntry DialogueEntry
---@return boolean
function DialogueUtil.HasCutScene(database, dialogueEntry)
    local hasCutScene = false
    if dialogueEntry.actions then
        for _, action in pairs(dialogueEntry.actions) do
            local realAction = database:GetAction(action)
            if realAction then
                if realAction.type == DialogueEnum.DialogueActionType.ActionGroup then
                    local subAction = realAction
                    for i = 1, #realAction.dialogueActions do
                        subAction = realAction.dialogueActions[i]
                        if action.overrideActions and action.overrideActions[realAction.dialogueActions[i].id] then
                            subAction = action.overrideActions[realAction.dialogueActions[i].id]
                            if subAction.type == DialogueEnum.DialogueActionType.CTSPlay then
                                hasCutScene = true
                            end
                        end
                    end
                else
                    if realAction.type == DialogueEnum.DialogueActionType.CTSPlay then
                        hasCutScene = true
                    end
                end
            end
        end
    end
    return hasCutScene
end

---获取某一段剧情的回顾信息（同剧情回顾功能）
---@param dialogueId int 剧情Id
---@param startNodeId int 剧情开始Id
---@param endNodeId int 剧情结束Id
---@param branchSelectedList int[] 选项信息，遍历时不判断条件，根据传入的选项决定分支走向
---@return DialogueReviewData[]
function DialogueUtil.GetDialogueReviewList(dialogueId, startNodeId, endNodeId, branchSelectedList)
    local reviewList = {}
    local checkedNodeList = {}
    local waitForCheckList = { startNodeId }
    local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", dialogueId)
    if dialogueId == 0 then
        return reviewList
    end
    local database = DialogueManager.LoadDatabase(dialogueInfo.Name)
    if database then
        while #waitForCheckList > 0 do
            local curId = table.remove(waitForCheckList, #waitForCheckList)
            if table.indexof(checkedNodeList, curId) == false then
                local curEntry = database:GetDialogueEntryByUniqueID(curId)
                if curEntry then
                    table.insert(checkedNodeList, #checkedNodeList + 1, curEntry.uniqueID)
                    local actor = database:GetActor(curEntry.actorID)
                    local mainDialogue = DialogueTextUtil.GetDialogueText(nil, dialogueId, curEntry)
                    if string.isnilorempty(mainDialogue) == false then
                        ---@type DialogueReviewData
                        local reviewData = {}
                        reviewData.actorName = DialogueTextUtil.GetActorName(dialogueId, curEntry)
                        reviewData.text = mainDialogue
                        reviewData.canFavorite = true
                        reviewData.roleId = actor ~= nil and actor.manType or 0
                        reviewData.dialogueId = dialogueId
                        reviewData.nodeId = curEntry.uniqueID
                        reviewData.isPlayer = actor ~= nil and actor.isPlayer or false
                        if string.isnilorempty(curEntry.voiceName) == false then
                            reviewData.voiceName = curEntry.voiceName
                        else
                            if curEntry.wwiseDatas then
                                for _, wwiseData in pairs(curEntry.wwiseDatas) do
                                    if wwiseData.voiceType == DialogueEnum.WwiseVoiceType.Voice then
                                        reviewData.voiceName = wwiseData.eventName
                                    end
                                end
                            end
                        end
                        table.insert(reviewList, #reviewList + 1, reviewData)
                    end
                    if curEntry.uniqueID ~= endNodeId then
                        if curEntry.conditionType == DialogueEnum.DialogueConditionType.Dialogue then
                            for _, link in pairs(curEntry.outgoingLinks) do
                                local nextEntry = database:GetDialogueEntryByLink(link)
                                if nextEntry then
                                    table.insert(waitForCheckList, #waitForCheckList + 1, nextEntry.uniqueID)
                                end
                            end
                        else
                            for _, link in pairs(curEntry.outgoingLinks) do
                                local nextEntry = database:GetDialogueEntryByLink(link)
                                local nextSelectedId = (branchSelectedList and #branchSelectedList > 0) and branchSelectedList[1] or 0
                                if nextEntry and nextSelectedId == nextEntry.uniqueID then
                                    table.remove(branchSelectedList, 1)
                                    table.insert(waitForCheckList, #waitForCheckList + 1, nextEntry.uniqueID)
                                end
                            end
                        end
                    end
                else
                    Debug.LogErrorFormat("未找到剧情Id:%s", curId)
                end
            end
        end
    else
        Debug.LogErrorFormat("未找到剧情数据:%s", dialogueId)
    end
    return reviewList
end

---检查Record是否合法，可以正常继续播放，不能就直接结算
---@param dialogueName string
---@param dialogueRecordList pbcmessage.DialogueRecord[]
---@return boolean
function DialogueUtil.CheckRecordLegal(dialogueName, dialogueRecordList)
    local waitNodeQueue = {}
    local curDialogueEntry = nil
    local cloneDialogueRecordList = table.clone(dialogueRecordList)
    local database = DialogueManager.LoadDatabase(dialogueName)
    local checkedCnt = 0
    if cloneDialogueRecordList and #cloneDialogueRecordList > 0 then
        local dialogueRecord = cloneDialogueRecordList[1]
        table.insert(waitNodeQueue, #waitNodeQueue + 1, database:GetDialogueEntryByUniqueID(dialogueRecord.Id))
        while #waitNodeQueue > 0 and #cloneDialogueRecordList > 0 do
            checkedCnt = checkedCnt + 1
            if checkedCnt >= 10000 then
                Debug.LogError("[DialogueSystem]出现死循环，请检查")
                return false
            end

            curDialogueEntry = waitNodeQueue[#waitNodeQueue]
            table.remove(waitNodeQueue, #waitNodeQueue)

            local settedNextLink = nil
            local dialogueRecord = cloneDialogueRecordList[1]
            local nextDialogueEntry = nil
            if curDialogueEntry.uniqueID == dialogueRecord.Id then
                table.remove(cloneDialogueRecordList, 1)
                if curDialogueEntry.outgoingLinks ~= nil then
                    for i = 1, #curDialogueEntry.outgoingLinks do
                        if database:GetDialogueEntryByLink(curDialogueEntry.outgoingLinks[i]).uniqueID == dialogueRecord.NextID then
                            settedNextLink = curDialogueEntry.outgoingLinks[i]
                        end
                    end
                end
            end
            if settedNextLink and DialogueUtil.IsBranchNode(curDialogueEntry.conditionType) then
                nextDialogueEntry = database:GetDialogueEntryByLink(settedNextLink)
                table.insert(waitNodeQueue, #waitNodeQueue + 1, nextDialogueEntry)
            else
                if curDialogueEntry.outgoingLinks ~= nil then
                    for i, _ in pairs(curDialogueEntry.outgoingLinks) do
                        nextDialogueEntry = database:GetDialogueEntryByLink(curDialogueEntry.outgoingLinks[i])
                        table.insert(waitNodeQueue, #waitNodeQueue + 1, nextDialogueEntry)
                    end
                end
            end
        end
    else
        return true
    end
    return #cloneDialogueRecordList == 0
end

---是否是分支节点
---@param conditionType int
---@return boolean
function DialogueUtil.IsBranchNode(conditionType)
    if conditionType == DialogueEnum.DialogueConditionType.Choice or
            conditionType == DialogueEnum.DialogueConditionType.ConditionBranch or
            conditionType == DialogueEnum.DialogueConditionType.Random or
            conditionType == DialogueEnum.DialogueConditionType.QTE then
        return true
    end

    return false
end

---@param worldPos Vector3 世界坐标
---@param screenPosOffset Vector2
---@param rootRectTransform RectTransform
function DialogueUtil.WorldPointToRectPosition(worldPos, screenPosOffset, rootRectTransform)
    local retPos = Vector2.Temp(0, 0)
    local screenPosition = RectTransformUtil.WorldToScreenPoint(worldPos, GlobalCameraMgr.GetUnityMainCamera())
    screenPosition = screenPosition + Vector3.Temp(screenPosOffset.x, screenPosOffset.y, 0)
    local size = rootRectTransform.sizeDelta
    local screenSize = CameraUtility.GetScreenSize()
    local cameraWidth = screenSize.x
    local cameraHeight = screenSize.y
    screenPosition.x = math.min(cameraWidth - size.x / 2, math.max(0 + size.x / 2, screenPosition.x))
    screenPosition.y = math.min(cameraHeight - size.y / 2, math.max(0 + size.y / 2, screenPosition.y))
    local is_ok = false
    local parent = rootRectTransform.parent and rootRectTransform.parent:GetComponent("RectTransform") or nil
    if parent then
        is_ok, retPos = RectTransformUtil.GetLocalPosFromScreenPos(parent,
                Vector2.Temp(screenPosition.x, screenPosition.y))
    end

    return retPos
end

---提供一个根据剧情id和Conversationid返回Conversation名字的接口
---@param dialogueId int
---@param conversationId int
function DialogueUtil.GetConversationName(dialogueId, conversationId)
    local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", dialogueId)
    if dialogueInfo then
        local database = DialogueManager.LoadDatabase(dialogueInfo.Name)
        if database then
            local conversation = database:GetConversation(conversationId)
            return conversation and conversation.description or nil
        end
    end
    return nil
end

---获取Wwise音频长度
---@param wwiseData DialogueWwiseData 音频数据
---@param needExtraWwiseTime boolean 是否需要留白时长
---@param extraTime float 留白时长
---@return float
function DialogueUtil.GetWwiseDuration(wwiseData, needExtraWwiseTime, extraTime)
    local wwiseDuration = 0
    if wwiseData.duration == nil or wwiseData.duration == -1 then
        local wwiseLength = WwiseMgr.GetMaxLength(wwiseData.eventName)
        if needExtraWwiseTime then
            wwiseLength = wwiseLength + extraTime
        end
        wwiseDuration = math.max(wwiseDuration, wwiseLength)
        if string.isnilorempty(wwiseData.lipSyncAsset) == false then
            local lipSyncAsset = Res.LoadWithAssetPath(wwiseData.lipSyncAsset, AutoReleaseMode.EndOfFrame)
            if lipSyncAsset ~= nil then
                wwiseDuration = math.max(wwiseDuration, lipSyncAsset.length)
            end
        end
    else
        wwiseDuration = wwiseData.duration
    end
    return wwiseDuration
end

--region 剧情资源预加载
---预加载资产搜集
---@param database DialogueDatabase
---@param collector CS.X3Game.PreloadTaskCollector
function DialogueUtil.RequestBatch(database, collector)
    --添加Actor资源
    local actors = database.data.actors
    if actors ~= nil then
        for i = 1, #actors do
            local syncActor = database:GetActor(actors[i].syncActor)
            if not syncActor and (actors[i].dontInitOnStart == false) then
                if string.isnilorempty(actors[i].assetKey) == false then
                    if actors[i].actorType == DialogueEnum.ActorType.RoleClothSuit then
                        collector:AddAssetTaskArray(CharacterMgr.GetAssetListWithSuitKey(actors[i].assetKey))
                    elseif actors[i].actorType == DialogueEnum.ActorType.RoleBaseModel then
                        collector:AddAssetTaskArray(CharacterMgr.GetInsAssetList(actors[i].assetKey, actors[i].clothList))
                    else
                        local modelAssetPath = CharacterUtil.GetAssetPathWithModelKey(actors[i].assetKey)
                        if modelAssetPath ~= nil then
                            collector:AddGameObjectTask(modelAssetPath)
                        end
                    end
                end
                if actors[i].alternateGameObjects ~= nil then
                    for j = 1, #actors[i].alternateGameObjects do
                        if string.isnilorempty(actors[i].alternateGameObjects[j].assetKey) == false then
                            if actors[i].actorType == DialogueEnum.ActorType.RoleClothSuit then
                                collector:AddAssetTaskArray(CharacterMgr.GetAssetListWithSuitKey(actors[i].alternateGameObjects[j].assetKey))
                            elseif actors[i].actorType == DialogueEnum.ActorType.RoleBaseModel then
                                collector:AddAssetTaskArray(CharacterMgr.GetInsAssetList(actors[i].alternateGameObjects[j].assetKey, actors[i].alternateGameObjects[j].clothList))
                            else
                                local modelAssetPath = CharacterUtil.GetAssetPathWithModelKey(actors[i].alternateGameObjects[j].assetKey)
                                if modelAssetPath ~= nil then
                                    collector:AddGameObjectTask(modelAssetPath)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    --添加TempObject资源
    local tempObject = database.data.tempObjects
    if tempObject ~= nil then
        for i = 1, #tempObject do
            if string.isnilorempty(tempObject[i].resKey) == false then
                if not tempObject[i].loadDirectly then
                    local cfg = LuaCfgMgr.Get("ModelAsset", tempObject[i].resKey)
                    if cfg then
                        collector:AddGameObjectTask(cfg.PrefabPath)
                    end
                end
            end
        end
    end

    collector:AddAssetTask(UIMgr.GetUIPrefabAssetPath(UIConf.Dialog))
    --只预加载第一个节点的资源
    local firstNodeGraph = database:GetFirstNodeGraph()
    if firstNodeGraph then
        DialogueUtil.RequestNodeBatch(database, firstNodeGraph, collector, false)
    end
end

---剧情子节点资源预加载
---@param database DialogueDatabase
---@param nodeGraph table
---@param collector CS.X3Game.PreloadTaskCollector
---@param needScene boolean
function DialogueUtil.RequestNodeBatch(database, nodeGraph, collector, needScene)
    needScene = needScene ~= nil and needScene or false
    if nodeGraph.sequenceNodeList then
        for _, v in pairs(nodeGraph.sequenceNodeList) do
            local exportEntry = database:GetDialogueEntryByUniqueID(v)
            DialogueUtil.AnalyzeAsset(database, exportEntry, collector, needScene)
        end
    end
end

---节点资产分析
---@param database DialogueDatabase
---@param dialogueEntry DialogueEntry
---@param collector CS.X3Game.PreloadTaskCollector
---@param needScene boolean
function DialogueUtil.AnalyzeAsset(database, dialogueEntry, collector, needScene)
    if dialogueEntry.actions then
        for _, action in pairs(dialogueEntry.actions) do
            local realAction = database:GetAction(action)
            if realAction then
                if realAction.type == DialogueEnum.DialogueActionType.ActionGroup then
                    local subAction = realAction
                    for i = 1, #realAction.dialogueActions do
                        subAction = realAction.dialogueActions[i]
                        if action.overrideActions and action.overrideActions[realAction.dialogueActions[i].id] then
                            subAction = action.overrideActions[realAction.dialogueActions[i].id]
                            DialogueUtil.AnalyzeActionAsset(subAction, collector, needScene)
                        end
                    end
                else
                    DialogueUtil.AnalyzeActionAsset(realAction, collector, needScene)
                end
            end
        end
    end
end

---行为资产分析
---@param database DialogueDatabase
---@param dialogueEntry DialogueEntry
---@param action DialogueBaseAction
---@param collector CS.X3Game.PreloadTaskCollector
---@param needScene
function DialogueUtil.AnalyzeActionAsset(action, collector, needScene)
    if action.type == DialogueEnum.DialogueActionType.CTSPlay then
        DialogueUtil.AnalyzeCTSAsset(action.assetName, collector)
    end
    if action.type == DialogueEnum.DialogueActionType.Anim then
        if action.stateType == DialogueEnum.AnimStateType.CutScene then
            DialogueUtil.AnalyzeCTSAsset(action.stateName, collector)
        end
    end
    if action.type == DialogueEnum.DialogueActionType.ChangeScene and needScene then
        collector:AddSceneTask(action.sceneName)
    end
end

---CTS资产分析
---@param name string
---@param collector CS.X3Game.PreloadTaskCollector
function DialogueUtil.AnalyzeCTSAsset(name, collector)
    collector:AddAssetTask(CutSceneCollector.GetPath(name))
    --分析CTS间接依赖资源
    local assetInfo = CutSceneCollector.GetAssetInfo(name)
    if assetInfo then
        local partConfigKeyList = {}
        local modelAssetKeyList = {}
        for _, assetID in pairs(assetInfo.assetIDs) do
            local cutSceneAssetCfg = LuaCfgMgr.Get("CutSceneAsset", assetID)
            if cutSceneAssetCfg then
                if cutSceneAssetCfg.PartKey then
                    for _, partKey in pairs(cutSceneAssetCfg.PartKey) do
                        table.insert(partConfigKeyList, #partConfigKeyList + 1, partKey)
                    end
                end
                if cutSceneAssetCfg.Type == "MainActor" then
                    local roleBaseModelCfg = LuaCfgMgr.Get("RoleBaseModelAsset", cutSceneAssetCfg.ModelKey)
                    if roleBaseModelCfg then
                        table.insert(modelAssetKeyList, #modelAssetKeyList + 1, roleBaseModelCfg.ModelAsset)
                    end
                else
                    table.insert(modelAssetKeyList, #modelAssetKeyList + 1, cutSceneAssetCfg.ModelKey)
                end
            end
        end
        for _, partKey in pairs(assetInfo.partKeys) do
            table.insert(partConfigKeyList, #partConfigKeyList + 1, partKey)
        end
        for _, partKey in pairs(partConfigKeyList) do
            local partCfg = LuaCfgMgr.Get("PartConfig", partKey)
            if partCfg and partCfg.Sources then
                for _, modelAssetKey in pairs(partCfg.Sources) do
                    table.insert(modelAssetKeyList, #modelAssetKeyList + 1, modelAssetKey)
                end
            end
        end
        --添加预加载资源
        for _, modelAssetKey in pairs(modelAssetKeyList) do
            local modelAsset = LuaCfgMgr.Get("ModelAsset", modelAssetKey)
            if modelAsset then
                collector:AddAssetTask(modelAsset.PrefabPath)
            end
        end
        for _, eventName in pairs(assetInfo.eventNames) do
            collector:AddWwiseEventTask(eventName, true)
        end
        if assetInfo.fullPaths then
            for _, fullPath in pairs(assetInfo.fullPaths) do
                collector:AddAssetTask(fullPath)
            end
        end
    end
end
--endregion

return DialogueUtil