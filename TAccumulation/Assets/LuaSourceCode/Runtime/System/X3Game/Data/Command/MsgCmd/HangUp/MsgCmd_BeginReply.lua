﻿--- Generated by AutoGen
---
---@class MsgCmd_BeginReply
local MsgCmd_BeginReply = class("MsgCmd_BeginReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BeginReply
function MsgCmd_BeginReply:Execute(reply)
    BllMgr.GetHangUpBLL():BeginReply(reply)
    ---Insert Your Code Here!
end

return MsgCmd_BeginReply