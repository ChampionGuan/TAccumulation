﻿--- Generated by AutoGen
---
---@class MsgCmd_GetQuestInfoReply
local MsgCmd_GetQuestInfoReply = class("MsgCmd_GetQuestInfoReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GetQuestInfoReply
function MsgCmd_GetQuestInfoReply:Execute(reply)
    ---Insert Your Code Here!
    if reply.Quest ~= nil then
        SelfProxyFactory.GetTaskProxy():OnEnterGame(reply.Quest.Quests,reply.Quest.RwdQuests)
    end
end

return MsgCmd_GetQuestInfoReply