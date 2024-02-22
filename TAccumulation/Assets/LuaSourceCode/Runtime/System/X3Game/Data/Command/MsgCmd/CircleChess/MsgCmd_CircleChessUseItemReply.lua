﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2021/12/28 14:47
---
---@class MsgCmd_CircleChessUseItemReply
local MsgCmd_CircleChessUseItemReply = class("MsgCmd_CircleChessUseItemReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param msg any
function MsgCmd_CircleChessUseItemReply:Execute(msg, ...)
    SelfProxyFactory.GetCircleChessProxy():CircleChessUseItemReply(msg)
    EventMgr.Dispatch(CircleChessDefine.Event.SERVER_CC_USE_ITEM_REPLY, msg)
end

return MsgCmd_CircleChessUseItemReply