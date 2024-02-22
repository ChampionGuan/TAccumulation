﻿--- Generated by AutoGen
---
---@class MsgCmd_PhotoComponentUpdateReply
local MsgCmd_PhotoComponentUpdateReply = class("MsgCmd_PhotoComponentUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.PhotoComponentUpdateReply
function MsgCmd_PhotoComponentUpdateReply:Execute(data)
	for k, v in pairs(data.ComponentList) do
		SelfProxyFactory.GetPhotoProxy():SetPhotoItem(v,true)
	end

	EventMgr.Dispatch("Photo_UpdateItem_AddItem")
end

return MsgCmd_PhotoComponentUpdateReply