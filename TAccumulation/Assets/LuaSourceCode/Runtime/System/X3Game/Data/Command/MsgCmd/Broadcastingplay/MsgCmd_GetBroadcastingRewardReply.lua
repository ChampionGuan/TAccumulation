﻿--- Generated by AutoGen
---
---@class MsgCmd_GetBroadcastingRewardReply
local MsgCmd_GetBroadcastingRewardReply = class("MsgCmd_GetBroadcastingRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param serverData pbcmessage.GetBroadcastingRewardReply
function MsgCmd_GetBroadcastingRewardReply:Execute(rewardData, sendData)
    BllMgr.GetRadioNewBLL():RecvMsg_SubRadioReward(rewardData, sendData)
end

return MsgCmd_GetBroadcastingRewardReply
