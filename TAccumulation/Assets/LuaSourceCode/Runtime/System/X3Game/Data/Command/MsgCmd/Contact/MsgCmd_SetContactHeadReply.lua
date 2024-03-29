﻿--- Generated by AutoGen
---
---@class MsgCmd_SetContactHeadReply
local MsgCmd_SetContactHeadReply = class("MsgCmd_SetContactHeadReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SetContactHeadReply
function MsgCmd_SetContactHeadReply:Execute(data,request)
    SelfProxyFactory.GetPhoneContactProxy():SetContactHeadCallBack(request)
    EventMgr.Dispatch("OnSetContactHeadCallBack", request)
end

return MsgCmd_SetContactHeadReply
