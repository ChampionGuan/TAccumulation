﻿--- Generated by AutoGen
---
---@class MsgCmd_ActiveUpdateReply
local MsgCmd_ActiveUpdateReply = class("MsgCmd_ActiveUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.ActiveUpdateReply
function MsgCmd_ActiveUpdateReply:Execute(data)
	BllMgr.GetActiveBLL():ActiveUpdateCallBack(data)
	EventMgr.Dispatch("OnActiveUpdateCallBack",data)
end

return MsgCmd_ActiveUpdateReply
