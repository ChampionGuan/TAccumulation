﻿--- Generated by AutoGen
---
---@class MsgCmd_SetAsmrBackgroundReply
local MsgCmd_SetAsmrBackgroundReply = class("MsgCmd_SetAsmrBackgroundReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.SetAsmrBackgroundReply
function MsgCmd_SetAsmrBackgroundReply:Execute(reply, sendData)
    BllMgr.GetASMRBLL():UpdateRadioCustomBg(sendData)
end

return MsgCmd_SetAsmrBackgroundReply
