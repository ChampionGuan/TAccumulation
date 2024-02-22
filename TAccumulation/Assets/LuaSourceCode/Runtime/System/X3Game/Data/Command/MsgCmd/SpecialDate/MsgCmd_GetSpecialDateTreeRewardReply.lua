﻿--- Generated by AutoGen
---
---@class MsgCmd_GetSpecialDateTreeRewardReply
local MsgCmd_GetSpecialDateTreeRewardReply = class("MsgCmd_GetSpecialDateTreeRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param msg pbcmessage.GetSpecialDateTreeRewardReply
function MsgCmd_GetSpecialDateTreeRewardReply:Execute(msg)
    local proxy = SelfProxyFactory.GetSpecialDateProxy()
    proxy:UpdateSpecialDateTreeReward(msg.RewardId)
    BllMgr.GetSpecialDateBLL():CheckRed(false, true)
end

return MsgCmd_GetSpecialDateTreeRewardReply