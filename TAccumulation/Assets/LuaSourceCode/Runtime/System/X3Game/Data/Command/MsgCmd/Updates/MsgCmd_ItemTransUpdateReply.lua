﻿--- Generated by AutoGen
---
---@class MsgCmd_ItemTransUpdateReply
local MsgCmd_ItemTransUpdateReply = class("MsgCmd_ItemTransUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.ItemTransUpdateReply
function MsgCmd_ItemTransUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetItemBLL():OnItemTransUpdateCallBack(reply)
end

return MsgCmd_ItemTransUpdateReply