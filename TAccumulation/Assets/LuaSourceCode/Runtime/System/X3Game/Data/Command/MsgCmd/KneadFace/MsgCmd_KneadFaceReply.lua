﻿--- Generated by AutoGen
---
---@class MsgCmd_KneadFaceReply
local MsgCmd_KneadFaceReply = class("MsgCmd_KneadFaceReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.KneadFaceReply
function MsgCmd_KneadFaceReply:Execute(reply)
    BllMgr.GetFaceEditBLL():RecvKneadFaceReply(reply)
end

return MsgCmd_KneadFaceReply