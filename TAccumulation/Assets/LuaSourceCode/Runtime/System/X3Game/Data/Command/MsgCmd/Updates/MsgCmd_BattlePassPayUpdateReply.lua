﻿--- Generated by AutoGen
---
---@class MsgCmd_BattlePassPayUpdateReply
local MsgCmd_BattlePassPayUpdateReply = class("MsgCmd_BattlePassPayUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BattlePassPayUpdateReply
function MsgCmd_BattlePassPayUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    SelfProxyFactory.GetBattlePassProxy():UpdatePayInfo(reply)
end

return MsgCmd_BattlePassPayUpdateReply
