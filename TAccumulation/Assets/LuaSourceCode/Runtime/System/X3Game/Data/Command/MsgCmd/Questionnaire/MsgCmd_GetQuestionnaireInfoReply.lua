﻿--- Generated by AutoGen
---
---@class MsgCmd_GetQuestionnaireInfoReply
local MsgCmd_GetQuestionnaireInfoReply = class("MsgCmd_GetQuestionnaireInfoReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GetQuestionnaireInfoReply
function MsgCmd_GetQuestionnaireInfoReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetQuestionBll():RefreshQuestionData(reply.Data)
end

return MsgCmd_GetQuestionnaireInfoReply
