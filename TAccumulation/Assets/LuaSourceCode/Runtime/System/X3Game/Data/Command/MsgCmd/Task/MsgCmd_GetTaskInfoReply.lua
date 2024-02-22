﻿--- Generated by AutoGen
---
---@class MsgCmd_GetTaskInfoReply
local MsgCmd_GetTaskInfoReply = class("MsgCmd_GetTaskInfoReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.GetTaskInfoReply
function MsgCmd_GetTaskInfoReply:Execute(data)
	if data.Task ~= nil then
		SelfProxyFactory.GetTaskProxy():OnEnterGame(data.Task.Quests, data.Task.RwdQuests)
	end
end

return MsgCmd_GetTaskInfoReply