﻿--- Generated by AutoGen
---
---@class MsgCmd_UpdatePersonalCoverReply
local MsgCmd_UpdatePersonalCoverReply = class("MsgCmd_UpdatePersonalCoverReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.UpdatePersonalCoverReply
function MsgCmd_UpdatePersonalCoverReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetPlayerInfoProxy():UpdateCover(reply.Cover)
end

return MsgCmd_UpdatePersonalCoverReply
