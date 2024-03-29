﻿--- Generated by AutoGen
---
---@class MsgCmd_EasterEggTriggerReply
local MsgCmd_EasterEggTriggerReply = class("MsgCmd_EasterEggTriggerReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.EasterEggTriggerReply
function MsgCmd_EasterEggTriggerReply:Execute(reply)
    --Debug.LogError("MsgCmd_EasterEggTriggerReply : " .. table.dump(reply))

    -- update data
    SelfProxyFactory.GetEasterEggProxy():UpdateDataByMap(reply.Eggs, EasterEggEnum.DebugEventMap.EasterEggTrigger)
end

return MsgCmd_EasterEggTriggerReply
