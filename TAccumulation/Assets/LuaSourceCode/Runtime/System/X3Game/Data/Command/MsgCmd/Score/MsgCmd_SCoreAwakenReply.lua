﻿--- Generated by AutoGen
---
---@class MsgCmd_SCoreAwakenReply
local MsgCmd_SCoreAwakenReply = class("MsgCmd_SCoreAwakenReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param Data pbcmessage.SCoreAwakenReply
function MsgCmd_SCoreAwakenReply:Execute(data)
	SelfProxyFactory.GetScoreProxy():SCoreAwakenReply(data)
	EventMgr.Dispatch(ScoreConst.Event.SCORE_AWAKEN_REPLY, data)
end

return MsgCmd_SCoreAwakenReply