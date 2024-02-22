﻿--- Generated by AutoGen
---
---@class MsgCmd_TitleUpdateReply
local MsgCmd_TitleUpdateReply = class("MsgCmd_TitleUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.TitleUpdateReply
function MsgCmd_TitleUpdateReply:Execute(data)
	if data.TitleList then
		SelfProxyFactory.GetPlayerInfoProxy():TitleUpdate(data.TitleList)
	end
end

return MsgCmd_TitleUpdateReply