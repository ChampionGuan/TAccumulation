﻿--- Generated by AutoGen
---
---@class MsgCmd_BattlePassGetLevelRewardReply
local MsgCmd_BattlePassGetLevelRewardReply = class("MsgCmd_BattlePassGetLevelRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BattlePassGetLevelRewardReply
function MsgCmd_BattlePassGetLevelRewardReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetBattlePassProxy():UpdateAwardInfo(reply)
    UICommonUtil.ShowRewardPopTips(reply.Rewards, 2)
end

return MsgCmd_BattlePassGetLevelRewardReply
