﻿--- Generated by AutoGen
---
---@class MsgCmd_GirlFashionUpdateReply
local MsgCmd_GirlFashionUpdateReply = class("MsgCmd_GirlFashionUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GirlFashionUpdateReply
function MsgCmd_GirlFashionUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetFashionBLL():UpdateLocalFashionChangeReply(reply)
end

return MsgCmd_GirlFashionUpdateReply
