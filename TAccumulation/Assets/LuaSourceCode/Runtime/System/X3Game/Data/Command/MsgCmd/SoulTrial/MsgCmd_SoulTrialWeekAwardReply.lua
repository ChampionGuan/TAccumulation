﻿--- Generated by AutoGen
---
---@class MsgCmd_SoulTrialWeekAwardReply
local MsgCmd_SoulTrialWeekAwardReply = class("MsgCmd_SoulTrialWeekAwardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SoulTrialWeekAwardReply
function MsgCmd_SoulTrialWeekAwardReply:Execute(data)
    SelfProxyFactory.GetSoulTrialProxy():SoulTrialWeekAwardReply(data)
    EventMgr.Dispatch(SoulTrialConst.Event.SERVER_ST_WEEK_AWARD_REPLY, data)
end

return MsgCmd_SoulTrialWeekAwardReply
