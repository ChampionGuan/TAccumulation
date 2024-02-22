﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2022/12/5 20:16
---@class PhoneMsgHelper
local PhoneMsgHelper = {}
local PhoneMsgConst = require("Runtime.System.X3Game.Modules.PhoneMessage.PhoneMsgConst")

function PhoneMsgHelper.SaveProgress(contactId, msgId, convId, lastReadId)
    local uid = PhoneMsgHelper.GetProgressUid(contactId)
    ---@type X3Data.PhoneMsgProgressData
    local progressInfo = X3DataMgr.Get(X3DataConst.X3Data.PhoneMsgProgressData, uid)
    if progressInfo == nil then
        progressInfo = X3DataMgr.Add(X3DataConst.X3Data.PhoneMsgProgressData)
        progressInfo:SetPrimaryValue(uid)
    end
    progressInfo:SetGUID(msgId)
    if convId then
        progressInfo:SetLastConvId(convId)
    end
    if lastReadId and lastReadId ~= 0 then
        progressInfo:SetLastReadId(lastReadId)
    end
end

function PhoneMsgHelper.ClearProgress(contactId)
    local uid = PhoneMsgHelper.GetProgressUid(contactId)
    local progressInfo = X3DataMgr.Get(X3DataConst.X3Data.PhoneMsgProgressData, uid)
    if progressInfo == nil then
        progressInfo:Clear()
    end
end

function PhoneMsgHelper.GetProgress(contactId)
    return X3DataMgr.Get(X3DataConst.X3Data.PhoneMsgProgressData, PhoneMsgHelper.GetProgressUid(contactId))
end

function PhoneMsgHelper.GetProgressUid(contactId)
    return PlayerUtil.GetUid() * PhoneMsgConst.ProgressUidOffset + contactId
end

---获取当前联系人话题的ServerID
---@param contactID int 联系人ID
---@return int ServerID
function PhoneMsgHelper.GetCurrentMsgGUID(contactID)
    local contactData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contactID)
    return contactData and contactData:GetCurMsgID() or 0
end

function PhoneMsgHelper.GetLastFinishMsg(contactID)
    local contactData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contactID)
    return contactData and contactData:GetLastMsgID() or 0
end

function PhoneMsgHelper.GetShowMsg(contactID)
    local result = {}
    local contactData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contactID)
    if contactData ~= nil then
        local lastGuid = contactData:GetLastMsgID() or 0
        local lastMsg = SelfProxyFactory.GetPhoneMsgProxy():GetMessageData(lastGuid or 0)
        ---@type cfg.PhoneMsg
        local lastCfg
        if lastMsg then
            lastCfg = LuaCfgMgr.Get("PhoneMsg", lastMsg:GetID())
            table.insert(result, lastGuid)
        end

        if lastCfg == nil or lastCfg.IsReaded ~= 0 then
            local history = contactData:GetHistory()
            if history then
                for i = #history, 1, -1 do
                    local message = SelfProxyFactory.GetPhoneMsgProxy():GetMessageData(history[i])
                    if message and message:GetPrimaryValue() ~= lastGuid then
                        local cfg = LuaCfgMgr.Get("PhoneMsg", message:GetID())
                        if cfg.IsReaded == 0 then
                            break
                        end
                        table.insert(result, 1, history[i])
                    end
                end
            end
        end
    end

    return result
end

function PhoneMsgHelper.GetLastShowMsg(contactID)
    local contactData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contactID)
    if contactData and contactData:GetCurMsgID() ~= 0 then
        return contactData:GetCurMsgID()
    else
        return contactData and contactData:GetLastMsgID()
    end
end

function PhoneMsgHelper.MsgIsFinish(msgGUID)
    local msg = SelfProxyFactory.GetPhoneMsgProxy():GetMessageData(msgGUID)
    return msg and msg:GetIsFinished()
end

