﻿--- Generated by AutoGen
---
---@class MsgCmd_PlayerDressUpReply
local MsgCmd_PlayerDressUpReply = class("MsgCmd_PlayerDressUpReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.PlayerDressUpReply
function MsgCmd_PlayerDressUpReply:Execute(reply, clientData)
    ---Insert Your Code Here!
    BllMgr.GetFashionBLL():OnGirlFashionChangeReply(clientData)
    EventMgr.Dispatch("RoleFashion_Role_FashionUpdate")
end

return MsgCmd_PlayerDressUpReply
