﻿--- Generated by AutoGen
---
---@class MsgCmd_RoleLoveLevelUpRewardsReply
local MsgCmd_RoleLoveLevelUpRewardsReply = class("MsgCmd_RoleLoveLevelUpRewardsReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.RoleLoveLevelUpRewardsReply
function MsgCmd_RoleLoveLevelUpRewardsReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetLovePointProxy():AddLvRewardData(reply)
end

return MsgCmd_RoleLoveLevelUpRewardsReply
