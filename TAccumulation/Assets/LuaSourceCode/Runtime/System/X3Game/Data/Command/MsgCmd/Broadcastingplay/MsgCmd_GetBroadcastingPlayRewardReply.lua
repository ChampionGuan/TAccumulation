﻿--- Generated by AutoGen
---
---@class MsgCmd_GetBroadcastingPlayRewardReply
local MsgCmd_GetBroadcastingPlayRewardReply = class("MsgCmd_GetBroadcastingPlayRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param serverData pbcmessage.GetBroadcastingPlayRewardReply
function MsgCmd_GetBroadcastingPlayRewardReply:Execute(rewardData, sendData)
    BllMgr.GetRadioNewBLL():RecvMsg_GetReward(rewardData, sendData)
end

return MsgCmd_GetBroadcastingPlayRewardReply
