﻿--- Generated by AutoGen
---
---@class MsgCmd_UpdateBuyRecordReply
local MsgCmd_UpdateBuyRecordReply = class("MsgCmd_UpdateBuyRecordReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.UpdateBuyRecordReply
function MsgCmd_UpdateBuyRecordReply:Execute(reply)
    ---Insert Your Code Here!
    local proxy = SelfProxyFactory.GetDailyDateProxy()
    proxy:UpdateBuyRecords(reply.LastRefreshTime, reply.UpdateRecords, false)
end

return MsgCmd_UpdateBuyRecordReply