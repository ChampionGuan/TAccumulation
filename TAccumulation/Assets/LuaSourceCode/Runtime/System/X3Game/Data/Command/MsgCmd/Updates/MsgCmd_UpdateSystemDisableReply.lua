﻿--- Generated by AutoGen
---
---@class MsgCmd_UpdateSystemDisableReply
local MsgCmd_UpdateSystemDisableReply = class("MsgCmd_UpdateSystemDisableReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.UpdateSystemDisableReply
function MsgCmd_UpdateSystemDisableReply:Execute(reply)
    ---Insert Your Code Here!
    ---更新自定义开关
    AppInfoMgr.SetCustomDisableData(reply.Diables)
end

return MsgCmd_UpdateSystemDisableReply
