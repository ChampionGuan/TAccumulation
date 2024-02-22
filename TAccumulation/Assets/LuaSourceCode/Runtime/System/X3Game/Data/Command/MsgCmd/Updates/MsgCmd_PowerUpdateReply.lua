﻿--- Generated by AutoGen
---
---@class MsgCmd_PowerUpdateReply
local MsgCmd_PowerUpdateReply = class("MsgCmd_PowerUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.PowerUpdateReply
function MsgCmd_PowerUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetCoinProxy():CoinUpdate(-X3_CFG_CONST.ITEM_TYPE_STAMINA, reply.PowerTime, true)
    SelfProxyFactory.GetCoinProxy():CoinUpdate(X3_CFG_CONST.ITEM_TYPE_STAMINA, reply.Power)
end

return MsgCmd_PowerUpdateReply