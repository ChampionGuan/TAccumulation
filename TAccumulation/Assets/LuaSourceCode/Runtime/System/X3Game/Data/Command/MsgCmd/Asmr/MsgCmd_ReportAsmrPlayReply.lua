﻿--- Generated by AutoGen
---
---@class MsgCmd_ReportAsmrPlayReply
local MsgCmd_ReportAsmrPlayReply = class("MsgCmd_ReportAsmrPlayReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.ReportAsmrPlayReply
function MsgCmd_ReportAsmrPlayReply:Execute(reply, sendData) 
    BllMgr.GetASMRBLL():RecvMsg_AsmrPlayReply(reply, sendData)
end

return MsgCmd_ReportAsmrPlayReply
