﻿--- Generated by AutoGen
---
---@class MsgCmd_GetDailyConfideDataReply
local MsgCmd_GetDailyConfideDataReply = class("MsgCmd_GetDailyConfideDataReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GetDailyConfideDataReply
function MsgCmd_GetDailyConfideDataReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetDailyConfideBll():SetDailyConfideData(reply.Data)
end

return MsgCmd_GetDailyConfideDataReply
