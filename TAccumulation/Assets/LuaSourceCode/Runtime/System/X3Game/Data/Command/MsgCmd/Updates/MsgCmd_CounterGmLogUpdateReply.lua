﻿--- Generated by AutoGen
---
---@class MsgCmd_CounterGmLogUpdateReply
local MsgCmd_CounterGmLogUpdateReply = class("MsgCmd_CounterGmLogUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.CounterGmLogUpdateReply
function MsgCmd_CounterGmLogUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    if UNITY_EDITOR then
        EventMgr.DispatchEventToCS("OnCounterTestGMLogUpdate", reply.Data)
    end
end

return MsgCmd_CounterGmLogUpdateReply
