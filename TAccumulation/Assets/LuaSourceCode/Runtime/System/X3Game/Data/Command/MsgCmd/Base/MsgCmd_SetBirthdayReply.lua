﻿--- Generated by AutoGen
---
---@class MsgCmd_SetBirthdayReply
local MsgCmd_SetBirthdayReply = class("MsgCmd_SetBirthdayReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.SetBirthdayReply
function MsgCmd_SetBirthdayReply:Execute(reply, request)
    ---Insert Your Code Here!
    --Debug.LogError("SetBirthdayReply : " .. table.dump(reply or {}) .. "   " .. table.dump(request or {}))

    SelfProxyFactory.GetPlayerInfoProxy():UpdateBirthday(request.Birthday)
end

return MsgCmd_SetBirthdayReply
