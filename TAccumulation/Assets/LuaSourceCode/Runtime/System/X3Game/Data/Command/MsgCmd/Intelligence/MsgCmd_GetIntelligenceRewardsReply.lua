﻿--- Generated by AutoGen
---
---@class MsgCmd_GetIntelligenceRewardsReply
local MsgCmd_GetIntelligenceRewardsReply = class("MsgCmd_GetIntelligenceRewardsReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GetIntelligenceRewardsReply
function MsgCmd_GetIntelligenceRewardsReply:Execute(reply, request)
    SelfProxyFactory.GetWorldIntelligenceProxy():UpdateReward(request.IntelligenceList, true)
end

return MsgCmd_GetIntelligenceRewardsReply
