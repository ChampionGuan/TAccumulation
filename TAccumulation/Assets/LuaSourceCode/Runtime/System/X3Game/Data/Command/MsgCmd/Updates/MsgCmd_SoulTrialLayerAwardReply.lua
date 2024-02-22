﻿--- Generated by AutoGen
---
---@class MsgCmd_SoulTrialLayerAwardReply
local MsgCmd_SoulTrialLayerAwardReply = class("MsgCmd_SoulTrialLayerAwardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SoulTrialLayerAwardReply
function MsgCmd_SoulTrialLayerAwardReply:Execute(data)
    local soulTrialCfg = LuaCfgMgr.GetDataByCondition("SoulTrial", {RoleID = data.RoleId, Floor = data.Layer})
    if not soulTrialCfg then return end
    
    SelfProxyFactory.GetSoulTrialProxy():SoulTrialLayerAwardReply(soulTrialCfg.ID, data.Rewards)
    --EventMgr.Dispatch(SoulTrialConst.Event.SERVER_ST_LAYER_AWARD_REPLY, data)
end

return MsgCmd_SoulTrialLayerAwardReply