﻿--- Generated by AutoGen
---
---@class MsgCmd_GachaOpenReply
local MsgCmd_GachaOpenReply = class("MsgCmd_GachaOpenReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GachaOpenReply
function MsgCmd_GachaOpenReply:Execute(reply)
    BllMgr.GetGachaBLL():STC_GachaOpenCallBack(reply)
end

return MsgCmd_GachaOpenReply