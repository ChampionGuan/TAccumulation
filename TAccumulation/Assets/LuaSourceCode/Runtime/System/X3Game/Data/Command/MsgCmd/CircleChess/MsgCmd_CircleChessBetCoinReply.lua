﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2021/12/28 14:55
---
---@class MsgCmd_CircleChessBetCoinReply
local MsgCmd_CircleChessBetCoinReply = class("MsgCmd_CircleChessBetCoinReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param msg any
function MsgCmd_CircleChessBetCoinReply:Execute(msg, ...)
    SelfProxyFactory.GetCircleChessProxy():CircleChessBetCoinReply(msg)
    EventMgr.Dispatch(CircleChessDefine.Event.SERVER_CC_BET_COIN_REPLY, msg)
end

return MsgCmd_CircleChessBetCoinReply