---通过联系人ID获取最后一个对话内容
---@param contactId int 联系人ID
---@return int,int 对话显示ID,最后一个对话ID
function PhoneMsgHelper.GetLastShowConverID(contactId)
    local msgGUID = PhoneMsgHelper.GetLastShowMsg(contactId)
    local convList = PhoneMsgHelper.GetConversation(msgGUID)
    local lastShowID = nil

    for i = #convList, 1, -1 do
        ---@type cfg.PhoneMsgConversation
        local cfg = LuaCfgMgr.Get("PhoneMsgConversation", convList[i])
        if cfg and not PhoneMsgConst.HideType[cfg.Type] then
            lastShowID = cfg.ID
            break
        end
    end

    return lastShowID, convList[#convList], msgGUID
end

function PhoneMsgHelper.GetFirstConversationId(cfgId, contactId, cfgName)
    ---@type cfg.PhoneMsg
    local cfg = LuaCfgMgr.Get(cfgName or "PhoneMsg", cfgId)
    if not cfg then
        return nil
    end
    if cfg.Type == 5 then
        ---@type cfg.PhoneMsgChat
        local chatData = LuaCfgMgr.Get("PhoneMsgChat", cfgId, contactId)
        if chatData then
            return chatData.Conversation
        end
    else
        return cfg.Conversation
    end
end

---@return cfg.PhoneMsgConversation[],int 列表，最后阅读
function PhoneMsgHelper._GetConversationIds(msgGuid)
    local result = {}
    local severData = SelfProxyFactory.GetPhoneMsgProxy():GetMessageData(msgGuid)

    if severData == nil then
        return result, 0
    end

    local lastConvId = -1
    local lastReadId = -1
    if severData:GetIsFinished() == false then
        ---@type X3Data.PhoneMsgProgressData
        local contactProgress = PhoneMsgHelper.GetProgress(severData:GetContactID())
        if contactProgress and contactProgress:GetGUID() == msgGuid then
            lastConvId = contactProgress:GetLastConvId()
            lastReadId = contactProgress:GetLastReadId()
        end
    end

    ---@type int[]
    local rawList = PoolUtil.GetTable()
    local lastSeverIdx = 0
    local lastClientId = 0
    local lastReadIdx = 0
    local nextID = nil
    local preNext = nil
    local isSeverRecordType = false
    local isSeverRecordResult = false
    local isPass = false
    local curId = PhoneMsgHelper.GetFirstConversationId(severData:GetID(), severData:GetContactID())

    while curId do
        ---@type cfg.PhoneMsgConversation
        local cfg = LuaCfgMgr.Get("PhoneMsgConversation", curId)
        if not cfg then
            Debug.LogErrorFormatWithTag(GameConst.LogTag.PhoneMsg, "PhoneMsgHelper.GetHistory converID = %d is Invalid", curId)
            break
        end

        nextID, isSeverRecordType, isPass = PhoneMsgHelper._GetNextId(cfg, severData)
        if isSeverRecordType and not isPass then
            break
        end

        table.insert(rawList, cfg)
        local length = #rawList
        lastReadIdx = curId == lastReadId and length or lastReadIdx
        lastClientId = curId == lastConvId and length or lastClientId
        lastSeverIdx = isSeverRecordResult and length or lastSeverIdx
        isSeverRecordResult = isSeverRecordType

        if nextID == -1 then
            if preNext == curId then
                curId = nil
            else
                curId = preNext
            end
        else
            if curId == nextID then
                curId = nil
            else
                curId = nextID
            end
        end

        if PhoneMsgConst.ChoiceType[cfg.Type] then
            preNext = cfg.NextID and cfg.NextID[1] or nil
        end
    end

    local length = severData:GetIsFinished() and #rawList or math.max(lastSeverIdx, lastClientId)
    lastReadIdx = severData:GetIsFinished() and length or lastReadIdx

    for i = 1, length do
        table.insert(result, rawList[i].ID)
    end

    PoolUtil.ReleaseTable(rawList)
    return result, lastReadIdx
end

---@return X3Data.PhoneMsgConversationData[]
function PhoneMsgHelper.GetHistory(msgGuid)
    local result = {}
    local converIds, lastReadIdx = PhoneMsgHelper._GetConversationIds(msgGuid)

    local curTime = TimerMgr.RealtimeSinceStartup()

    for i = 1, #converIds do
        local cfg = LuaCfgMgr.Get("PhoneMsgConversation", converIds[i])
        local uid = PhoneMsgHelper.GetConverUid(msgGuid, cfg.ID)

        ---@type X3Data.PhoneMsgConversationData
        local convData = X3DataMgr.Get(X3DataConst.X3Data.PhoneMsgConversationData, uid)

        if convData == nil then
            convData = X3DataMgr.Add(X3DataConst.X3Data.PhoneMsgConversationData)
            convData:SetPrimaryValue(uid)
            convData:SetCfgId(cfg.ID)
            convData:SetType(cfg.Type)
            convData:SetState(X3DataConst.PhoneMsgConversationStateType.Finish)
            convData:SetReadState(i <= lastReadIdx and X3DataConst.PhoneMsgConversationReadType.Read or X3DataConst.PhoneMsgConversationReadType.Unread)
            convData:SetRewardState(PhoneMsgHelper.GetRewardState(cfg))
            convData:SetFireTime(curTime)
        end

        table.insert(result, convData)
    end

    return result, lastReadIdx
end

function PhoneMsgHelper.GetConversation(msgGuid, contactId)
    if msgGuid == nil then
        return {}
    end

    if msgGuid == -1 then
        return BllMgr.GetPhoneMsgBLL():GetLocalConversationList(contactId)
    end

    local severData = SelfProxyFactory.GetPhoneMsgProxy():GetMessageData(msgGuid)
    if severData == nil then
        return {}
    end

    local result = {}
    if severData:GetIsFinished() then
        result, _ = PhoneMsgHelper._GetConversationIds(msgGuid)
    else
        result = BllMgr.GetPhoneMsgBLL():GetSimulator():GetConversationList(severData:GetContactID())
    end

    return result
end

---@param conversations X3Data.PhoneMsgConversationData[]
function PhoneMsgHelper.ReleaseHistory(contactId, conversations)
    if conversations == nil then
        return
    end

    local contactData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contactId)
    local curMsg = contactData:GetCurMsgID()

    for i = 1, conversations do
        local uid = conversations[i]:GetPrimaryValue()
        if curMsg ~= PhoneMsgHelper.GetConverMsgId(uid) then
            X3DataMgr.Remove(X3DataConst.X3Data.PhoneMsgConversationData, uid)
        end
    end
