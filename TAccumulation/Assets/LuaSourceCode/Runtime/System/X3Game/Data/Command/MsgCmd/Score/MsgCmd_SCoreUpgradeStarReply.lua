﻿--- Generated by AutoGen
---
---@class MsgCmd_SCoreUpgradeStarReply
local MsgCmd_SCoreUpgradeStarReply = class("MsgCmd_SCoreUpgradeStarReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SCoreUpgradeStarReply
function MsgCmd_SCoreUpgradeStarReply:Execute(data)
	SelfProxyFactory.GetScoreProxy():SCoreUpgradeStarReply(data)
	EventMgr.Dispatch(ScoreConst.Event.SCORE_UPDATE_STAR_REPLY)
end

return MsgCmd_SCoreUpgradeStarReply