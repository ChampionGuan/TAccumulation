﻿--- Generated by AutoGen
---
---@class MsgCmd_LPTaskGroupFinishReply
local MsgCmd_LPTaskGroupFinishReply = class("MsgCmd_LPTaskGroupFinishReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.LPTaskGroupFinishReply
function MsgCmd_LPTaskGroupFinishReply:Execute(data)
	BllMgr.GetRoleBLL():OnLPTaskGroupFinishReply(data)
end

return MsgCmd_LPTaskGroupFinishReply