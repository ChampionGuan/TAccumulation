﻿--- Generated by AutoGen
---
---@class MsgCmd_FashionBuyReply
local MsgCmd_FashionBuyReply = class("MsgCmd_FashionBuyReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.FashionBuyReply
function MsgCmd_FashionBuyReply:Execute(data)
	EventMgr.Dispatch("RoleFashion_Role_BuyFinish",data.RewardList)
end

return MsgCmd_FashionBuyReply