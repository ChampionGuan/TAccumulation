﻿--- Generated by AutoGen
---
---@class MsgCmd_GetMiaoRewardReply
local MsgCmd_GetMiaoRewardReply = class("MsgCmd_GetMiaoRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.GetMiaoRewardReply
function MsgCmd_GetMiaoRewardReply:Execute(data)
	---@type CatCardConst
	local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
	EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.GETMIAOREWARD,data)
end

return MsgCmd_GetMiaoRewardReply
