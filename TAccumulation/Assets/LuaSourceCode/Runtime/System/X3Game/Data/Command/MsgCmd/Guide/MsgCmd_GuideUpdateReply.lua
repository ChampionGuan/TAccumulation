﻿--- Generated by AutoGen
---
---@class MsgCmd_GuideUpdateReply
local MsgCmd_GuideUpdateReply = class("MsgCmd_GuideUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.GuideUpdateReply
function MsgCmd_GuideUpdateReply:Execute(data)
	Debug.LogTable(data)
	BllMgr.GetNoviceGuideBLL():Update(data.OpType,data.OpReason,data.UserGuideList)
end

return MsgCmd_GuideUpdateReply