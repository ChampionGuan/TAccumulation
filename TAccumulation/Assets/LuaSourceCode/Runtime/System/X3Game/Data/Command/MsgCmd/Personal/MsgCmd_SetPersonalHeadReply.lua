﻿--- Generated by AutoGen
---
---@class MsgCmd_SetPersonalHeadReply
local MsgCmd_SetPersonalHeadReply = class("MsgCmd_SetPersonalHeadReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SetPersonalHeadReply
---@param request pbcmessage.SetPersonalHeadRequest
function MsgCmd_SetPersonalHeadReply:Execute(data, request)
    if request and (request.Type ~= 2 or request.HeadPhoto.Status == 2) then
        SelfProxyFactory.GetPlayerInfoProxy():ChangeHead(request)
    end
end

return MsgCmd_SetPersonalHeadReply