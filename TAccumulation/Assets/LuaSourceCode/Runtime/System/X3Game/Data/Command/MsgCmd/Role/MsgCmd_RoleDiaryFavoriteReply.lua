﻿--- Generated by AutoGen
---
---@class MsgCmd_RoleDiaryFavoriteReply
local MsgCmd_RoleDiaryFavoriteReply = class("MsgCmd_RoleDiaryFavoriteReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.RoleDiaryFavoriteReply
function MsgCmd_RoleDiaryFavoriteReply:Execute(reply)
    ---Insert Your Code Here!
    EventMgr.Dispatch("OnRoleDiaryFavoriteEvent")
end

return MsgCmd_RoleDiaryFavoriteReply