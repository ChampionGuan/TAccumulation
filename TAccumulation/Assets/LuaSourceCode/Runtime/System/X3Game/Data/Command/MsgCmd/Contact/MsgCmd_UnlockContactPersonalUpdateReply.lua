﻿--- Generated by AutoGen
---
---@class MsgCmd_UnlockContactPersonalUpdateReply
local MsgCmd_UnlockContactPersonalUpdateReply = class("MsgCmd_UnlockContactPersonalUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.UnlockContactPersonalUpdateReply
function MsgCmd_UnlockContactPersonalUpdateReply:Execute(data)
    SelfProxyFactory.GetPhoneContactProxy():UnlockContactPersonalUpdate(data)
end

return MsgCmd_UnlockContactPersonalUpdateReply