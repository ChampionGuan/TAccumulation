﻿--- Generated by AutoGen
---
---@class MsgCmd_MessageManBubbleStartReply
local MsgCmd_MessageManBubbleStartReply = class("MsgCmd_MessageManBubbleStartReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.MessageManBubbleStartReply
function MsgCmd_MessageManBubbleStartReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetPhoneMsgBLL():StartMsgSuccess(reply.Msg)
end

return MsgCmd_MessageManBubbleStartReply
