﻿--- Generated by AutoGen
---
---@class MsgCmd_ResetHunterContestSeasonReply
local MsgCmd_ResetHunterContestSeasonReply = class("MsgCmd_ResetHunterContestSeasonReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))
local HunterContestConst = require("Runtime.System.X3Game.GameConst.HunterContestConst")

---Command执行
---@param reply pbcmessage.ResetHunterContestSeasonReply
function MsgCmd_ResetHunterContestSeasonReply:Execute(reply, cacheData)
    ---Insert Your Code Here!
    SelfProxyFactory.GetHunterContestDataProxy():ResetSeaonCardsReply(cacheData)
    EventMgr.Dispatch(HunterContestConst.Event.ResetHunterContestSeasonReply)
end

return MsgCmd_ResetHunterContestSeasonReply