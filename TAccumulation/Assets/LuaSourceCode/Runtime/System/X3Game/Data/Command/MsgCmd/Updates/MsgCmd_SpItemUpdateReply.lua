﻿--- Generated by AutoGen
---
---@class MsgCmd_SpItemUpdateReply
local MsgCmd_SpItemUpdateReply = class("MsgCmd_SpItemUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.SpItemUpdateReply
function MsgCmd_SpItemUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    for k, v in pairs(reply.SpItemList) do
        BllMgr.GetItemBLL():AddSpItem(v)
    end
end

return MsgCmd_SpItemUpdateReply