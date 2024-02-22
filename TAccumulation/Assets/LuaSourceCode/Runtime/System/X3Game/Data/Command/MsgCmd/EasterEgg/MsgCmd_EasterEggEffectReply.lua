﻿--- Generated by AutoGen
---
---@class MsgCmd_EasterEggEffectReply
local MsgCmd_EasterEggEffectReply = class("MsgCmd_EasterEggEffectReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.EasterEggEffectReply
function MsgCmd_EasterEggEffectReply:Execute(reply)
    --Debug.LogError("EggEffectReply : " .. table.dump(reply))
    
    -- update data
    local eggInfoList = reply.Eggs
    if table.isnilorempty(eggInfoList) then return end
    for _, v in pairs(eggInfoList) do
        SelfProxyFactory.GetEasterEggProxy():UpdateData(v.Egg, EasterEggEnum.DebugEventMap.EasterEggEffect)
        
        SelfProxyFactory.GetEasterEggProxy():PoolRewardList(v.RewardList)
    end
end

return MsgCmd_EasterEggEffectReply