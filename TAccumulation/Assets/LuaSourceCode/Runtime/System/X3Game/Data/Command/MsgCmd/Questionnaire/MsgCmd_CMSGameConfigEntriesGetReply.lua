﻿--- Generated by AutoGen
---
---@class MsgCmd_CMSGameConfigEntriesGetReply
local MsgCmd_CMSGameConfigEntriesGetReply = class("MsgCmd_CMSGameConfigEntriesGetReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.CMSGameConfigEntriesGetReply
function MsgCmd_CMSGameConfigEntriesGetReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetQuestionBll():OnGetQuestionListReply(reply.Configs)
end

return MsgCmd_CMSGameConfigEntriesGetReply
