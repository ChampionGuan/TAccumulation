﻿--- Generated by AutoGen
---
---@class MsgCmd_ReturnSetRoleReply
local MsgCmd_ReturnSetRoleReply = class("MsgCmd_ReturnSetRoleReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.ReturnSetRoleReply
function MsgCmd_ReturnSetRoleReply:Execute(reply, request)
    ---Insert Your Code Here!
    SelfProxyFactory.GetReturnActivityProxy():OnSetRoleReply(request.RoleID)
end

return MsgCmd_ReturnSetRoleReply
