﻿--- Generated by AutoGen
---
---@class MsgCmd_ReadStoryReply
local MsgCmd_ReadStoryReply = class("MsgCmd_ReadStoryReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.ReadStoryReply
---@param request pbcmessage.ReadStoryRequest
function MsgCmd_ReadStoryReply:Execute(reply, request)
    ---Insert Your Code Here!
    --Debug.LogError("MsgCmd_ReadStoryReply : " .. table.dump({reply, request}))

    SelfProxyFactory.GetPlayerBirthdayProxy():UpdateRoleStoryRecord(request.RoleID, true)
end

return MsgCmd_ReadStoryReply
