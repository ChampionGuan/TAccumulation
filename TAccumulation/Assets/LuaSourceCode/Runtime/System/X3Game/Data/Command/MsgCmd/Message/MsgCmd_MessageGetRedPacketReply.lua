﻿--- Generated by AutoGen
---
---@class MsgCmd_MessageGetRedPacketReply
local MsgCmd_MessageGetRedPacketReply = class("MsgCmd_MessageGetRedPacketReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.MessageGetRedPacketReply
---@param request pbcmessage.MessageGetRedPacketRequest
function MsgCmd_MessageGetRedPacketReply:Execute(reply, request)
    ---Insert Your Code Here!
    BllMgr.GetPhoneMsgBLL():GetRedPacketReply(request.Guid, request.ConversationID, reply.RewardList)
end

return MsgCmd_MessageGetRedPacketReply
