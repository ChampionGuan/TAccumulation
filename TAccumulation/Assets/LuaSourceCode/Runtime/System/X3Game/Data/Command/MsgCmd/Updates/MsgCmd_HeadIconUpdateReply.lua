﻿--- Generated by AutoGen
---
---@class MsgCmd_HeadIconUpdateReply
local MsgCmd_HeadIconUpdateReply = class("MsgCmd_HeadIconUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.HeadIconUpdateReply
function MsgCmd_HeadIconUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetPlayerInfoProxy():HeadIconItemUpdate(reply.OpType, reply.List)

    --Debug.LogError("HeadIconUpdateReply : " .. table.dump(reply))
end

return MsgCmd_HeadIconUpdateReply
