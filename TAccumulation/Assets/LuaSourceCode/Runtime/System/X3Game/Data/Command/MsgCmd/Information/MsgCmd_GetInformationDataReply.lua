﻿--- Generated by AutoGen
---
---@class MsgCmd_GetInformationDataReply
local MsgCmd_GetInformationDataReply = class("MsgCmd_GetInformationDataReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GetInformationDataReply
function MsgCmd_GetInformationDataReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetLovePointBLL():UpdateServerData(reply.Information.InformationMap)
end

return MsgCmd_GetInformationDataReply