end

---@param uidList int[]
function PhoneMsgHelper.ReleaseHistoryByUidList(contactId, uidList)
    if uidList == nil then
        return
    end

    local contactData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contactId)
    local curMsg = contactData and contactData:GetCurMsgID()

    for i = 1, #uidList do
        local uid = uidList[i]
        if curMsg and curMsg ~= PhoneMsgHelper.GetConverMsgId(uid) then
            X3DataMgr.Remove(X3DataConst.X3Data.PhoneMsgConversationData, uid)
        end
    end
end

---@param cfg cfg.PhoneMsgConversation
---@return X3DataConst.PhoneMsgConversationRewardType
function PhoneMsgHelper.GetRewardState(cfg)
    local rewardMap = SelfProxyFactory.GetPhoneMsgProxy():GetRewardMap()
    local redPacketMap = SelfProxyFactory.GetPhoneMsgProxy():GetRedPacketMap()
    if cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_REWARD then
        if rewardMap and rewardMap[cfg.ID] then
            return X3DataConst.PhoneMsgConversationRewardType.Rewarded
        else
            return X3DataConst.PhoneMsgConversationRewardType.UnRewarded
        end
    end

    if cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_REDPACKET then
        if redPacketMap and redPacketMap[cfg.ID] then
            return X3DataConst.PhoneMsgConversationRewardType.Rewarded
        else
            return X3DataConst.PhoneMsgConversationRewardType.UnRewarded
        end
    end

    return X3DataConst.PhoneMsgConversationRewardType.None
end

function PhoneMsgHelper.GetChoiceResult(cfgId, recordList)
    local chooseList = BllMgr.GetPhoneMsgBLL():GetAllNextOption(cfgId, nil, true)

    local chooseID = nil

    if chooseList ~= nil and recordList ~= nil then
        for i = 1, #chooseList do
            for j = 1, #recordList do
                if chooseList[i] == recordList[j] then
                    chooseID = chooseList[i]
                    break
                end
            end
        end
    end

    return chooseID
end

---节点是否通过
---@param msgGUID int ServerID
---@param converID int 对话ID
---@return bool
function PhoneMsgHelper.NodeIsPass(msgGUID, converID)
    local chatData = BllMgr.GetPhoneMsgBLL():GetServerChatData(msgGUID)
    ---@type cfg.PhoneMsgConversation
    local cfg = LuaCfgMgr.Get(msgGUID > 0 and "PhoneMsgConversation" or "DialoguePhoneMsgConversation", converID)
    if cfg == nil then
        Debug.LogErrorFormatWithTag("Invalid ConvId : %d", converID)
        return false
    end
    if (cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_CHOICE or cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_CHOICE_AUTO)
            and cfg.Teller == PhoneMsgConst.PlayerTellerId then
        return false
    end

    local keyNodes = {}
    if chatData then
        local choiceList = chatData:GetChoiceList()

        if choiceList then
            for _, v in pairs(choiceList) do
                keyNodes[v] = 1
            end
        end
    end

    local result = true
    local passId = nil

    if cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_CHOICE or cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_MANCHOICE or cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_COMMON_REPLY then
        result = false
        passId = nil
        if cfg.NextID then
            for i = 1, #cfg.NextID do
                if keyNodes[cfg.NextID[i]] ~= nil then
                    result = true
                    passId = cfg.NextID[i]
                    break
                end
            end
        end
    elseif cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_REWARD then
        result = false
        if keyNodes[cfg.ID] ~= nil then
            result = true
        end
    end

    return result, passId
