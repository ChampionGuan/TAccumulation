﻿--- Generated by AutoGen
---
---@class MsgCmd_GetGemCoreDataReply
local MsgCmd_GetGemCoreDataReply = class("MsgCmd_GetGemCoreDataReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GetGemCoreDataReply
function MsgCmd_GetGemCoreDataReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetGemCoreProxy():OnGetGemCoreDataReply(reply)
end

return MsgCmd_GetGemCoreDataReply
