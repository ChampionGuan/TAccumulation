﻿--- Generated by AutoGen
---
---@class MsgCmd_ReduceBlockTowerCountReply
local MsgCmd_ReduceBlockTowerCountReply = class("MsgCmd_ReduceBlockTowerCountReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.ReduceBlockTowerCountReply
function MsgCmd_ReduceBlockTowerCountReply:Execute(reply)
    BllMgr.GetBlockTowerBLL():SetBlockList(reply.BlockList)
    local blockTowerData = BllMgr.GetBlockTowerBLL():GetBlockTowerData()
    blockTowerData:ReduceBlockTowerCountReply(reply)
    SelfProxyFactory.GetGamePlayProxy():ChangeCurrentRoundIndex(reply.RoundCount)
    SelfProxyFactory.GetGamePlayProxy():ChangeTurnCount(reply.TurnCount)
    EventMgr.Dispatch("BlockTowerGameInfoChanged")
end

return MsgCmd_ReduceBlockTowerCountReply