﻿--- Generated by AutoGen
---
---@class MsgCmd_QuitBroadcastingPlayReply
local MsgCmd_QuitBroadcastingPlayReply = class("MsgCmd_QuitBroadcastingPlayReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param serverData pbcmessage.QuitBroadcastingPlayReply
function MsgCmd_QuitBroadcastingPlayReply:Execute(serverData, sendData)
    BllMgr.GetRadioNewBLL():RecvMsg_QuitRadio(sendData)
end

return MsgCmd_QuitBroadcastingPlayReply
