﻿--- Generated by AutoGen
---
---@class MsgCmd_DecorationPrefabOnReply
local MsgCmd_DecorationPrefabOnReply = class("MsgCmd_DecorationPrefabOnReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.DecorationPrefabOnReply
function MsgCmd_DecorationPrefabOnReply:Execute(data,cacheData)
    BllMgr.GetCollectionRoomBLL():DecorationPrefabOnReply(data,cacheData)
end

return MsgCmd_DecorationPrefabOnReply