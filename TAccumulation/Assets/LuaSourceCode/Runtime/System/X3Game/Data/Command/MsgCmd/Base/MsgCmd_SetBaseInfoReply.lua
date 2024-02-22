﻿--- Generated by AutoGen
---
---@class MsgCmd_SetBaseInfoReply
local MsgCmd_SetBaseInfoReply = class("MsgCmd_SetBaseInfoReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SetBaseInfoReply
function MsgCmd_SetBaseInfoReply:Execute(data, request)
	SelfProxyFactory.GetPlayerInfoProxy():UpdateName(request)
	SelfProxyFactory.GetPlayerInfoProxy():UpdateNickName({ Nickname = request.GenericNickname }, true)
	SelfProxyFactory.GetPlayerInfoProxy():UpdateBirthday(request.Birthday)
	EventMgr.Dispatch("CreateCharacter_SetBaseInfo_Succeed")
end

return MsgCmd_SetBaseInfoReply