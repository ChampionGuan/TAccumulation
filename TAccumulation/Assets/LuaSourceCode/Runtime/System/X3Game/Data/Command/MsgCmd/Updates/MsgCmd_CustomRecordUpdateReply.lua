﻿--- Generated by AutoGen
---
---@class MsgCmd_CustomRecordUpdateReply
local MsgCmd_CustomRecordUpdateReply = class("MsgCmd_CustomRecordUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.CustomRecordUpdateReply
function MsgCmd_CustomRecordUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetCustomRecordBLL():UpdateRecord(reply.CustomRecordType, reply.Record)
end

return MsgCmd_CustomRecordUpdateReply
