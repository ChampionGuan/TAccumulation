﻿--- Generated by AutoGen
---
---@class MsgCmd_GemCoreBreakReply
local MsgCmd_GemCoreBreakReply = class("MsgCmd_GemCoreBreakReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GemCoreBreakReply
function MsgCmd_GemCoreBreakReply:Execute(reply)
    ---Insert Your Code Here!
    ---Insert Your Code Here!
    local proxy=  SelfProxyFactory.GetGemCoreProxy()
    proxy:OnGemCoreBreakReply(reply)
    UICommonUtil.ShowRewardPopTips(reply.Rewards, 2, false)
end

return MsgCmd_GemCoreBreakReply
