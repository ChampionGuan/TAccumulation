﻿--- Generated by AutoGen
---
---@class MsgCmd_CardAwakenReply
local MsgCmd_CardAwakenReply = class("MsgCmd_CardAwakenReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.CardAwakenReply
function MsgCmd_CardAwakenReply:Execute(reply, request)
    SelfProxyFactory.GetCardDataProxy():OnCardAwakenReply(request.Id)
end

return MsgCmd_CardAwakenReply
