﻿--- Generated by AutoGen
---
---@class MsgCmd_JewelExchangeReply
local MsgCmd_JewelExchangeReply = class("MsgCmd_JewelExchangeReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.JewelExchangeReply
function MsgCmd_JewelExchangeReply:Execute(reply)
    ---Insert Your Code Here!
    EventMgr.Dispatch("StartJewel_ShortCut_ExChangeFinish")
end

return MsgCmd_JewelExchangeReply