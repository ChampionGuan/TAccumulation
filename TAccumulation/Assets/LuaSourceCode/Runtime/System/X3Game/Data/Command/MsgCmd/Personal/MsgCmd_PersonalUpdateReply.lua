﻿--- Generated by AutoGen
---
---@class MsgCmd_PersonalUpdateReply
local MsgCmd_PersonalUpdateReply = class("MsgCmd_PersonalUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.PersonalUpdateReply
function MsgCmd_PersonalUpdateReply:Execute(data)
    SelfProxyFactory.GetPlayerInfoProxy():PersonalUpdate(data.Personal)
end

return MsgCmd_PersonalUpdateReply
