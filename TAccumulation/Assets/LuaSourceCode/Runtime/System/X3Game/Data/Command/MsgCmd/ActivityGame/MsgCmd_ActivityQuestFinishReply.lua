﻿--- Generated by AutoGen
---
---@class MsgCmd_ActivityQuestFinishReply
local MsgCmd_ActivityQuestFinishReply = class("MsgCmd_ActivityQuestFinishReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.ActivityQuestFinishReply
function MsgCmd_ActivityQuestFinishReply:Execute(reply)
    ---Insert Your Code Here!
    --Debug.LogError("MsgCmd_ActivityQuestFinishReply")
    --Debug.LogErrorTable(reply)
    SelfProxyFactory.GetTaskProxy():UpdateFinishTask(reply.Quests)
    SelfProxyFactory.GetActivityCenterProxy():UpdatePointData(reply)
    EventMgr.Dispatch("OnUpdateActivityPoint", reply.Point, reply.ActivityID)

    UICommonUtil.ShowRewardPopTips(reply.RewardList, 1, true)

    EventMgr.Dispatch("OnGetActivityTaskReward", reply.QuestIDs)
    --活动红点
    BllMgr.GetActivityCenterBLL():UpdateAllActivityItemRewardRp()
end

return MsgCmd_ActivityQuestFinishReply
