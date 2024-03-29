﻿--- Generated by AutoGen
---
---@class MsgCmd_GetItemInfoReply
local MsgCmd_GetItemInfoReply = class("MsgCmd_GetItemInfoReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.GetItemInfoReply
function MsgCmd_GetItemInfoReply:Execute(data)
    for k, v in data.Item.ItemMap do
        BllMgr.GetItemBLL():AddItem(v)
    end
    for k, v in data.Item.SpitemList do
        BllMgr.GetItemBLL():AddSpItem(v)
    end
    Debug.Log("GetItemInfoReplyHandle");
end

return MsgCmd_GetItemInfoReply
