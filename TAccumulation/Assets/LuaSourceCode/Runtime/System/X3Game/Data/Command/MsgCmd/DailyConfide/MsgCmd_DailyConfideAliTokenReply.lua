﻿--- Generated by AutoGen
---
---@class MsgCmd_DailyConfideAliTokenReply
local MsgCmd_DailyConfideAliTokenReply = class("MsgCmd_DailyConfideAliTokenReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))
---@type DailyConfideConst
local DailyConfideConst = require("Runtime.System.X3Game.Modules.DailyConfide.Data.DailyConfideConst")
---Command执行
---@param reply pbcmessage.DailyConfideAliTokenReply
function MsgCmd_DailyConfideAliTokenReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetDailyConfideBll():SetToken(reply)

end

return MsgCmd_DailyConfideAliTokenReply