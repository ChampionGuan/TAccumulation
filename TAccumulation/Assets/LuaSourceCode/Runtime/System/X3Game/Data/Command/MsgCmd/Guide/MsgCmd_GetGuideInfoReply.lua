﻿--- Generated by AutoGen
---
---@class MsgCmd_GetGuideInfoReply
local MsgCmd_GetGuideInfoReply = class("MsgCmd_GetGuideInfoReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.GetGuideInfoReply
function MsgCmd_GetGuideInfoReply:Execute(data)
	print("GetGuideInfoReply")
	Debug.LogTable(data)
end

return MsgCmd_GetGuideInfoReply
