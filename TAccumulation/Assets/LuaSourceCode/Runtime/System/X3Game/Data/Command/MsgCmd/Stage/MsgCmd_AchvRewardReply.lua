﻿--- Generated by AutoGen
---
---@class MsgCmd_AchvRewardReply
local MsgCmd_AchvRewardReply = class("MsgCmd_AchvRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.AchvRewardReply
function MsgCmd_AchvRewardReply:Execute(data)
    UICommonUtil.ShowRewardPopTips(data.RewardList, 1)
    EventMgr.Dispatch("OnAchvRewardCallBack", data);
end

return MsgCmd_AchvRewardReply
