﻿--- Generated by AutoGen
---
---@class MsgCmd_MomentMessageUpdateReply
local MsgCmd_MomentMessageUpdateReply = class("MsgCmd_MomentMessageUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.MomentMessageUpdateReply
function MsgCmd_MomentMessageUpdateReply:Execute(data)
    if data.OpType == 1 then
        BllMgr.GetMobileMomentBLL():AddMessage(data.MessageList)
    else
        BllMgr.GetMobileMomentBLL():RemoveMessage(data.MessageList)
    end
end

return MsgCmd_MomentMessageUpdateReply
