﻿--- Generated by AutoGen
---
---@class MsgCmd_MessageGetRewardReply
local MsgCmd_MessageGetRewardReply = class("MsgCmd_MessageGetRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.MessageGetRewardReply
---@param request pbcmessage.MessageGetRewardRequest
function MsgCmd_MessageGetRewardReply:Execute(reply, request)
    ---Insert Your Code Here!
    BllMgr.GetPhoneMsgBLL():GetRewardReply(request.Guid, request.ConversationID, reply.RewardList)
end

return MsgCmd_MessageGetRewardReply