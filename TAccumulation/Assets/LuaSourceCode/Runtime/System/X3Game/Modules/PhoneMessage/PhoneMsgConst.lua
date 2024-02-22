﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2022/11/30 16:50
---@class PhoneMsgConst
local PhoneMsgConst = {}
PhoneMsgConst.StartNodeType = 0
PhoneMsgConst.NormalMsgType = {
    [X3_CFG_CONST.MESSAGE_TYPE_DRAMA] = true,
    [X3_CFG_CONST.MESSAGE_TYPE_FETTERS] = true,
    [X3_CFG_CONST.MESSAGE_TYPE_DAILY] = true,
    [X3_CFG_CONST.MESSAGE_TYPE_RETURN] = true,
}

PhoneMsgConst.SavingMsgType = {
    [X3_CFG_CONST.MESSAGE_TYPE_DRAMA] = true,
    [X3_CFG_CONST.MESSAGE_TYPE_FETTERS] = true,
    [X3_CFG_CONST.MESSAGE_TYPE_DAILY] = true,
    [X3_CFG_CONST.MESSAGE_TYPE_RETURN] = true,
}

PhoneMsgConst.ContentConversationType = {
    [X3_CFG_CONST.CONVERSATION_TYPE_TEXT] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_VOICE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_PICTURE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_VIDEO] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_REDPACKET] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_OFFCIALARTICLE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_RECALL] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_AVATAR] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_BUBBLE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_CHATSTICKER] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_LINK] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_EXPIREDIMAGE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_WORLDINFO] = true,
}

PhoneMsgConst.LogicConversationType = {
    [X3_CFG_CONST.CONVERSATION_TYPE_CHOICE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_MANCHOICE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_CHANGE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_COMMON_REPLY] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_CHOICE_AUTO] = true,
}

PhoneMsgConst.HideType = {
    [PhoneMsgConst.StartNodeType] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_CHOICE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_REWARD] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_MANCHOICE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_TYPEIN] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_CHANGE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_CHOICE_AUTO] = true,
}

PhoneMsgConst.ChoiceType = {
    [X3_CFG_CONST.CONVERSATION_TYPE_CHOICE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_MANCHOICE] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_COMMON_REPLY] = true,
    [X3_CFG_CONST.CONVERSATION_TYPE_CHOICE_AUTO] = true,
}

PhoneMsgConst.MsgLoop = {
    [X3DataConst.PhoneMsgConversationStateType.Begin] = X3DataConst.PhoneMsgConversationStateType.Reading,
    [X3DataConst.PhoneMsgConversationStateType.Reading] = X3DataConst.PhoneMsgConversationStateType.Input,
    [X3DataConst.PhoneMsgConversationStateType.Input] = X3DataConst.PhoneMsgConversationStateType.Execute,
    [X3DataConst.PhoneMsgConversationStateType.Execute] = X3DataConst.PhoneMsgConversationStateType.Finish,
}

PhoneMsgConst.ConverUidOffset = 100000
PhoneMsgConst.ProgressUidOffset = 100
PhoneMsgConst.PlayerTellerId = 0
PhoneMsgConst.PlayerContactId = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONECONTACTPLAYER)
PhoneMsgConst.PhoneMsgReadDelayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMSGREADDELAYTIME) / 1000
PhoneMsgConst.PhoneMsgActiveTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMSGACTIVETIME)

PhoneMsgConst.MessageUpdateEvent = "EVENT_MESSAGE_UPDATE"
PhoneMsgConst.MessageReadUpdateEvent = "EVENT_MESSAGE_READ_UPDATE"
PhoneMsgConst.ContactNameUnlockEvent = "EVENT_MESSAGE_UNLOCK_CONTACT_NAME"
PhoneMsgConst.DrawMsgEvent = "EVENT_DRAW_MSG"

PhoneMsgConst.ChangeHeadWaitStartTime =
{
    [1] = GameConst.CustomDataIndex.PhoneMsgHeadTimeRole1,
    [2] = GameConst.CustomDataIndex.PhoneMsgHeadTimeRole2,
    [3] = GameConst.CustomDataIndex.PhoneMsgHeadTimeRole3,
    [4] = GameConst.CustomDataIndex.PhoneMsgHeadTimeRole4,
    [5] = GameConst.CustomDataIndex.PhoneMsgHeadTimeRole5,
}

PhoneMsgConst.ChangeHeadWaitTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEREJECTMSGWAITTIME)
PhoneMsgConst.HeadStateCondition =
{
    [0] = X3DataConst.PhoneContactHeadState.ChangeWaiting,
    [1] = X3DataConst.PhoneContactHeadState.ChangeSuccess,
    [2] = X3DataConst.PhoneContactHeadState.ChangeFail,
}

PhoneMsgConst.JumpType =
{
    Normal = 0,
    Stickers = 1,
    Function = 2
}

PhoneMsgConst.InvalidMsgId = -1
return PhoneMsgConst