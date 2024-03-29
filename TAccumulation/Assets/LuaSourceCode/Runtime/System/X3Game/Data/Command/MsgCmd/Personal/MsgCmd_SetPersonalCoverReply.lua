﻿--- Generated by AutoGen
---
---@class MsgCmd_SetPersonalCoverReply
local MsgCmd_SetPersonalCoverReply = class("MsgCmd_SetPersonalCoverReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SetPersonalCoverReply
---@param request pbcmessage.SetPersonalCoverRequest
function MsgCmd_SetPersonalCoverReply:Execute(data, request)
    if request.CoverPhoto == nil or request.CoverPhoto.Url == "" then
        SelfProxyFactory.GetPlayerInfoProxy():UpdateCover()
    end

    EventMgr.Dispatch("ReplaceCoverCB")
end

return MsgCmd_SetPersonalCoverReply
