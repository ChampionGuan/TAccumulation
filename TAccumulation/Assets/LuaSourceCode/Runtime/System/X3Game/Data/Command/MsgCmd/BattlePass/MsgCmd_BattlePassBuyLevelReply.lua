﻿--- Generated by AutoGen
---
---@class MsgCmd_BattlePassBuyLevelReply
local MsgCmd_BattlePassBuyLevelReply = class("MsgCmd_BattlePassBuyLevelReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BattlePassBuyLevelReply
function MsgCmd_BattlePassBuyLevelReply:Execute(reply, request)
    ---Insert Your Code Here!
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_40051)
end

return MsgCmd_BattlePassBuyLevelReply
