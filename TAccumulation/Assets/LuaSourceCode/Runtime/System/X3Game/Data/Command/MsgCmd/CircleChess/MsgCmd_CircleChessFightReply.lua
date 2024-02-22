﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2021/12/28 14:39
---
---@class MsgCmd_CircleChessFightReply
local MsgCmd_CircleChessFightReply = class("MsgCmd_CircleChessFightReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param msg any
function MsgCmd_CircleChessFightReply:Execute(msg, ...)
    SelfProxyFactory.GetCircleChessProxy():CircleChessFightReply(msg)
    EventMgr.Dispatch(CircleChessDefine.Event.SERVER_CC_FIGHT_REPLY, msg)
end

return MsgCmd_CircleChessFightReply