﻿--- Generated by AutoGen
---
---@class MsgCmd_AcceptInvitationReply
local MsgCmd_AcceptInvitationReply = class("MsgCmd_AcceptInvitationReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.AcceptInvitationReply
function MsgCmd_AcceptInvitationReply:Execute(reply, sendData)
    ---Insert Your Code Here!
    SelfProxyFactory.GetDatePlanProxy():UpdateDatePlanAcceptInvitation(sendData)
end

return MsgCmd_AcceptInvitationReply
