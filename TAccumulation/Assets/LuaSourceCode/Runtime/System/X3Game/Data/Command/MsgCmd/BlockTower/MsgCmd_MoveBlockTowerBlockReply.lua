﻿--- Generated by AutoGen
---
---@class MsgCmd_MoveBlockTowerBlockReply
local MsgCmd_MoveBlockTowerBlockReply = class("MsgCmd_MoveBlockTowerBlockReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.MoveBlockTowerBlockReply
function MsgCmd_MoveBlockTowerBlockReply:Execute(reply)
    SelfProxyFactory.GetGamePlayProxy():ChangeTurnCount(reply.TurnCount)
    local blockTowerData = BllMgr.GetBlockTowerBLL():GetBlockTowerData()
    blockTowerData:MoveBlockTowerBlockReply(reply)
    EventMgr.Dispatch("BlockTowerGameInfoChanged")
end

return MsgCmd_MoveBlockTowerBlockReply