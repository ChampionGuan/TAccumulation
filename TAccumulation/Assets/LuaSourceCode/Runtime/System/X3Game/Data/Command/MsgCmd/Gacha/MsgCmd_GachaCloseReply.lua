﻿--- Generated by AutoGen
---
---@class MsgCmd_GachaCloseReply
local MsgCmd_GachaCloseReply = class("MsgCmd_GachaCloseReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GachaCloseReply
function MsgCmd_GachaCloseReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetGachaBLL():STC_GachaCloseCallBack(reply)
end

return MsgCmd_GachaCloseReply
