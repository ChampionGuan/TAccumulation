﻿--- Generated by AutoGen
---
---@class MsgCmd_BattlePassGetWeeklyRewardReply
local MsgCmd_BattlePassGetWeeklyRewardReply = class("MsgCmd_BattlePassGetWeeklyRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BattlePassGetWeeklyRewardReply
function MsgCmd_BattlePassGetWeeklyRewardReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetBattlePassProxy():UpdateWeeklyReward(reply)
    UICommonUtil.ShowRewardPopTips(reply.Rewards, 2)
end

return MsgCmd_BattlePassGetWeeklyRewardReply