﻿--- Generated by AutoGen
---
---@class MsgCmd_SetRoleHeadCardIDReply
local MsgCmd_SetRoleHeadCardIDReply = class("MsgCmd_SetRoleHeadCardIDReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SetRoleHeadCardIDReply
function MsgCmd_SetRoleHeadCardIDReply:Execute(data)
	BllMgr.GetRoleBLL():OnSetRoleHeadCardIDCallBack(data)
end

return MsgCmd_SetRoleHeadCardIDReply