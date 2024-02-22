﻿--- Generated by AutoGen
---
---@class MsgCmd_UFOEncourageReply
local MsgCmd_UFOEncourageReply = class("MsgCmd_UFOEncourageReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param msg pbcmessage.UFOEncourageReply
function MsgCmd_UFOEncourageReply:Execute(msg)
	BllMgr.GetUFOCatcherBLL().buffID = msg.BuffId
	if (msg.NewDoll ~= nil) then
		BllMgr.GetUFOCatcherBLL().newDoll = CS.S2Int()
		BllMgr.GetUFOCatcherBLL().newDoll.ID = msg.NewDoll.Id
		BllMgr.GetUFOCatcherBLL().newDoll.Num = msg.NewDoll.Num
	end
	local maxCount = SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount() + msg.AddMaxCount
	SelfProxyFactory.GetGamePlayProxy():ChangeMaxRoundCount(maxCount, false)
	BllMgr.GetUFOCatcherBLL().resultType = msg.ResultType
	GamePlayMgr.GamePlayResume()
	EventMgr.Dispatch("UFOEvent_GetCheerBuff")
end

return MsgCmd_UFOEncourageReply
