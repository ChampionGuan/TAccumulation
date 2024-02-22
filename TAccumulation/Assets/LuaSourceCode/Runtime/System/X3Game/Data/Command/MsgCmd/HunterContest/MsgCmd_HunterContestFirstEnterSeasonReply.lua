﻿--- Generated by AutoGen
---
---@class MsgCmd_HunterContestFirstEnterSeasonReply
local MsgCmd_HunterContestFirstEnterSeasonReply = class("MsgCmd_HunterContestFirstEnterSeasonReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))
local HunterContestConst = require("Runtime.System.X3Game.GameConst.HunterContestConst")

---Command执行
---@param reply pbcmessage.HunterContestFirstEnterSeasonReply
function MsgCmd_HunterContestFirstEnterSeasonReply:Execute(reply, cacheData)
    ---Insert Your Code Here!
    SelfProxyFactory.GetHunterContestDataProxy():FirstEnterSeasonReply(reply.LastSeason, cacheData.ID)
    EventMgr.Dispatch(HunterContestConst.Event.FirstEnterSeasonReply)
end

return MsgCmd_HunterContestFirstEnterSeasonReply