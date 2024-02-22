﻿--- Generated by AutoGen
---
---@class MsgCmd_ActivityTotalLoginClaimReply
local MsgCmd_ActivityTotalLoginClaimReply = class("MsgCmd_ActivityTotalLoginClaimReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.ActivityTotalLoginClaimReply
function MsgCmd_ActivityTotalLoginClaimReply:Execute(reply, clientData)
    ---Insert Your Code Here!
    SelfProxyFactory.GetActivityCenterProxy():UpdateSignData(clientData)
    EventMgr.Dispatch("OnGetActivitySignReward", clientData.ActivityID, reply.Rewards)
    --活动红点
    BllMgr.GetActivityCenterBLL():UpdateAllActivityItemRewardRp()
end

return MsgCmd_ActivityTotalLoginClaimReply