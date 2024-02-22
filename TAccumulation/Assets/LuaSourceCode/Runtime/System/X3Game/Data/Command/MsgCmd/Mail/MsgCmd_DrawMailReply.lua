﻿--- Generated by AutoGen
---
---@class MsgCmd_DrawMailReply
local MsgCmd_DrawMailReply = class("MsgCmd_DrawMailReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.DrawMailReply
function MsgCmd_DrawMailReply:Execute(reply, request)
    if reply.Limit then
        SelfProxyFactory.GetMailProxy():ReadMail(request.Mailid)
    else
        SelfProxyFactory.GetMailProxy():DrawMail(request.Mailid)
    end
end

return MsgCmd_DrawMailReply