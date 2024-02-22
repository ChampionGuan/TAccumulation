﻿--- Generated by AutoGen
---
---@class MsgCmd_SCoreUpdateReply
local MsgCmd_SCoreUpdateReply = class("MsgCmd_SCoreUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SCoreUpdateReply
function MsgCmd_SCoreUpdateReply:Execute(data)
    if data.OpType == 1 then
        BllMgr.GetScoreBLL():ShowScoreList(data.SCoreList)
    end
    SelfProxyFactory.GetScoreProxy():OnSCoreUpdateReply(data)
end

return MsgCmd_SCoreUpdateReply
