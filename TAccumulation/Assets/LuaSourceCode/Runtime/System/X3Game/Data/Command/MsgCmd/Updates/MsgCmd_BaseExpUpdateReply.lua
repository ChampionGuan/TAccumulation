﻿--- Generated by AutoGen
---
---@class MsgCmd_BaseExpUpdateReply
local MsgCmd_BaseExpUpdateReply = class("MsgCmd_BaseExpUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BaseExpUpdateReply
function MsgCmd_BaseExpUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetPlayerInfoProxy():BaseLevelExpUpdate(reply.Exp, reply.Level)
end

return MsgCmd_BaseExpUpdateReply