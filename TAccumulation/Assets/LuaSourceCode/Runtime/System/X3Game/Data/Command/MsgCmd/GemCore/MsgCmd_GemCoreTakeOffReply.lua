﻿--- Generated by AutoGen
---
---@class MsgCmd_GemCoreTakeOffReply
local MsgCmd_GemCoreTakeOffReply = class("MsgCmd_GemCoreTakeOffReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GemCoreTakeOffReply
function MsgCmd_GemCoreTakeOffReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetGemCoreProxy():OnGemCoreTakeOffReply(reply)
    SelfProxyFactory.GetScoreProxy():GemCoreTakeOffReply(reply)
    EventMgr.Dispatch(ScoreConst.Event.SCORE_TAKEOFF_CORE, reply)
end

return MsgCmd_GemCoreTakeOffReply
