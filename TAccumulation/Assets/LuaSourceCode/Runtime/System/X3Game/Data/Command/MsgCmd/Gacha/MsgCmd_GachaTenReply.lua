﻿--- Generated by AutoGen
---
---@class MsgCmd_GachaTenReply
local MsgCmd_GachaTenReply = class("MsgCmd_GachaTenReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.GachaTenReply
function MsgCmd_GachaTenReply:Execute(data)
    BllMgr.GetGachaBLL():STC_GachaTenCallBack(data)
end

return MsgCmd_GachaTenReply
