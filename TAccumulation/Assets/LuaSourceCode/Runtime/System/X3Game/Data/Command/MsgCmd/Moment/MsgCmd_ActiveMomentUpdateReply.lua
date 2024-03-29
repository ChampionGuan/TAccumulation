﻿--- Generated by AutoGen
---
---@class MsgCmd_ActiveMomentUpdateReply
local MsgCmd_ActiveMomentUpdateReply = class("MsgCmd_ActiveMomentUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.ActiveMomentUpdateReply
function MsgCmd_ActiveMomentUpdateReply:Execute(data)
    if data.OpType == 1 then
        BllMgr.GetMobileMomentBLL():AddActiveMoment(data.ActiveMomentList)
    else
        BllMgr.GetMobileMomentBLL():RemoveActiveMoment(data.ActiveMomentList)
    end
end

return MsgCmd_ActiveMomentUpdateReply