end

---@return X3Data.PhoneMsgConversationData
function PhoneMsgHelper.GetConverData(msgId, converId)
    return X3DataMgr.Get(X3DataConst.X3Data.PhoneMsgConversationData, PhoneMsgHelper.GetConverUid(msgId, converId))
end

function PhoneMsgHelper.GetConverUid(msgId, converId)
    return converId * PhoneMsgConst.ConverUidOffset + msgId
end

function PhoneMsgHelper.GetConverId(msgId, converUid)
    return (converUid - msgId) // PhoneMsgConst.ConverUidOffset
end

function PhoneMsgHelper.GetConverMsgId(converUid)
    return converUid % PhoneMsgConst.ConverUidOffset
end

---@param cfg cfg.PhoneMsgConversation
---@param severData X3Data.PhoneMsgDetailData
function PhoneMsgHelper._GetNextId(cfg, severData)
    if PhoneMsgConst.ChoiceType[cfg.Type] then
        local nextId = PhoneMsgHelper.GetChoiceResult(cfg.ID, severData:GetChoiceList())
        return nextId , true, nextId ~= nil
    end

    local nextId = nil
    if cfg.NextID then
        nextId = cfg.NextID[1]
    end

    if cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_REWARD then
        local rwdMap = SelfProxyFactory.GetPhoneMsgProxy():GetRewardMap()
        return nextId, true, rwdMap and rwdMap[cfg.ID]
    end

    return nextId, false, true
end

function PhoneMsgHelper.GetHistoryData(contactID)
    local activeMsgList = PhoneMsgHelper.GetActiveHistoryMsgData(contactID)

    local result = {}
    for i = 1, #activeMsgList do
        local msgData = SelfProxyFactory.GetPhoneMsgProxy():GetMessageData(activeMsgList[i])
        local msgInfo = LuaCfgMgr.Get("PhoneMsg", msgData:GetID())
        local msgType = LuaCfgMgr.Get("MsgType", msgInfo.Type)

        if msgType.IsShow == 1 then
            result[msgData:GetPrimaryValue()] = PhoneMsgHelper.FillHistoryData(
                    msgData:GetPrimaryValue(),
                    msgData:GetID(),
                    msgData:GetPrimaryValue(),
                    msgInfo.Type,
                    UITextHelper.GetUIText(msgInfo.Name),
                    PhoneMsgHelper.GetConversation(msgData:GetPrimaryValue()),
                    msgData:GetCreateTime(),
                    contactID,
                    true
            )
        end
    end

    return result
end

function PhoneMsgHelper.FillHistoryData(id, msgid, guid, type, title, convlist, createTime, contactId, isFinish)
    local mresult = {
        ID = id,
        MsgID = msgid,
        GUID = guid,
        Type = type,
        Title = title,
        ConvList = convlist,
        CreateTime = createTime,
        ContactId = contactId,
        IsFinish = isFinish
    }

    return mresult
end

function PhoneMsgHelper.GetActiveHistoryMsgData(contactID)
    local activeMsgList = {}

    local contData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contactID)
    if contData == nil then
        return activeMsgList
    end

    local contractList = contData:GetHistory()

    if contractList then
        for i = 1, #contractList do
            if contractList[i] ~= contData:GetCurMsgID() then
                table.insert(activeMsgList, #activeMsgList + 1, contractList[i])
            end
        end
    end

    return activeMsgList
end

function PhoneMsgHelper.GetDailyTime(contactId, type, msgId)
    local recordProxy = SelfProxyFactory.GetUserRecordProxy()
    if type == X3_CFG_CONST.MESSAGE_TYPE_CHAT then
        return recordProxy:GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeTodayChatNum, contactId, msgId)
    elseif type == X3_CFG_CONST.MESSAGE_TYPE_AVATAR then
        return recordProxy:GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeChangeHeadTimes, contactId)
    elseif type == X3_CFG_CONST.MESSAGE_TYPE_BUBBLE then
        return recordProxy:GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeChangeBubbleTimes, contactId)
    elseif type == X3_CFG_CONST.MESSAGE_TYPE_PAT then
        return recordProxy:GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeNudgeNum, contactId)
    elseif type == X3_CFG_CONST.MESSAGE_TYPE_SUFFIX then
        return recordProxy:GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeChangeNudgeTimes, contactId)
    end

    return 0
end

return PhoneMsgHelper